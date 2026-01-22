#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>

// Hàm Patch an toàn, chỉ chạy khi người dùng tác động vào Menu
static void safe_patch(uintptr_t offset, const char *bytes, size_t len) {
    uintptr_t base = (uintptr_t)_dyld_get_image_header(0);
    if (base > 0x100000000) { // Đảm bảo địa chỉ hợp lệ cho arm64
        MSHookMemory((void *)(base + offset), bytes, len);
    }
}

#define OFFSET_MAP    0x1D2C4A0 
#define OFFSET_ANTEN  0x2E1A5C4

@interface DQProMenu : UIView
@property (nonatomic, strong) UIView *container;
@end

@implementation DQProMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        
        // Nút mở Menu (Thiết kế đơn giản để không lỗi Render)
        UIButton *toggleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        toggleBtn.frame = CGRectMake(20, 150, 45, 45);
        toggleBtn.backgroundColor = [UIColor colorWithRed:0 green:0.8 blue:1 alpha:0.8];
        toggleBtn.layer.cornerRadius = 22.5;
        [toggleBtn setTitle:@"DQ" forState:UIControlStateNormal];
        [toggleBtn addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:toggleBtn];

        // Khung chức năng
        self.container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 180)];
        self.container.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        self.container.backgroundColor = [UIColor colorWithWhite:0 alpha:0.9];
        self.container.layer.cornerRadius = 12;
        self.container.layer.borderWidth = 1;
        self.container.layer.borderColor = [UIColor cyanColor].CGColor;
        self.container.hidden = YES;
        [self addSubview:self.container];

        [self addSwitch:@"Hack Map" y:40 selector:@selector(onMap:)];
        [self addSwitch:@"Anten" y:100 selector:@selector(onAnten:)];
    }
    return self;
}

- (void)addSwitch:(NSString *)title y:(CGFloat)y selector:(SEL)sel {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 120, 30)];
    lbl.text = title; lbl.textColor = [UIColor whiteColor];
    [self.container addSubview:lbl];

    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(170, y, 0, 0)];
    [sw addTarget:self action:sel forControlEvents:UIControlEventValueChanged];
    [self.container addSubview:sw];
}

- (void)toggleMenu { self.container.hidden = !self.container.hidden; }

// Thao tác Patch
- (void)onMap:(UISwitch *)s { if(s.isOn) safe_patch(OFFSET_MAP, "\x00\x00\x80\xD2\xC0\x03\x5F\xD6", 8); }
- (void)onAnten:(UISwitch *)s { if(s.isOn) safe_patch(OFFSET_ANTEN, "\x00\x00\xA0\x43", 4); }

// Cho phép bấm hxuyên qua các vùng trống để không ảnh hưởng thao tác game
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    return (view == self) ? nil : view;
}
@end

// --- CƠ CHẾ NẠP SIÊU CHẬM (ANTI-CRASH) ---
static __attribute__((constructor)) void init_stealth_mode() {
    // Đợi 35 giây (đủ để game qua logo, load xong data và vào hẳn sảnh)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *mainWin = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *scene in (NSArray *)[UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    mainWin = scene.windows.firstObject;
                    break;
                }
            }
        }
        if (!mainWin) mainWin = [UIApplication sharedApplication].windows.firstObject;

        if (mainWin) {
            DQProMenu *menu = [[DQProMenu alloc] initWithFrame:mainWin.bounds];
            [mainWin addSubview:menu];
        }
    });
}
