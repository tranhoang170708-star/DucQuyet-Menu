#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>

// Khai báo biến trạng thái toàn cục
static BOOL isHackMapEnabled = NO;

// --- Kỹ thuật Hook hàm kiểm tra tầm nhìn ---
// Giả sử hàm IsVisible(obj) ở địa chỉ 0x1D2C4A0
// Chúng ta sẽ "đánh tráo" hàm này của game
BOOL (*old_IsVisible)(void *instance);
BOOL new_IsVisible(void *instance) {
    if (isHackMapEnabled) {
        return YES; // Nếu Bật: Luôn thấy địch
    }
    return old_IsVisible(instance); // Nếu Tắt: Trả về logic gốc của game
}

@interface DQMenu : UIView
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) UIView *box;
@end

@implementation DQMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.tag = 178;
        self.layer.zPosition = 9999;

        // Nút tròn DQ (Kéo thả được)
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn.frame = CGRectMake(60, 160, 55, 55);
        _btn.backgroundColor = [UIColor colorWithRed:0 green:0.5 blue:1 alpha:0.8];
        _btn.layer.cornerRadius = 27.5;
        [_btn setTitle:@"DQ" forState:UIControlStateNormal];
        _btn.layer.borderWidth = 1.5;
        _btn.layer.borderColor = [UIColor whiteColor].CGColor;
        [_btn addTarget:self action:@selector(open) forControlEvents:UIControlEventTouchUpInside];
        
        UIPanGestureRecognizer *p = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drag:)];
        [_btn addGestureRecognizer:p];
        [self addSubview:_btn];

        // Bảng Menu
        _box = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 220, 150)];
        _box.center = self.center;
        _box.backgroundColor = [UIColor colorWithWhite:0 alpha:0.95];
        _box.layer.cornerRadius = 12;
        _box.layer.borderColor = [UIColor cyanColor].CGColor;
        _box.layer.borderWidth = 1;
        _box.hidden = YES;
        [self addSubview:_box];

        UIButton *sw = [UIButton buttonWithType:UIButtonTypeCustom];
        sw.frame = CGRectMake(20, 50, 180, 45);
        sw.backgroundColor = [UIColor darkGrayColor];
        sw.layer.cornerRadius = 8;
        [sw setTitle:@"HACK MAP: OFF" forState:UIControlStateNormal];
        [sw addTarget:self action:@selector(toggleHack:) forControlEvents:UIControlEventTouchUpInside];
        [_box addSubview:sw];
        
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 220, 30)];
        l.text = @"DUC QUYET MENU";
        l.textColor = [UIColor cyanColor];
        l.textAlignment = NSTextAlignmentCenter;
        [_box addSubview:l];
    }
    return self;
}

- (void)toggleHack:(UIButton *)s {
    isHackMapEnabled = !isHackMapEnabled;
    if (isHackMapEnabled) {
        [s setTitle:@"HACK MAP: ON" forState:UIControlStateNormal];
        s.backgroundColor = [UIColor colorWithRed:0 green:0.6 blue:0.2 alpha:1];
    } else {
        [s setTitle:@"HACK MAP: OFF" forState:UIControlStateNormal];
        s.backgroundColor = [UIColor darkGrayColor];
    }
}

- (void)drag:(UIPanGestureRecognizer *)g {
    CGPoint t = [g translationInView:self];
    g.view.center = CGPointMake(g.view.center.x + t.x, g.view.center.y + t.y);
    [g setTranslation:CGPointZero inView:self];
}

- (void)open { _box.hidden = !_box.hidden; }

- (UIView *)hitTest:(CGPoint)p withEvent:(UIEvent *)e {
    UIView *v = [super hitTest:p withEvent:e];
    return (v == self) ? nil : v;
}
@end

// --- Khởi tạo và nạp Hook ---
#import <substrate.h> // Thư viện để dùng MSHookFunction

static __attribute__((constructor)) void setup() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 6 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIWindow *w = [UIApplication sharedApplication].keyWindow;
        if (w && ![w viewWithTag:178]) {
            DQMenu *m = [[DQMenu alloc] initWithFrame:w.bounds];
            [w addSubview:m];
        }
        
        // Thực hiện Hook hàm của game
        // Thay 0x1D2C4A0 bằng Offset chuẩn của phiên bản bạn đang dùng
        uintptr_t target = (uintptr_t)_dyld_get_image_header(0) + 0x1D2C4A0;
        MSHookFunction((void *)target, (void *)new_IsVisible, (void **)&old_IsVisible);
    });
}
