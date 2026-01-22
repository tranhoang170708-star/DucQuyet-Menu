#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>
#import <objc/runtime.h>

// --- HÀM LẤY ĐỊA CHỈ GỐC AN TOÀN ---
uintptr_t get_BaseAddress() {
    // 0 thường là địa chỉ của chính app, nhưng với game Unity 
    // đôi khi cần tìm đúng image "UnityFramework"
    return (uintptr_t)_dyld_get_image_header(0);
}

// Hàm Patch tránh crash bằng cách kiểm tra địa chỉ hợp lệ
void safe_patch(uintptr_t offset, const char *bytes, size_t len) {
    uintptr_t address = get_BaseAddress() + offset;
    if (address > 0x100000000) { // Kiểm tra địa chỉ ARM64 hợp lệ
        MSHookMemory((void *)address, bytes, len);
    }
}

// --- OFFSETS (Cần kiểm tra lại nếu vẫn crash) ---
// Nếu game update, 2 số này SAI sẽ gây crash 100%
#define OFFSET_MAP_FOG    0x1D2C4A0 
#define OFFSET_ANTEN_VAL  0x2E1A5C4

@interface DQProController : UIViewController
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIButton *btnOpen;
@end

@implementation DQProController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Nút mở Menu nhỏ gọn, có thể kéo được (nếu thêm code)
    self.btnOpen = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnOpen.frame = CGRectMake(20, 150, 45, 45);
    self.btnOpen.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.7];
    self.btnOpen.layer.cornerRadius = 22.5;
    self.btnOpen.layer.borderWidth = 1;
    self.btnOpen.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.btnOpen setTitle:@"DQ" forState:UIControlStateNormal];
    [self.btnOpen addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnOpen];

    // Menu chính
    self.menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 200)];
    self.menuView.center = self.view.center;
    self.menuView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.1 alpha:0.9];
    self.menuView.layer.cornerRadius = 12;
    self.menuView.layer.borderWidth = 2;
    self.menuView.layer.borderColor = [UIColor cyanColor].CGColor;
    self.menuView.hidden = YES;
    [self.view addSubview:self.menuView];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 260, 30)];
    title.text = @"DUC QUYET MOD";
    title.textColor = [UIColor cyanColor];
    title.textAlignment = NSTextAlignmentCenter;
    [self.menuView addSubview:title];

    [self addHackItem:@"Bản Đồ Sáng" y:60 action:@selector(mapSwitch:)];
    [self addHackItem:@"Anten Cao" y:110 action:@selector(antenSwitch:)];
}

- (void)addHackItem:(NSString *)name y:(CGFloat)y action:(SEL)sel {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 150, 30)];
    lbl.text = name;
    lbl.textColor = [UIColor whiteColor];
    [self.menuView addSubview:lbl];

    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(190, y, 0, 0)];
    [sw addTarget:self action:sel forControlEvents:UIControlEventValueChanged];
    [self.menuView addSubview:sw];
}

- (void)toggleMenu {
    self.menuView.hidden = !self.menuView.hidden;
}

// Xử lý bật tắt - Dùng dispatch_async để tránh treo luồng UI
- (void)mapSwitch:(UISwitch *)sw {
    if (sw.isOn) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            safe_patch(OFFSET_MAP_FOG, "\x00\x00\x80\xD2\xC0\x03\x5F\xD6", 8);
        });
    }
}

- (void)antenSwitch:(UISwitch *)sw {
    if (sw.isOn) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            safe_patch(OFFSET_ANTEN_VAL, "\x00\x00\xA0\x43", 4);
        });
    }
}
@end

// --- HOOK VÀO GAME ---
%hook UnityAppController
- (void)applicationDidBecomeActive:(UIApplication *)application {
    %orig;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        // Tăng delay lên 10 giây để Unity load xong hết Assets
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
            if (!keyWindow) keyWindow = [[UIApplication sharedApplication] windows].firstObject;

            DQProController *vc = [[DQProController alloc] init];
            UIWindow *hackWin = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            hackWin.rootViewController = vc;
            hackWin.windowLevel = UIWindowLevelAlert + 1;
            hackWin.backgroundColor = [UIColor clearColor];
            hackWin.userInteractionEnabled = YES;
            [hackWin makeKeyAndVisible];

            static char winKey;
            objc_setAssociatedObject(application, &winKey, hackWin, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        });
    });
}
%end
