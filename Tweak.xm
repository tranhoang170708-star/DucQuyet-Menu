#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>

// Hàm ghi đè bộ nhớ sử dụng MS (Chỉ chạy khi bấm nút)
void patch_bytes(uintptr_t offset, const char *bytes, size_t len) {
    uintptr_t base = (uintptr_t)_dyld_get_image_header(0);
    if (base != 0) {
        MSHookMemory((void *)(base + offset), bytes, len);
    }
}

// --- OFFSETS (Kiểm tra lại xem game có cập nhật không) ---
#define ADDR_MAP    0x1D2C4A0 
#define ADDR_ANTEN  0x2E1A5C4

@interface DQMenu : UIView
@property (nonatomic, strong) UIView *bg;
@end

@implementation DQMenu
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Nút tròn nhỏ mở menu
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(10, 120, 40, 40);
        btn.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.7];
        btn.layer.cornerRadius = 20;
        [btn setTitle:@"DQ" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];

        // Khung menu
        self.bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 140)];
        self.bg.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        self.bg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
        self.bg.layer.cornerRadius = 10;
        self.bg.hidden = YES;
        [self addSubview:self.bg];

        [self addS:@"Hack Map" y:30 a:@selector(s1:)];
        [self addS:@"Anten" y:80 a:@selector(s2:)];
    }
    return self;
}

- (void)addS:(NSString*)t y:(float)y a:(SEL)a {
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 100, 30)];
    l.text = t; l.textColor = [UIColor whiteColor];
    [self.bg addSubview:l];
    UISwitch *s = [[UISwitch alloc] initWithFrame:CGRectMake(130, y, 0, 0)];
    [s addTarget:self action:a forControlEvents:UIControlEventValueChanged];
    [self.bg addSubview:s];
}

- (void)toggle { self.bg.hidden = !self.bg.hidden; }
- (void)s1:(UISwitch*)s { if(s.isOn) patch_bytes(ADDR_MAP, "\x00\x00\x80\xD2\xC0\x03\x5F\xD6", 8); }
- (void)s2:(UISwitch*)s { if(s.isOn) patch_bytes(ADDR_ANTEN, "\x00\x00\xA0\x43", 4); }

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    return (hitView == self) ? nil : hitView;
}
@end

// Constructor nạp Menu sau 30 giây - TUYỆT ĐỐI KHÔNG DÙNG %HOOK
static __attribute__((constructor)) void start_dq_service() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *targetWin = nil;
        if (@available(iOS 13.0, *)) {
            for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if ([scene isKindOfClass:[UIWindowScene class]] && scene.activationState == UISceneActivationStateForegroundActive) {
                    targetWin = ((UIWindowScene *)scene).windows.firstObject;
                    break;
                }
            }
        }
        if (!targetWin) targetWin = [UIApplication sharedApplication].windows.firstObject;

        if (targetWin) {
            DQMenu *menu = [[DQMenu alloc] initWithFrame:targetWin.bounds];
            [targetWin addSubview:menu];
        }
    });
}
