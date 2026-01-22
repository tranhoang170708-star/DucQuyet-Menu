#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>
#import <objc/runtime.h>

// --- PATCH AN TOÀN ---
uintptr_t get_BaseAddress() {
    return (uintptr_t)_dyld_get_image_header(0);
}

void safe_patch(uintptr_t offset, const char *bytes, size_t len) {
    uintptr_t address = get_BaseAddress() + offset;
    // Chỉ patch nếu địa chỉ có vẻ hợp lệ để tránh crash ngay lập tức
    if (address > 0x1000000) {
        MSHookMemory((void *)address, bytes, len);
    }
}

// --- OFFSETS ---
#define OFFSET_MAP_FOG    0x1D2C4A0 
#define OFFSET_ANTEN_VAL  0x2E1A5C4

@interface DQProController : UIViewController
@property (nonatomic, strong) UIView *menuView;
@end

@implementation DQProController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Nút nổi mở menu
    UIButton *btnOpen = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOpen.frame = CGRectMake(30, 150, 50, 50);
    btnOpen.backgroundColor = [UIColor cyanColor];
    btnOpen.layer.cornerRadius = 25;
    [btnOpen setTitle:@"DQ" forState:UIControlStateNormal];
    [btnOpen setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnOpen addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnOpen];

    // Khung Menu
    self.menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 220)];
    self.menuView.center = self.view.center;
    self.menuView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0.1 alpha:0.9];
    self.menuView.layer.cornerRadius = 15;
    self.menuView.layer.borderWidth = 1.5;
    self.menuView.layer.borderColor = [UIColor cyanColor].CGColor;
    self.menuView.hidden = YES;
    [self.view addSubview:self.menuView];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 260, 40)];
    title.text = @"DUC QUYET x UNITY";
    title.textColor = [UIColor cyanColor];
    title.textAlignment = NSTextAlignmentCenter;
    [self.menuView addSubview:title];

    [self addSwitch:@"Hack Map Sáng" y:70 action:@selector(toggleMap:)];
    [self addSwitch:@"Anten Cao" y:130 action:@selector(toggleAnten:)];
}

- (void)addSwitch:(NSString *)text y:(CGFloat)y action:(SEL)sel {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 150, 30)];
    lbl.text = text;
    lbl.textColor = [UIColor whiteColor];
    [self.menuView addSubview:lbl];

    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(190, y, 0, 0)];
    [sw addTarget:self action:sel forControlEvents:UIControlEventValueChanged];
    [self.menuView addSubview:sw];
}

- (void)toggleMenu { self.menuView.hidden = !self.menuView.hidden; }

- (void)toggleMap:(UISwitch *)sender {
    if (sender.isOn) {
        safe_patch(OFFSET_MAP_FOG, "\x00\x00\x80\xD2\xC0\x03\x5F\xD6", 8);
    }
}

- (void)toggleAnten:(UISwitch *)sender {
    if (sender.isOn) {
        safe_patch(OFFSET_ANTEN_VAL, "\x00\x00\xA0\x43", 4);
    }
}
@end

// --- HOOK VÀO UNITY ---
%hook UnityAppController
- (void)applicationDidBecomeActive:(UIApplication *)application {
    %orig;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        // Delay 12 giây cho an toàn nhất
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(12 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            // CÁCH LẤY WINDOW MỚI (Sửa lỗi keyWindow deprecated)
            UIWindow *win = nil;
            if (@available(iOS 13.0, *)) {
                for (UIWindowScene* scene in [UIApplication sharedApplication].connectedScenes) {
                    if (scene.activationState == UISceneActivationStateForegroundActive) {
                        win = [[UIWindow alloc] initWithWindowScene:scene];
                        break;
                    }
                }
            }
            if (!win) win = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

            win.rootViewController = [[DQProController alloc] init];
            win.windowLevel = UIWindowLevelAlert + 1;
            win.backgroundColor = [UIColor clearColor];
            [win makeKeyAndVisible];
            
            static char dq_key;
            objc_setAssociatedObject(application, &dq_key, win, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        });
    });
}
%end
