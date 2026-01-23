#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>

// Hàm ghi bộ nhớ chuẩn
void patch_memory(uintptr_t offset, const char *data, size_t size) {
    uintptr_t address = (uintptr_t)_dyld_get_image_header(0) + offset;
    mach_port_t task = mach_task_self();
    if (vm_protect(task, (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY) == KERN_SUCCESS) {
        memcpy((void *)address, data, size);
        vm_protect(task, (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
    }
}

@interface DQMenu : UIView
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) UIView *box;
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

        // Nút tròn DQ
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn.frame = CGRectMake(60, 160, 55, 55);
        _btn.backgroundColor = [UIColor colorWithRed:0.0 green:0.6 blue:1.0 alpha:0.8];
        _btn.layer.cornerRadius = 27.5;
        [_btn setTitle:@"DQ" forState:UIControlStateNormal];
        [_btn addTarget:self action:@selector(toggleBox) forControlEvents:UIControlEventTouchUpInside];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
        [_btn addGestureRecognizer:pan];
        [self addSubview:_btn];

        // Bảng điều khiển
        _box = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 150)];
        _box.center = self.center;
        _box.backgroundColor = [UIColor colorWithWhite:0 alpha:0.95];
        _box.layer.cornerRadius = 15;
        _box.layer.borderWidth = 1.5;
        _box.layer.borderColor = [UIColor cyanColor].CGColor;
        _box.hidden = YES;
        [self addSubview:_box];

        UIButton *sw = [UIButton buttonWithType:UIButtonTypeCustom];
        sw.frame = CGRectMake(20, 55, 200, 45);
        sw.backgroundColor = [UIColor darkGrayColor];
        sw.layer.cornerRadius = 10;
        [sw setTitle:@"HACK MAP: OFF" forState:UIControlStateNormal];
        [sw addTarget:self action:@selector(switchMap:) forControlEvents:UIControlEventTouchUpInside];
        [_box addSubview:sw];
    }
    return self;
}

- (void)switchMap:(UIButton *)sender {
    _isHackActive = !_isHackActive;
    
    // ĐỊA CHỈ OFFSET (Bạn hãy thay đúng offset của bản bạn đang dùng)
    uintptr_t mapOffset = 0x1D2C4A0; 

    if (_isHackActive) {
        // --- BẬT: Ghi mã Hack ---
        patch_memory(mapOffset, "\x00\x00\x80\xD2\xC0\x03\x5F\xD6", 8);
        [sender setTitle:@"HACK MAP: ON" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor colorWithRed:0 green:0.6 blue:0.1 alpha:1];
    } else {
        // --- TẮT: Ghi lại đúng mã gốc (PHẢI CHUẨN) ---
        // Lưu ý: Nếu mã gốc này sai, nó sẽ không ẩn được địch
        patch_memory(mapOffset, "\xFF\x43\x00\xD1\xF4\x4F\x01\xA9", 8); 
        [sender setTitle:@"HACK MAP: OFF" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor darkGrayColor];
    }
}

- (void)handleDrag:(UIPanGestureRecognizer *)g {
    CGPoint t = [g translationInView:self];
    g.view.center = CGPointMake(g.view.center.x + t.x, g.view.center.y + t.y);
    [g setTranslation:CGPointZero inView:self];
}

- (void)toggleBox { _box.hidden = !_box.hidden; }

- (UIView *)hitTest:(CGPoint)p withEvent:(UIEvent *)e {
    UIView *v = [super hitTest:p withEvent:e];
    return (v == self) ? nil : v;
}
@end

static void StartMenu() {
    UIWindow *win = [UIApplication sharedApplication].keyWindow;
    if (win && ![win viewWithTag:178]) {
        DQMenu *m = [[DQMenu alloc] initWithFrame:win.bounds];
        [win addSubview:m];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            StartMenu();
        });
    }
}

static __attribute__((constructor)) void init() {
    // Đợi 6 giây để qua logo hoàn toàn rồi mới hiện menu
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 6 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        StartMenu();
    });
}
