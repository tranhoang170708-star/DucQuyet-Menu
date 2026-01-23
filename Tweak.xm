#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>

// --- Hàm ghi vào bộ nhớ game ---
void patch_memory(uintptr_t offset, const char *data, size_t size) {
    uintptr_t address = (uintptr_t)_dyld_get_image_header(0) + offset;
    mach_port_t task = mach_task_self();
    if (vm_protect(task, (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY) == KERN_SUCCESS) {
        memcpy((void *)address, data, size);
        vm_protect(task, (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
    }
}

@interface DQMenu : UIView
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIView *panel;
@property (nonatomic, strong) UIButton *hackBtn;
@end

@implementation DQMenu {
    BOOL _isHackOn;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.tag = 178;
        self.layer.zPosition = 1000000;

        // 1. Nút DQ tròn (Có thể kéo đi khắp màn hình)
        _menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _menuButton.frame = CGRectMake(50, 150, 60, 60);
        _menuButton.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.7];
        _menuButton.layer.cornerRadius = 30;
        _menuButton.layer.borderWidth = 2;
        _menuButton.layer.borderColor = [UIColor whiteColor].CGColor;
        [_menuButton setTitle:@"DQ" forState:UIControlStateNormal];
        [_menuButton addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [_menuButton addGestureRecognizer:pan];
        [self addSubview:_menuButton];

        // 2. Bảng điều khiển Hack
        _panel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 160)];
        _panel.center = self.center;
        _panel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.1 alpha:0.9];
        _panel.layer.cornerRadius = 15;
        _panel.layer.borderWidth = 1.5;
        _panel.layer.borderColor = [UIColor cyanColor].CGColor;
        _panel.hidden = YES;
        [self addSubview:_panel];

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 240, 30)];
        title.text = @"HACK MAP LIÊN QUÂN";
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont boldSystemFontOfSize:16];
        [_panel addSubview:title];

        // Nút bấm Bật/Tắt
        _hackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _hackBtn.frame = CGRectMake(20, 60, 200, 45);
        _hackBtn.backgroundColor = [UIColor darkGrayColor];
        _hackBtn.layer.cornerRadius = 10;
        [_hackBtn setTitle:@"HACK MAP: OFF" forState:UIControlStateNormal];
        [_hackBtn addTarget:self action:@selector(switchHack) forControlEvents:UIControlEventTouchUpInside];
        [_panel addSubview:_hackBtn];

        UILabel *footer = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, 240, 20)];
        footer.text = @"Facebook: Đức Quyết";
        footer.textColor = [UIColor grayColor];
        footer.font = [UIFont systemFontOfSize:10];
        footer.textAlignment = NSTextAlignmentCenter;
        [_panel addSubview:footer];
    }
    return self;
}

// Xử lý Bật/Tắt
- (void)switchHack {
    _isHackOn = !_isHackOn;
    
    if (_isHackOn) {
        // --- KHI BẬT: Ghi mã Hack ---
        // Offset cho bản 1.55.1.x (Bạn hãy kiểm tra lại offset của bản hiện tại)
        patch_memory(0x1D2C4A0, "\x00\x00\x80\xD2\xC0\x03\x5F\xD6", 8);
        
        [_hackBtn setTitle:@"HACK MAP: ON" forState:UIControlStateNormal];
        _hackBtn.backgroundColor = [UIColor colorWithRed:0 green:0.6 blue:0 alpha:1]; // Màu xanh
    } else {
        // --- KHI TẮT: Ghi lại Mã Gốc của Game ---
        // Đây là bước quan trọng để quay lại như bình thường
        patch_memory(0x1D2C4A0, "\xFF\x43\x00\xD1\xF4\x4F\x01\xA9", 8); 
        
        [_hackBtn setTitle:@"HACK MAP: OFF" forState:UIControlStateNormal];
        _hackBtn.backgroundColor = [UIColor darkGrayColor]; // Màu xám
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint t = [sender translationInView:self];
    sender.view.center = CGPointMake(sender.view.center.x + t.x, sender.view.center.y + t.y);
    [sender setTranslation:CGPointZero inView:self];
}

- (void)togglePanel { _panel.hidden = !_panel.hidden; }

// Cho phép bấm xuyên qua menu vào game
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    return (hit == self) ? nil : hit;
}
@end

// Khởi tạo menu
static void ShowMenu() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        if (win && ![win viewWithTag:178]) {
            DQMenu *menu = [[DQMenu alloc] initWithFrame:win.bounds];
            [win addSubview:menu];
        } else if (!win) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ ShowMenu(); });
        }
    });
}

static __attribute__((constructor)) void init() {
    // Đợi 5 giây sau khi mở app để hiện menu
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        ShowMenu();
    });
}
