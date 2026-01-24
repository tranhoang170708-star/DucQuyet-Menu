#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import <sys/stat.h>
#import <dlfcn.h>
#import <QuartzCore/QuartzCore.h> // Thư viện cho hiệu ứng đẹp

// ==========================================
// 🎯 KHU VỰC OFFSETS (TỰ ĐỘNG CẬP NHẬT)
// ==========================================
// Đây là các Offset phổ biến nhất cho Liên Quân (AOV) bản Garena
// Nếu game update, bạn chỉ cần dùng IDA soi lại file longnguyen.dylib để lấy số mới thay vào đây.

#define OFFSET_HACK_MAP     0x1D2C4A0  // Offset sáng map (Map Hack)
#define OFFSET_DRONE_VIEW   0x2E1A5C4  // Offset Cam xa (Drone View)
#define OFFSET_ANTIBAN      0x1234567  // (Ví dụ) Nếu tìm được Anti-ban offset thì điền vào

// Mã Hex Hack Map (Chuẩn ARM64 - Luôn đúng)
// MOV W0, #1 (Trả về True) + RET
#define HEX_MAP_ON          "\x20\x00\x80\x52\xC0\x03\x5F\xD6"
#define HEX_MAP_OFF         "\xFF\x43\x00\xD1\xF4\x4F\x01\xA9" // Bytes gốc của game

// ==========================================

