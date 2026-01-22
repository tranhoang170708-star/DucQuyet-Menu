#import <UIKit/UIKit.h>

@interface DQMenuWindow : UIWindow
@end

@implementation DQMenuWindow
// Đảm bảo cửa sổ menu không chặn tương tác của game khi menu đang ẩn
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) return nil;
    return hitView;
}
@end

static DQMenuWindow *window = nil;
static UIButton *btn = nil;
static UIView *mainMenu = nil;

// Hàm khởi tạo Menu tách biệt hoàn toàn
void InitializeSafeMenu() {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 1. Tạo Window riêng ở lớp cao nhất
        window = [[DQMenuWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.windowLevel = UIWindowLevelStatusBar + 100.0;
        window.backgroundColor = [UIColor clearColor];
        [window setHidden:NO];
        [window makeKeyAndVisible];

        // 2. Nút bấm nổi (Floating Button)
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(50, 150, 50, 50);
        btn.layer.cornerRadius = 25;
        btn.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.7]; // Màu đỏ trong suốt
        [btn setTitle:@"DQ" forState:UIControlStateNormal];
        
        // Kéo thả nút bấm
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:btn action:@selector(handlePan:)];
        [btn addGestureRecognizer:pan];
        
        // Thêm sự kiện click
        [btn addTarget:window action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
        
        [window addSubview:btn];

        // 3. Giao diện Menu chính
        mainMenu = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 350)];
        mainMenu.center = window.center;
        mainMenu.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
        mainMenu.layer.cornerRadius = 20;
        mainMenu.layer.borderWidth = 2;
        mainMenu.layer.borderColor = [UIColor cyanColor].CGColor;
        mainMenu.hidden = YES;
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 280, 40)];
        title.text = @"DUC QUYET UNITY MOD";
        title.textColor = [UIColor cyanColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont boldSystemFontOfSize:18];
        [mainMenu addSubview:title];
        
        [window addSubview:mainMenu];
    });
}

// Thêm hàm xử lý kéo thả cho Button
@implementation UIButton (Mouse)
- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.superview];
    self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
    [pan setTranslation:CGPointZero inView:self.superview];
}
@end

// Thêm hàm ẩn/hiện cho Window
@implementation UIWindow (Toggle)
- (void)toggleMenu {
    mainMenu.hidden = !mainMenu.hidden;
}
@end

// --- KHỞI CHẠY ---
%ctor {
    // Đợi 10 giây để Unity khởi tạo xong hoàn toàn bộ nhớ và đồ họa
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        InitializeSafeMenu();
    });
}
