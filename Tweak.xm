#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>
#import <objc/runtime.h>

// --- LẤY BASE ADDRESS CHẬM (CHỈ KHI CẦN) ---
static uintptr_t _baseAddr = 0;
uintptr_t getBase() {
    if (_baseAddr == 0) _baseAddr = (uintptr_t)_dyld_get_image_header(0);
    return _baseAddr;
}

// --- HÀM PATCH KHÔNG ĐỂ LẠI DẤU VẾT ---
void silent_patch(uintptr_t offset, const char *bytes, size_t len) {
    uintptr_t addr = getBase() + offset;
    if (addr > 0x100000000) {
        MSHookMemory((void *)addr, bytes, len);
    }
}

#define OFF_MAP 0x1D2C4A0 
#define OFF_ANTEN 0x2E1A5C4

@interface DQController : UIViewController
@property (nonatomic, strong) UIView *box;
@end

@implementation DQController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Tạo một nút rất nhỏ ở góc màn hình để tránh bị phát hiện UI
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(10, 150, 40, 40);
    btn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    btn.layer.cornerRadius = 20;
    [btn setTitle:@"M" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showM) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];

    self.box = [[UIView alloc] initWithFrame:CGRectMake(0,0,220,150)];
    self.box.center = self.view.center;
    self.box.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.95];
    self.box.layer.cornerRadius = 8;
    self.box.hidden = YES;
    [self.view addSubview:self.box];

    [self addS:@"Map" y:40 s:@selector(m1:)];
    [self addS:@"Anten" y:90 s:@selector(m2:)];
}

- (void)addS:(NSString*)t y:(float)y s:(SEL)s {
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(15,y,100,30)];
    l.text = t; l.textColor = [UIColor cyanColor];
    [self.box addSubview:l];
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(150,y,0,0)];
    [sw addTarget:self action:s forControlEvents:UIControlEventValueChanged];
    [self.box addSubview:sw];
}

- (void)showM { self.box.hidden = !self.box.hidden; }
- (void)m1:(UISwitch*)s { if(s.isOn) silent_patch(OFF_MAP, "\x00\x00\x80\xD2\xC0\x03\x5F\xD6", 8); }
- (void)m2:(UISwitch*)s { if(s.isOn) silent_patch(OFF_ANTEN, "\x00\x00\xA0\x43", 4); }
@end

// --- HOOK VÀO GIAI ĐOẠN MUỘN NHẤT CỦA GAME ---
%hook UIViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    // Kiểm tra nếu là màn hình chính của game thì mới nạp Menu
    NSString *vcName = NSStringFromClass([self class]);
    if ([vcName containsString:@"Unity"] || [vcName containsString:@"UI"]) {
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                DQController *menu = [[DQController alloc] init];
                // Thêm trực tiếp vào View hiện tại của game thay vì tạo Window mới
                [self addChildViewController:menu];
                [self.view addSubview:menu.view];
                [menu didMoveToParentViewController:self];
            });
        });
    }
}
%end
