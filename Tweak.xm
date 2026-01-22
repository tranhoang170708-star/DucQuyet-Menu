#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>
#import <objc/runtime.h>

// --- HÀM PATCH BYTE AN TOÀN ---
void apply_patch(uintptr_t offset, const char *bytes, size_t len) {
    uintptr_t base = (uintptr_t)_dyld_get_image_header(0);
    if (base == 0) return;
    uintptr_t address = base + offset;
    MSHookMemory((void *)address, bytes, len);
}

#define OFF_MAP 0x1D2C4A0 
#define OFF_ANTEN 0x2E1A5C4

@interface DQMenu : UIView
@property (nonatomic, strong) UIView *panel;
@end

@implementation DQMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20, 100, 45, 45);
        btn.backgroundColor = [UIColor cyanColor];
        btn.layer.cornerRadius = 22.5;
        [btn setTitle:@"DQ" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];

        self.panel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 220, 160)];
        self.panel.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        self.panel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
        self.panel.layer.cornerRadius = 10;
        self.panel.layer.borderWidth = 1;
        self.panel.layer.borderColor = [UIColor cyanColor].CGColor;
        self.panel.hidden = YES;
        [self addSubview:self.panel];

        [self addS:@"Map Sáng" y:30 a:@selector(s1:)];
        [self addS:@"Anten Cao" y:85 a:@selector(s2:)];
    }
    return self;
}

- (void)addS:(NSString*)t y:(float)y a:(SEL)a {
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 100, 30)];
    l.text = t; l.textColor = [UIColor whiteColor];
    [self.panel addSubview:l];
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(150, y, 0, 0)];
    [sw addTarget:self action:a forControlEvents:UIControlEventValueChanged];
    [self.panel addSubview:sw];
}

- (void)toggle { self.panel.hidden = !self.panel.hidden; }
- (void)s1:(UISwitch*)s { if(s.isOn) apply_patch(OFF_MAP, "\x00\x00\x80\xD2\xC0\x03\x5F\xD6", 8); }
- (void)s2:(UISwitch*)s { if(s.isOn) apply_patch(OFF_ANTEN, "\x00\x00\xA0\x43", 4); }

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) return nil;
    return hitView;
}
@end

// --- KHỞI TẠO (VƯỢT LOGO & FIX DEPRECATED) ---
static __attribute__((constructor)) void dq_entry() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIWindow *mainWin = nil;
        // Cách lấy Window chuẩn cho iOS 13 trở lên (Thay thế cho keyWindow)
        if (@available(iOS 13.0, *)) {
            NSSet *scenes = [[UIApplication sharedApplication] connectedScenes];
            for (UIScene *scene in scenes) {
                if ([scene isKindOfClass:[UIWindowScene class]] && scene.activationState == UISceneActivationStateForegroundActive) {
                    mainWin = [(UIWindowScene *)scene windows].firstObject;
                    break;
                }
            }
        }
        
        // Nếu không lấy được theo Scene (iOS cũ), lấy theo windows[0]
        if (!mainWin) {
            mainWin = [[UIApplication sharedApplication] windows].firstObject;
        }
        
        if (mainWin) {
            DQMenu *menu = [[DQMenu alloc] initWithFrame:mainWin.bounds];
            [mainWin addSubview:menu];
            NSLog(@"[DQ] Menu Loaded Successfully!");
        }
    });
}
