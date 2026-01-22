#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>
#import <objc/runtime.h>

// --- CẤU TRÚC PATCH BỘ NHỚ ---
uintptr_t get_BaseAddress() {
    return (uintptr_t)_dyld_get_image_header(0);
}

void patch_bytes(uintptr_t offset, const char *bytes, size_t len) {
    uintptr_t address = get_BaseAddress() + offset;
    MSHookMemory((void *)address, bytes, len);
}

// --- OFFSETS (Lấy từ longnguyen.dylib) ---
#define OFFSET_MAP_FOG    0x1D2C4A0
#define OFFSET_ANTEN_VAL  0x2E1A5C4

@interface DQProController : UIViewController
@property (nonatomic, strong) UIView *menuView;
@end

@implementation DQProController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Nút nổi (Floating Button) để mở Menu
    UIButton *btnOpen = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOpen.frame = CGRectMake(10, 100, 50, 50);
    btnOpen.backgroundColor = [UIColor cyanColor];
    btnOpen.layer.cornerRadius = 25;
    [btnOpen setTitle:@"DQ" forState:UIControlStateNormal];
    [btnOpen setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnOpen addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnOpen];

    // Khung Menu chính
    self.menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 250)];
    self.menuView.center = self.view.center;
    self.menuView.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.1 alpha:0.95];
    self.menuView.layer.borderColor = [UIColor cyanColor].CGColor;
    self.menuView.layer.borderWidth = 1.5;
    self.menuView.layer.cornerRadius = 10;
    self.menuView.hidden = YES; // Mặc định ẩn, bấm nút mới hiện
    [self.view addSubview:self.menuView];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 280, 40)];
    title.text = @"DUC QUYET x LONG NGUYEN";
    title.textColor = [UIColor cyanColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:16];
    [self.menuView addSubview:title];

    // Chức năng Hack Map
    [self createSwitchWithLabel:@"Hack Map Sáng" y:70 action:@selector(toggleMap:) inView:self.menuView];
    
    // Chức năng Anten
    [self createSwitchWithLabel:@"Hiện Anten Dài" y:120 action:@selector(toggleAnten:) inView:self.menuView];
}

- (void)toggleMenu {
    self.menuView.hidden = !self.menuView.hidden;
}

- (void)createSwitchWithLabel:(NSString *)text y:(CGFloat)y action:(SEL)action inView:(UIView *)view {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 180, 30)];
    lbl.text = text;
    lbl.textColor = [UIColor whiteColor];
    [view addSubview:lbl];

    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(210, y, 0, 0)];
    sw.onTintColor = [UIColor cyanColor];
    [sw addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [view addSubview:sw];
}

- (void)toggleMap:(UISwitch *)sender {
    if (sender.isOn) {
        patch_bytes(OFFSET_MAP_FOG, "\x00\x00\x80\xD2\xC0\x03\x5F\xD6", 8);
    }
}

- (void)toggleAnten:(UISwitch *)sender {
    if (sender.isOn) {
        patch_bytes(OFFSET_ANTEN_VAL, "\x00\x00\xA0\x43", 4);
    }
}
@end

%hook UnityAppController
- (void)applicationDidBecomeActive:(UIApplication *)application {
    %orig;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIWindow *win = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            win.rootViewController = [[DQProController alloc] init];
            win.windowLevel = UIWindowLevelAlert + 1;
            win.backgroundColor = [UIColor clearColor];
            [win makeKeyAndVisible];
            
            static char dq_window_key;
            objc_setAssociatedObject(application, &dq_window_key, win, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        });
    });
}
%end
