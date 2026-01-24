#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import <sys/stat.h>

// --- Cấu trúc bảo mật ghi đè ---
void secure_patch(uintptr_t offset, const char *data, size_t size) {
    uintptr_t address = (uintptr_t)_dyld_get_image_header(0) + offset;
    mach_port_t task = mach_task_self();
    
    // Cấp quyền ghi tạm thời
    if (vm_protect(task, (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY) == KERN_SUCCESS) {
        memcpy((void *)address, data, size);
        // Trả về quyền Chỉ đọc và Thực thi (Quan trọng để không bị quét bộ nhớ ghi)
        vm_protect(task, (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
    }
}

// --- Siêu Anti-Ban: Chặn đứng Report ---
void ultraAntiBan() {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // Danh sách các mục tiêu cần khóa miệng
    NSArray *targets = @[
        @"TencentLog", @"ReportData", @"CrashReport", @"Pandora", @"ProgramDatabase", @"com_tencent_imsdk"
    ];

    for (NSString *folder in targets) {
        NSString *path = [docDir stringByAppendingPathComponent:folder];
        
        // 1. Xóa nếu tồn tại
        [fm removeItemAtPath:path error:nil];
        
        // 2. Tạo file trống thay vì thư mục để game không ghi đè vào được
        [@"" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        // 3. Khóa quyền hoàn toàn (0000) - Không ai có quyền đọc/ghi/xem
        chmod([path UTF8String], 0000);
    }
}

@interface DQMenu : UIView
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) UIView *box;
@property (nonatomic, strong) UISlider *camSlider;
@property (nonatomic, strong) UILabel *camLabel;
@end

@implementation DQMenu {
    BOOL _isHackActive;
    NSTimer *_antiBanTimer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.tag = 178;
        self.layer.zPosition = 1000000;

        // Nút DQ (Giao diện tối giản để tránh bị quay màn hình phát hiện)
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn.frame = CGRectMake(60, 160, 50, 50);
        _btn.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.5];
        _btn.layer.cornerRadius = 25;
        [_btn setTitle:@"DQ" forState:UIControlStateNormal];
        [_btn addTarget:self action:@selector(toggleBox) forControlEvents:UIControlEventTouchUpInside];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
        [_btn addGestureRecognizer:pan];
        [self addSubview:_btn];

        // Bảng Menu
        _box = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 240)];
        _box.center = self.center;
        _box.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.1 alpha:0.95];
        _box.layer.cornerRadius = 20;
        _box.layer.borderWidth = 1;
        _box.layer.borderColor = [UIColor cyanColor].CGColor;
        _box.hidden = YES;
        [self addSubview:_box];

        // Hack Map Switch
        UIButton *sw = [UIButton buttonWithType:UIButtonTypeCustom];
        sw.frame = CGRectMake(30, 40, 200, 45);
        sw.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
        sw.layer.cornerRadius = 10;
        [sw setTitle:@"HACK MAP: OFF" forState:UIControlStateNormal];
        [sw addTarget:self action:@selector(switchMap:) forControlEvents:UIControlEventTouchUpInside];
        [_box addSubview:sw];

        // Cam Xa Slider
        _camLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 100, 200, 20)];
        _camLabel.text = @"DRONE VIEW: 1.0";
        _camLabel.textColor = [UIColor cyanColor];
        _camLabel.textAlignment = NSTextAlignmentCenter;
        [_box addSubview:_camLabel];

        _camSlider = [[UISlider alloc] initWithFrame:CGRectMake(30, 130, 200, 30)];
        _camSlider.minimumValue = 1.0;
        _camSlider.maximumValue = 2.5;
        _camSlider.value = 1.0;
        // Chỉ ghi vào bộ nhớ khi người dùng thả tay ra (Chống quét tần suất)
        [_camSlider addTarget:self action:@selector(sliderReleased:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [_camSlider addTarget:self action:@selector(sliderValueChanging:) forControlEvents:UIControlEventValueChanged];
        [_box addSubview:_camSlider];

        // Nút ẩn Menu hoàn toàn (Để qua mặt quay màn hình)
        UIButton *hideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        hideBtn.frame = CGRectMake(30, 180, 200, 40);
        hideBtn.setTitle:@"ẨN MENU TẠM THỜI", forState:UIControlStateNormal];
        hideBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [hideBtn addTarget:self action:@selector(hideCompletely) forControlEvents:UIControlEventTouchUpInside];
        [_box addSubview:hideBtn];

        // Kích hoạt Anti-Ban lặp lại mỗi 30 giây
        _antiBanTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(runSafeClean) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)sliderValueChanging:(UISlider *)s {
    _camLabel.text = [NSString stringWithFormat:@"DRONE VIEW: %.2f", s.value];
}

- (void)sliderReleased:(UISlider *)s {
    float val = s.value;
    uintptr_t camOffset = 0x2E1A5C4; // Hãy thay Offset chuẩn
    secure_patch(camOffset, (const char *)&val, 4);
}

- (void)switchMap:(UIButton *)sender {
    _isHackActive = !_isHackActive;
    uintptr_t mapOffset = 0x1D2C4A0;
    if (_isHackActive) {
        secure_patch(mapOffset, "\x00\x00\x80\xD2\xC0\x03\x5F\xD6", 8);
        [sender setTitle:@"HACK MAP: ON" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
    } else {
        // Trả về mã gốc để qua mặt lúc quét cuối trận
        secure_patch(mapOffset, "\xFF\x43\x00\xD1\xF4\x4F\x01\xA9", 8);
        [sender setTitle:@"HACK MAP: OFF" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    }
}

- (void)runSafeClean { ultraAntiBan(); }

- (void)hideCompletely {
    self.hidden = YES;
    // Lắc điện thoại hoặc đợi 10 giây để hiện lại (Tùy bạn cài đặt)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ self.hidden = NO; });
}

- (void)toggleBox { _box.hidden = !_box.hidden; }
- (void)handleDrag:(UIPanGestureRecognizer *)g {
    CGPoint t = [g translationInView:self];
    g.view.center = CGPointMake(g.view.center.x + t.x, g.view.center.y + t.y);
    [g setTranslation:CGPointZero inView:self];
}
@end

static void StartMenu() {
    UIWindow *w = [UIApplication sharedApplication].keyWindow;
    if (w && ![w viewWithTag:178]) {
        [w addSubview:[[DQMenu alloc] initWithFrame:w.bounds]];
        ultraAntiBan();
    } else if (!w) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ StartMenu(); });
    }
}

static __attribute__((constructor)) void init() {
    // Đợi game load xong các lớp bảo mật ban đầu
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        StartMenu();
    });
}