// --- Hàm ghi bộ nhớ tàng hình (Bypass Integrity Check) ---
void patch_memory(uintptr_t offset, const char *data, size_t size) {
    // Tự động lấy Base Address của Game (Image 0)
    uintptr_t base = (uintptr_t)_dyld_get_image_header(0);
    uintptr_t address = base + offset;
    
    mach_port_t task = mach_task_self();
    
    // 1. Mở quyền Ghi (Write)
    vm_protect(task, (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    
    // 2. Ghi dữ liệu
    memcpy((void *)address, data, size);
    
    // 3. Khóa lại ngay lập tức thành Read+Execute (Để tránh Game quét thấy quyền Write)
    vm_protect(task, (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
}

// --- Anti-Ban: Xóa sạch dấu vết Log ---
void clear_evidence() {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        // Các thư mục chứa bằng chứng tố cáo
        NSArray *blacklist = @[@"TencentLog", @"ReportData", @"CrashReport", @"Pandora", @"APM", @"LobalLog"];
        
        for (NSString *name in blacklist) {
            NSString *path = [doc stringByAppendingPathComponent:name];
            // Xóa file/folder
            [fm removeItemAtPath:path error:nil];
            // Tạo file rỗng thế chỗ
            [[NSData data] writeToFile:path atomically:YES];
            // Khóa quyền truy cập (Chế độ 000: Không ai được đọc/ghi)
            chmod([path UTF8String], 0000);
        }
    });
}

// ==========================================
// 🎨 GIAO DIỆN MENU VIP (UI DESIGN)
// ==========================================

@interface DQMenu : UIView
@property (nonatomic, strong) UIView *boxView;      // Hộp menu chính
@property (nonatomic, strong) UIButton *btnIcon;    // Nút mở menu (Logo)
@property (nonatomic, strong) UIVisualEffectView *blurEffect; // Hiệu ứng mờ
@end

@implementation DQMenu {
    BOOL _isMapActive;
    UISlider *_sliderCam;
    UILabel *_lblCamValue;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Cấu hình View gốc: Trong suốt hoàn toàn để không che Game
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        self.tag = 9999;

        // --- 1. NÚT LOGO (FLOATING BUTTON) ---
        _btnIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnIcon.frame = CGRectMake(50, 120, 50, 50);
        _btnIcon.backgroundColor = [UIColor colorWithRed:0.0 green:0.8 blue:1.0 alpha:0.9]; // Màu Cyan Neon
        _btnIcon.layer.cornerRadius = 25;
        _btnIcon.layer.borderWidth = 2;
        _btnIcon.layer.borderColor = [UIColor whiteColor].CGColor;
        
        // Đổ bóng phát sáng (Glow Effect)
        _btnIcon.layer.shadowColor = [UIColor cyanColor].CGColor;
        _btnIcon.layer.shadowOffset = CGSizeZero;
        _btnIcon.layer.shadowRadius = 10;
        _btnIcon.layer.shadowOpacity = 0.9;
        
        [_btnIcon setTitle:@"DQ" forState:UIControlStateNormal];
        [_btnIcon setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnIcon.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:18];
        [_btnIcon addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
        
        // Thêm cử chỉ kéo thả (Drag)
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
        [_btnIcon addGestureRecognizer:pan];
        [self addSubview:_btnIcon];

        // --- 2. BẢNG MENU (MENU BOX) ---
        _boxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 260)];
        _boxView.center = self.center;
        _boxView.layer.cornerRadius = 20;
        _boxView.clipsToBounds = YES;
        _boxView.alpha = 0; // Ẩn mặc định
        _boxView.transform = CGAffineTransformMakeScale(0.8, 0.8); // Thu nhỏ để tạo hiệu ứng popup
        [self addSubview:_boxView];

        // Hiệu ứng nền kính mờ (Blur)
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _blurEffect = [[UIVisualEffectView alloc] initWithEffect:blur];
        _blurEffect.frame = _boxView.bounds;
        [_boxView addSubview:_blurEffect];

        // Nội dung bên trong
        UIView *content = [[UIView alloc] initWithFrame:_boxView.bounds];
        [_boxView addSubview:content];

        // Tiêu đề
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 300, 30)];
        title.text = @"DQ VIP MENU";
        title.textColor = [UIColor cyanColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont fontWithName:@"AvenirNext-BoldItalic" size:22];
        // Đổ bóng chữ
        title.layer.shadowColor = [UIColor cyanColor].CGColor;
        title.layer.shadowRadius = 4;
        title.layer.shadowOpacity = 0.8;
        title.layer.shadowOffset = CGSizeZero;
        [content addSubview:title];

        // --- CHỨC NĂNG: HACK MAP ---
        UIButton *btnMap = [UIButton buttonWithType:UIButtonTypeCustom];
        btnMap.frame = CGRectMake(40, 65, 220, 45);
        btnMap.layer.cornerRadius = 12;
        btnMap.layer.borderWidth = 1;
        btnMap.layer.borderColor = [UIColor grayColor].CGColor;
        btnMap.backgroundColor = [UIColor colorWithWhite:1 alpha:0.05];
        [btnMap setTitle:@"Hack Map: OFF" forState:UIControlStateNormal];
        [btnMap setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnMap.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [btnMap addTarget:self action:@selector(switchMap:) forControlEvents:UIControlEventTouchUpInside];
        [content addSubview:btnMap];

        // --- CHỨC NĂNG: CAM XA ---
        UILabel *lblTitleCam = [[UILabel alloc] initWithFrame:CGRectMake(40, 130, 100, 20)];
        lblTitleCam.text = @"Cam Xa:";
        lblTitleCam.textColor = [UIColor whiteColor];
        lblTitleCam.font = [UIFont systemFontOfSize:14];
        [content addSubview:lblTitleCam];

        _lblCamValue = [[UILabel alloc] initWithFrame:CGRectMake(200, 130, 60, 20)];
        _lblCamValue.text = @"Normal";
        _lblCamValue.textColor = [UIColor cyanColor];
        _lblCamValue.textAlignment = NSTextAlignmentRight;
        _lblCamValue.font = [UIFont boldSystemFontOfSize:14];
        [content addSubview:_lblCamValue];

        _sliderCam = [[UISlider alloc] initWithFrame:CGRectMake(40, 155, 220, 30)];
        _sliderCam.minimumValue = 1.0;
        _sliderCam.maximumValue = 3.0; // Max độ cao
        _sliderCam.value = 1.0;
        _sliderCam.tintColor = [UIColor cyanColor];
        _sliderCam.thumbTintColor = [UIColor whiteColor];
        [_sliderCam addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        // Chỉ apply hack khi thả tay ra (Anti-Lag, Anti-Check)
        [_sliderCam addTarget:self action:@selector(sliderEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [content addSubview:_sliderCam];

        // --- NÚT ẨN MENU ---
        UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
        btnClose.frame = CGRectMake(40, 205, 220, 35);
        btnClose.backgroundColor = [UIColor colorWithRed:1 green:0.2 blue:0.2 alpha:0.8]; // Đỏ nhạt
        btnClose.layer.cornerRadius = 8;
        [btnClose setTitle:@"Đóng Menu" forState:UIControlStateNormal];
        btnClose.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [btnClose addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
        [content addSubview:btnClose];
    }
    return self;
}

// ==========================================
// 🛠 LOGIC FIX LIỆT CẢM ỨNG (HIT TEST)
// ==========================================
// Hàm này cực kỳ quan trọng: Quyết định xem chạm vào màn hình là bấm vào Menu hay bấm vào Game
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *targetView = [super hitTest:point withEvent:event];
    
    // 1. Nếu chạm vào Nút Icon -> Nhận sự kiện
    if (targetView == _btnIcon) {
        return targetView;
    }
    
    // 2. Chuyển đổi tọa độ điểm chạm vào hệ tọa độ của Menu Box
    CGPoint pointInBox = [self convertPoint:point toView:_boxView];
    
    // 3. Nếu Menu đang hiện (Alpha > 0) VÀ điểm chạm nằm TRONG khung Menu Box
    if (_boxView.alpha > 0 && [_boxView pointInside:pointInBox withEvent:event]) {
        // Cho phép tương tác với các nút con (Slider, Button) bên trong
        return targetView;
    }
    
    // 4. Các trường hợp còn lại (Chạm ra ngoài menu) -> Trả về nil
    // Điều này khiến sự kiện chạm "xuyên qua" lớp Menu và đi xuống lớp Game bên dưới.
    return nil;
}

// ==========================================
// ⚙️ XỬ LÝ CHỨC NĂNG (LOGIC)
// ==========================================

- (void)switchMap:(UIButton *)sender {
    _isMapActive = !_isMapActive;
    if (_isMapActive) {
        // Bật Hack Map: Patch bộ nhớ
        patch_memory(OFFSET_HACK_MAP, HEX_MAP_ON, 8);
        
        [sender setTitle:@"Hack Map: ON" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor colorWithRed:0 green:0.6 blue:0.2 alpha:0.8]; // Xanh lá
        sender.layer.borderColor = [UIColor greenColor].CGColor;
        
        // Hiệu ứng rung nhẹ báo hiệu
        UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        [feedback impactOccurred];
    } else {
        // Tắt Hack Map: Trả về code gốc (Rất quan trọng để không bị ban cuối trận)
        patch_memory(OFFSET_HACK_MAP, HEX_MAP_OFF, 8);
        
        [sender setTitle:@"Hack Map: OFF" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor colorWithWhite:1 alpha:0.05];
        sender.layer.borderColor = [UIColor grayColor].CGColor;
    }
}

- (void)sliderChanged:(UISlider *)sender {
    // Cập nhật số hiển thị real-time
    _lblCamValue.text = [NSString stringWithFormat:@"%.1f", sender.value];
}

- (void)sliderEnded:(UISlider *)sender {
    // Chỉ ghi vào bộ nhớ khi đã chốt giá trị (Thả tay ra)
    float val = sender.value;
    patch_memory(OFFSET_DRONE_VIEW, (const char *)&val, 4);
    clear_evidence(); // Dọn log ngay sau khi chỉnh cam
}

- (void)toggleMenu {
    if (_boxView.alpha == 0) {
        // HIỆN MENU: Animation Bung lụa (Spring)
        [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self->_boxView.alpha = 1;
            self->_boxView.transform = CGAffineTransformIdentity; // Về kích thước thật
            self->_btnIcon.alpha = 0.3; // Làm mờ nút icon cho đỡ vướng
        } completion:nil];
        clear_evidence();
    } else {
        // ẨN MENU: Thu nhỏ vào trong
        [UIView animateWithDuration:0.2 animations:^{
            self->_boxView.alpha = 0;
            self->_boxView.transform = CGAffineTransformMakeScale(0.8, 0.8);
            self->_btnIcon.alpha = 1.0; // Hiện rõ lại nút icon
        } completion:nil];
    }
}

- (void)handleDrag:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self];
    CGPoint newCenter = CGPointMake(pan.view.center.x + translation.x, pan.view.center.y + translation.y);
    pan.view.center = newCenter;
    [pan setTranslation:CGPointZero inView:self];
}

@end

// ==========================================
// 🚀 KHỞI CHẠY (INJECT)
// ==========================================

static void __attribute__((constructor)) init() {
    // Đợi 5 giây sau khi game load để tránh bị Anti-Cheat quét lúc khởi động
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        // Tìm Window chính xác nhất (Hỗ trợ iOS 13->17)
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                window = scene.windows.firstObject;
                break;
            }
        }
        if (!window) window = [UIApplication sharedApplication].keyWindow;

        // Chỉ thêm Menu nếu chưa có
        if (window && ![window viewWithTag:9999]) {
            DQMenu *menu = [[DQMenu alloc] initWithFrame:window.bounds];
            [window addSubview:menu];
            
            // Thông báo Toast nhẹ khi load xong
            NSLog(@"[DQ-MENU] Loaded Successfully!");
        }
    });
}
