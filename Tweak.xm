#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// Sử dụng biến tĩnh để đảm bảo không bị khởi tạo chồng chéo
static UIWindow *menuWindow = nil;
static BOOL isMenuVisible = NO;

@interface DucQuyetMenuController : UIViewController
@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, strong) UIView *menuView;
@end

@implementation DucQuyetMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self setupToggleButton];
    [self setupMenu];
}

- (void)setupToggleButton {
    self.toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.toggleButton.frame = CGRectMake(20, 100, 60, 60);
    self.toggleButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.8 alpha:0.8];
    self.toggleButton.layer.cornerRadius = 30;
    [self.toggleButton setTitle:@"DQ" forState:UIControlStateNormal];
    [self.toggleButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    
    // Cho phép kéo nút Menu để không vướng màn hình
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.toggleButton addGestureRecognizer:pan];
    
    [self.view addSubview:self.toggleButton];
}

- (void)setupMenu {
    self.menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 300)];
    self.menuView.center = self.view.center;
    self.menuView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.9];
    self.menuView.layer.cornerRadius = 15;
    self.menuView.hidden = YES;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 250, 30)];
    title.text = @"DUC QUYET MENU";
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    [self.menuView addSubview:title];
    
    [self.view addSubview:self.menuView];
}

- (void)toggleMenu {
    isMenuVisible = !isMenuVisible;
    self.menuView.hidden = !isMenuVisible;
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.view];
    pan.view.center = CGPointMake(pan.view.center.x + translation.x, pan.view.center.y + translation.y);
    [pan setTranslation:CGPointZero inView:self.view];
}

@end

// Hook vào bước khởi tạo ứng dụng để tạo Overlay
%hook UnityAppController // Hoặc dùng UnityAppController nếu là game Unity
- (void)applicationDidBecomeActive:(UIApplication *)application {
    %orig;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Chờ 3 giây sau khi game active để tránh crash lúc đang load splash screen
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!menuWindow) {
                UIWindowScene *scene = (UIWindowScene *)[[[UIApplication sharedApplication] connectedScenes] anyObject];
                if (scene) {
                    menuWindow = [[UIWindow alloc] initWithWindowScene:scene];
                } else {
                    menuWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                }
                
                menuWindow.rootViewController = [[DucQuyetMenuController alloc] init];
                menuWindow.windowLevel = UIWindowLevelAlert + 1;
                menuWindow.backgroundColor = [UIColor clearColor];
                [menuWindow makeKeyAndVisible];
                menuWindow.userInteractionEnabled = YES;
            }
        });
    });
}
%end
