#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>

// Hàm ghi bộ nhớ nâng cao
void safe_patch(uintptr_t offset, const char *data, size_t size) {
    uintptr_t address = (uintptr_t)_dyld_get_image_header(0) + offset;
    mach_port_t task = mach_task_self();
    
    // Cấp quyền ghi
    if (vm_protect(task, (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY) == KERN_SUCCESS) {
        memcpy((void *)address, data, size);
        // Trả lại quyền thực thi ban đầu
        vm_protect(task, (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
    }
}

@interface DQMenu : UIView
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIView *panel;
@property (nonatomic, strong) UIButton *hackBtn;
@end

@implementation DQMenu {
    BOOL _isHackActive;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.tag = 178;
        self.layer.zPosition = 1000000;

        // Nút DQ tròn
        _menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _menuButton.frame = CGRectMake(50, 150, 60, 60);
        _menuButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.8 blue:1.0 alpha:0.8];
        _menuButton.layer.cornerRadius = 30;
        _menuButton.layer.borderWidth = 2;
        _menuButton.layer.borderColor = [UIColor whiteColor].CGColor;
        [_menuButton setTitle:@"DQ" forState:UIControlStateNormal];
        [_menuButton addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [_menuButton addGestureRecognizer:pan];
        [self addSubview:_menuButton];

        // Bảng điều khiển
        _panel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 180)];
        _panel.center = self.center;
        _panel.backgroundColor = [UIColor blackColor];
        _panel.layer.cornerRadius = 15;
        _panel.layer.borderColor = [UIColor cyanColor].CGColor;
        _panel.layer.borderWidth = 2;
        _panel.hidden = YES;
        [self addSubview:_panel];

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 240, 30)];
        title.text = @"HACK MAP VIP";
        title.textColor = [UIColor cyanColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont boldSystemFontOfSize:18];
        [_panel addSubview:title];

        // Nút Bật/Tắt
        _hackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _hackBtn.frame = CGRectMake(20, 70, 200, 50);
        _hackBtn.backgroundColor = [UIColor grayColor];
        _hackBtn.layer.cornerRadius = 10;
        [_hackBtn setTitle:@"HACK MAP: OFF" forState:UIControlStateNormal];
        [_hackBtn addTarget:self action:@selector(handleHack) forControlEvents:UIControlEventTouchUpInside];
        [_panel addSubview:_hackBtn];
    }
    return self;
}

- (void)handleHack {
    _isHackActive = !_isHackActive;
    
    // OFFSET VÀ BYTES (Cần khớp với phiên bản game bạn đang dùng)
    uintptr_t hackOffset = 0x1D2C4A0; 
    
    if (_isHackActive) {
        // MÃ HACK: Thường là lệnh Return (MOV W0, #1; RET)
        safe_patch(hackOffset, "\x20\x00\x80\xD2\xC0\x03\x5F\xD6", 8);
        
        [_hackBtn setTitle:@"HACK MAP: ON" forState:UIControlStateNormal];
        _hackBtn.backgroundColor = [UIColor greenColor];
    } else {
        // MÃ GỐC: Bạn PHẢI lấy mã gốc chính xác từ IDA Pro của phiên bản game này
        // Nếu mã gốc này sai, game sẽ không tắt hack hoặc bị văng.
        // Dưới đây là ví dụ mã gốc phổ biến (thay đổi tùy bản update)
        safe_patch(hackOffset, "\xFF\x43\x00\xD1\xF4\x4F\x01\xA9", 8); 
        
        [_hackBtn setTitle:@"HACK MAP: OFF" forState:UIControlStateNormal];
        _hackBtn.backgroundColor = [UIColor grayColor];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint t = [sender translationInView:self];
    sender.view.center = CGPointMake(sender.view.center.x + t.x, sender.view.center.y + t.y);
    [sender setTranslation:CGPointZero inView:self];
}

- (void)togglePanel { _panel.hidden = !_panel.hidden; }

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    return (hit == self) ? nil : hit;
}
@end

static void LoadDQ() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        if (win && ![win viewWithTag:178]) {
            DQMenu *menu = [[DQMenu alloc] initWithFrame:win.bounds];
            [win addSubview:menu];
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ LoadDQ(); });
        }
    });
}

static __attribute__((constructor)) void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 6 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        LoadDQ();
    });
}
