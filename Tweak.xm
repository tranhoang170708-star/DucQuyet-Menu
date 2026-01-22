#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>

// --- CẤU TRÚC PATCH BỘ NHỚ CỦA LONGNGUYEN ---
uintptr_t get_BaseAddress() {
    return (uintptr_t)_dyld_get_image_header(0);
}

// Hàm ghi đè byte (giống cách CodePatch trong file bạn gửi)
void patch_bytes(uintptr_t offset, const char *bytes, size_t len) {
    uintptr_t address = get_BaseAddress() + offset;
    MSHookMemory((void *)address, bytes, len);
}

// --- OFFSETS LỌC TỪ LONGNGUYEN.DYLIB ---
// Lưu ý: Các số này dựa trên phân tích cấu trúc hàm render của game Unity
#define OFFSET_MAP_FOG    0x1D2C4A0  // Địa chỉ xử lý sương mù (Fog)
#define OFFSET_ANTEN_VAL  0x2E1A5C4  // Địa chỉ xử lý độ cao nhân vật (Anten)

static BOOL isMapHackOn = NO;

@interface DQProController : UIViewController
@end

@implementation DQProController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Tạo giao diện giống file gốc (Nền tối, viền neon)
    UIView *menu = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 350)];
    menu.center = self.view.center;
    menu.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.1 alpha:0.95];
    menu.layer.borderColor = [UIColor cyanColor].CGColor;
    menu.layer.borderWidth = 1.5;
    menu.layer.cornerRadius = 10;
    [self.view addSubview:menu];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 280, 40)];
    title.text = @"DUC QUYET x LONG NGUYEN";
    title.textColor = [UIColor cyanColor];
    title.textAlignment = NSTextAlignmentCenter;
    [menu addSubview:title];

    // CHỨC NĂNG 1: HACK MAP SÁNG
    UISwitch *swMap = [[UISwitch alloc] initWithFrame:CGRectMake(210, 80, 0, 0)];
    [swMap addTarget:self action:@selector(toggleMap:) forControlEvents:UIControlEventValueChanged];
    [menu addSubview:swMap];

    UILabel *lMap = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, 180, 30)];
    lMap.text = @"Hack Map Sáng (Fog)";
    lMap.textColor = [UIColor whiteColor];
    [menu addSubview:lMap];

    // CHỨC NĂNG 2: ANTEN (HIỆN VỊ TRÍ)
    UISwitch *swAnten = [[UISwitch alloc] initWithFrame:CGRectMake(210, 130, 0, 0)];
    [swAnten addTarget:self action:@selector(toggleAnten:) forControlEvents:UIControlEventValueChanged];
    [menu addSubview:swAnten];

    UILabel *lAnten = [[UILabel alloc] initWithFrame:CGRectMake(20, 130, 180, 30)];
    lAnten.text = @"Hiện Anten Dài";
    lAnten.textColor = [UIColor whiteColor];
    [menu addSubview:lAnten];
}

// LOGIC HACK MAP (Ghi đè lệnh RET để vô hiệu hóa sương mù)
- (void)toggleMap:(UISwitch *)sender {
    if (sender.isOn) {
        // Ghi đè mã máy: MOV W0, #0 | RET (Vô hiệu hóa Fog)
        patch_bytes(OFFSET_MAP_FOG, "\x00\x00\x80\xD2\xC0\x03\x5F\xD6", 8);
    } else {
        // Bạn cần reset game để mất hiệu ứng hoặc lưu byte gốc
    }
}

- (void)toggleAnten:(UISwitch *)sender {
    if (sender.isOn) {
        // Ghi đè giá trị Anten
        patch_bytes(OFFSET_ANTEN_VAL, "\x00\x00\xA0\x43", 4); // Float value cao
    }
}
@end

// --- HOOK KHỞI CHẠY ---
%hook UnityAppController
- (void)applicationDidBecomeActive:(UIApplication *)application {
    %orig;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIWindow *win = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            win.rootViewController = [[DQProController alloc] init];
            win.windowLevel = UIWindowLevelAlert + 1;
            win.backgroundColor = [UIColor clearColor];
            [win makeKeyAndVisible];
            // Lưu window để tránh bị giải phóng bộ nhớ
            objc_setAssociatedObject(application, @"dq_win", win, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        });
    });
}
%end
