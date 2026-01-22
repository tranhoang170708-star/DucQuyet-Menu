#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>

// --- CẤU TRÌNH QUẢN LÝ BỘ NHỚ ---
uintptr_t get_BaseAddress() {
    return (uintptr_t)_dyld_get_image_header(0);
}

// Hàm ghi đè mã máy (Dùng để bật/tắt Hack)
void patch_memory(uintptr_t offset, uint32_t data) {
    uintptr_t address = get_BaseAddress() + offset;
    MSHookMemory((void *)address, &data, sizeof(data));
}

// --- KHAI BÁO BIẾN ---
static UIWindow *menuWin = nil;
static UIView *mainBox = nil;
// Thay OFFSET_MAP bằng số bạn tìm được trong file UnityFramework hoặc danh sách offset
#define OFFSET_MAP 0x1234567 

@interface DQController : UIViewController
@end

@implementation DQController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Tạo nút nổi DQ
    UIButton *dqBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    dqBtn.frame = CGRectMake(20, 150, 50, 50);
    dqBtn.backgroundColor = [UIColor orangeColor];
    dqBtn.layer.cornerRadius = 25;
    [dqBtn setTitle:@"DQ" forState:UIControlStateNormal];
    [dqBtn addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dqBtn];
    
    // Tạo bảng Menu
    mainBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 300)];
    mainBox.center = self.view.center;
    mainBox.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
    mainBox.layer.cornerRadius = 15;
    mainBox.layer.borderColor = [UIColor orangeColor].CGColor;
    mainBox.layer.borderWidth = 2;
    mainBox.hidden = YES;
    [self.view addSubview:mainBox];
    
    // Tiêu đề
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 260, 30)];
    title.text = @"DUC QUYET HACK MAP";
    title.textColor = [UIColor orangeColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:18];
    [mainBox addSubview:title];
    
    // Nút gạt HACK MAP
    UILabel *mapLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, 150, 30)];
    mapLabel.text = @"Bật Hack Map";
    mapLabel.textColor = [UIColor whiteColor];
    [mainBox addSubview:mapLabel];
    
    UISwitch *mapSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(190, 70, 0, 0)];
    [mapSwitch addTarget:self action:@selector(mapHackToggled:) forControlEvents:UIControlEventValueChanged];
    [mainBox addSubview:mapSwitch];
}

- (void)toggleMenu {
    mainBox.hidden = !mainBox.hidden;
}

// --- LOGIC HACK MAP ---
- (void)mapHackToggled:(UISwitch *)sender {
    if (sender.isOn) {
        // Mã máy 0xD65F03C0AA0103E0 thường dùng để "Return True" (Bật hack)
        patch_memory(OFFSET_MAP, 0xD65F03C0); 
        NSLog(@"[DQ] Hack Map: ON");
    } else {
        // Bạn cần lưu lại mã máy gốc để trả về nếu muốn tắt (Restore)
        // patch_memory(OFFSET_MAP, ORIGINAL_CODE);
        NSLog(@"[DQ] Hack Map: OFF (Yêu cầu reset game)");
    }
}
@end

// --- KHỞI CHẠY AN TOÀN ---
%hook UnityAppController
- (void)applicationDidBecomeActive:(UIApplication *)application {
    %orig;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            menuWin = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            menuWin.rootViewController = [[DQController alloc] init];
            menuWin.windowLevel = UIWindowLevelStatusBar + 1;
            menuWin.backgroundColor = [UIColor clearColor];
            [menuWin makeKeyAndVisible];
        });
    });
}
%end
