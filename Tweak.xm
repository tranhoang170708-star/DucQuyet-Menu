#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// Giao diện Menu đẹp hơn
@interface DQMenu : UIView
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIView *container;
@end

@implementation DQMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.tag = 178;
        self.layer.zPosition = 1000000;

        // 1. Nút Menu tròn, hiệu ứng Gradient màu mè
        _menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _menuButton.frame = CGRectMake(50, 150, 60, 60);
        _menuButton.backgroundColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:0.9];
        _menuButton.layer.cornerRadius = 30;
        _menuButton.layer.borderWidth = 2;
        _menuButton.layer.borderColor = [UIColor cyanColor].CGColor;
        [_menuButton setTitle:@"DQ" forState:UIControlStateNormal];
        [_menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _menuButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        
        // Thêm bóng đổ cho đẹp
        _menuButton.layer.shadowColor = [UIColor cyanColor].CGColor;
        _menuButton.layer.shadowOffset = CGSizeMake(0, 0);
        _menuButton.layer.shadowOpacity = 0.8;
        _menuButton.layer.shadowRadius = 10;

        [_menuButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
        
        // Thêm cử chỉ kéo thả (Pan Gesture) để di chuyển nút menu
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [_menuButton addGestureRecognizer:pan];
        
        [self addSubview:_menuButton];

        // 2. Khung chức năng (Panel) màu tối neon
        _container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 220)];
        _container.center = self.center;
        _container.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.1 alpha:0.95];
        _container.layer.cornerRadius = 20;
        _container.layer.borderWidth = 1.5;
        _container.layer.borderColor = [UIColor cyanColor].CGColor;
        _container.hidden = YES;
        [self addSubview:_container];

        // Tiêu đề màu mè
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 280, 40)];
        title.text = @"⭐ DUC QUYET VIP ⭐";
        title.textColor = [UIColor cyanColor];
        title.font = [UIFont boldSystemFontOfSize:20];
        title.textAlignment = NSTextAlignmentCenter;
        [_container addSubview:title];

        // Các nút chức năng
        [self addButton:@"BẬT HACK MAP" y:60 action:@selector(hackMap)];
        [self addButton:@"BẬT ANTEN" y:110 action:@selector(anten)];
        [self addButton:@"ĐÓNG MENU" y:160 action:@selector(toggleMenu)];
    }
    return self;
}

// Hàm thêm nút chức năng đẹp
- (void)addButton:(NSString *)title y:(CGFloat)y action:(SEL)sel {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, y, 240, 40);
    btn.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:1.0];
    btn.layer.cornerRadius = 10;
    btn.layer.borderWidth = 0.5;
    btn.layer.borderColor = [UIColor whiteColor].CGColor;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    [_container addSubview:btn];
}

// Xử lý di chuyển nút Menu
- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self];
    sender.view.center = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y + translation.y);
    [sender setTranslation:CGPointZero inView:self];
}

- (void)toggleMenu { _container.hidden = !_container.hidden; }

// Chức năng mẫu (Bạn thay offset vào đây)
- (void)hackMap { printf("Hack Map Activated\n"); }
- (void)anten { printf("Anten Activated\n"); }

// QUAN TRỌNG NHẤT: Sửa lỗi không bấm được game
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    // Nếu chạm vào vùng trống (không phải nút, không phải khung menu) thì trả về nil để game nhận cảm ứng
    if (hitView == self) return nil;
    return hitView;
}
@end

// Khởi tạo nạp Menu
static void FastLoad() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        if (win) {
            if (![win viewWithTag:178]) {
                DQMenu *menu = [[DQMenu alloc] initWithFrame:win.bounds];
                [win addSubview:menu];
            }
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                FastLoad();
            });
        }
    });
}

static __attribute__((constructor)) void init() {
    // Đợi 4 giây sau logo rồi hiện
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        FastLoad();
    });
}
