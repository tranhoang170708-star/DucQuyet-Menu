#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>

// ==========================================
// 🎯 OFFSETS CHUẨN AOV 1.61
// ==========================================
// Hack Map: Chuẩn 1.61
#define OFFSET_MAP 0x1D2C4A0 
// Cam Xa: Đây là Offset FOV trong UnityFramework bản 1.61
#define OFFSET_CAM 0x2E30A10 

// Mã Hex để bật Hack Map
#define HEX_MAP_ON "\x20\x00\x80\x52\xC0\x03\x5F\xD6"
#define HEX_MAP_OFF "\xFF\x43\x00\xD1\xF4\x4F\x01\xA9"

// --- Hàm ghi bộ nhớ an toàn ---
void patch_memory(uintptr_t offset, const char *data, size_t size) {
    uintptr_t base = (uintptr_t)_dyld_get_image_header(0);
    uintptr_t address = base + offset;
    vm_protect(mach_task_self(), (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    memcpy((void *)address, data, size);
    vm_protect(mach_task_self(), (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
}

// ==========================================
// 🎨 GIAO DIỆN MENU VIP
// ==========================================
@interface DQMenu : UIView
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIButton *icon;
@end

@implementation DQMenu {
    BOOL _mapOn;
    UISlider *_camSlider;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tag = 9999;
        
        // 1. Nút Icon nổi (Logo)
        _icon = [UIButton buttonWithType:UIButtonTypeCustom];
        _icon.frame = CGRectMake(100, 100, 55, 55);
        _icon.backgroundColor = [UIColor colorWithRed:0.0 green:0.9 blue:1.0 alpha:0.9];
        _icon.layer.cornerRadius = 27.5;
        _icon.layer.shadowColor = [UIColor cyanColor].CGColor;
        _icon.layer.shadowRadius = 8;
        _icon.layer.shadowOpacity = 0.8;
        [_icon setTitle:@"DQ" forState:UIControlStateNormal];
        [_icon addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_icon];

        // 2. Khung Menu chính
        _container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 220)];
        _container.center = self.center;
        _container.backgroundColor = [UIColor clearColor];
        _container.alpha = 0;
        _container.transform = CGAffineTransformMakeScale(0.5, 0.5);
        
        // Hiệu ứng nền mờ (Blur)
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
        blurView.frame = _container.bounds;
        blurView.layer.cornerRadius = 20;
        blurView.clipsToBounds = YES;
        blurView.layer.borderWidth = 1.5;
        blurView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
        [_container addSubview:blurView];

        // Tiêu đề Neon
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 280, 30)];
        title.text = @"DUC QUYET MENU 1.61";
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont fontWithName:@"AvenirNext-Bold" size:18];
        [_container addSubview:title];

        // Nút Hack Map
        UIButton *btnMap = [UIButton buttonWithType:UIButtonTypeCustom];
        btnMap.frame = CGRectMake(30, 60, 220, 45);
        btnMap.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
        btnMap.layer.cornerRadius = 10;
        [btnMap setTitle:@"Hack Map: OFF" forState:UIControlStateNormal];
        [btnMap addTarget:self action:@selector(mapSwitch:) forControlEvents:UIControlEventTouchUpInside];
        [_container addSubview:btnMap];

        // Slider Cam Xa
        UILabel *lblCam = [[UILabel alloc] initWithFrame:CGRectMake(30, 120, 220, 20)];
        lblCam.text = @"Drone View (Cam Xa)";
        lblCam.textColor = [UIColor cyanColor];
        lblCam.font = [UIFont systemFontOfSize:12];
        [_container addSubview:lblCam];

        _camSlider = [[UISlider alloc] initWithFrame:CGRectMake(30, 145, 220, 30)];
        _camSlider.minimumValue = 1.0;
        _camSlider.maximumValue = 2.5;
        _camSlider.value = 1.0;
        [_camSlider addTarget:self action:@selector(camChanged:) forControlEvents:UIControlEventTouchUpInside];
        [_container addSubview:_camSlider];

        [self addSubview:_container];

        // Kéo thả icon
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drag:)];
        [_icon addGestureRecognizer:pan];
    }
    return self;
}

// ==========================================
// 🛠 FIX LIỆT CẢM ỨNG (HIT-TEST)
// ==========================================
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) return nil; // Chạm xuyên qua lớp nền vào game
    return hitView; // Chỉ nhận cảm ứng nếu chạm vào nút hoặc menu
}

// ==========================================
// ⚙️ LOGIC CHỨC NĂNG
// ==========================================
- (void)mapSwitch:(UIButton *)sender {
    _mapOn = !_mapOn;
    if (_mapOn) {
        patch_memory(OFFSET_MAP, HEX_MAP_ON, 8);
        [sender setTitle:@"Hack Map: ON" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:0.5];
    } else {
        patch_memory(OFFSET_MAP, HEX_MAP_OFF, 8);
        [sender setTitle:@"Hack Map: OFF" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    }
}

- (void)camChanged:(UISlider *)sender {
    float val = sender.value;
    patch_memory(OFFSET_CAM, (const char *)&val, 4);
}

- (void)toggle {
    [UIView animateWithDuration:0.3 animations:^{
        if (self->_container.alpha == 0) {
            self->_container.alpha = 1;
            self->_container.transform = CGAffineTransformIdentity;
        } else {
            self->_container.alpha = 0;
            self->_container.transform = CGAffineTransformMakeScale(0.5, 0.5);
        }
    }];
}

- (void)drag:(UIPanGestureRecognizer *)p {
    CGPoint loc = [p locationInView:self];
    _icon.center = loc;
}
@end

// ==========================================
// 🚀 INJECT & FIX CRASH (iOS 13+ SUPPORT)
// ==========================================
static void __attribute__((constructor)) init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 6 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIWindow *win = nil;
        // Sử dụng @available để fix lỗi biên dịch GitHub Actions
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    win = scene.windows.firstObject;
                    break;
                }
            }
        }
        if (!win) win = [UIApplication sharedApplication].keyWindow;
        
        if (win) {
            DQMenu *m = [[DQMenu alloc] initWithFrame:win.bounds];
            [win addSubview:m];
        }
    });
}
