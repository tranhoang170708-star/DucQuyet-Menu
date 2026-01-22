#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import <objc/runtime.h>

// Hàm Patch bộ nhớ thuần (Lách soi dylib)
void aov_patch(uintptr_t off, const char *data, size_t sz) {
    uintptr_t addr = (uintptr_t)_dyld_get_image_header(0) + off;
    mach_port_t t = mach_task_self();
    vm_protect(t, (vm_address_t)addr, sz, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    memcpy((void *)addr, data, sz);
    vm_protect(t, (vm_address_t)addr, sz, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
}

@interface AOVMenu : UIView
@end

@implementation AOVMenu {
    UIView *_menuBox;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.layer.zPosition = 100000; // Cực cao để đè lên UI của game

        // Nút bấm nhỏ (Màu vàng cho giống màu game)
        UIButton *mainBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        mainBtn.frame = CGRectMake(10, 80, 45, 45);
        mainBtn.backgroundColor = [UIColor colorWithRed:0.85 green:0.75 blue:0.4 alpha:0.8];
        mainBtn.layer.cornerRadius = 22.5;
        mainBtn.layer.borderWidth = 1;
        mainBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        [mainBtn setTitle:@"L Quân" forState:UIControlStateNormal];
        mainBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        [mainBtn addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:mainBtn];

        _menuBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 220, 160)];
        _menuBox.center = self.center;
        _menuBox.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.1 alpha:0.95];
        _menuBox.layer.cornerRadius = 10;
        _menuBox.layer.borderWidth = 1.5;
        _menuBox.layer.borderColor = [UIColor colorWithRed:0.85 green:0.75 blue:0.4 alpha:1.0].CGColor;
        _menuBox.hidden = YES;
        [self addSubview:_menuBox];

        [self addOpt:@"HACK MAP" y:30 o:0x1D2C4A0 d:"\x00\x00\x80\xD2\xC0\x03\x5F\xD6" l:8];
        [self addOpt:@"ANTEN CAO" y:90 o:0x2E1A5C4 d:"\x00\x00\xA0\x43" l:4];
    }
    return self;
}

- (void)addOpt:(NSString*)n y:(float)y o:(uintptr_t)o d:(const char*)d l:(size_t)l {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.frame = CGRectMake(10, y, 200, 40);
    [b setTitle:n forState:UIControlStateNormal];
    [b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [b addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    objc_set_associated_object(b, "o", @(o), OBJC_ASSOCIATION_RETAIN);
    objc_set_associated_object(b, "d", [NSData dataWithBytes:d length:l], OBJC_ASSOCIATION_RETAIN);
    [_menuBox addSubview:b];
}

- (void)toggle { _menuBox.hidden = !_menuBox.hidden; }
- (void)clicked:(UIButton*)s {
    uintptr_t o = [objc_get_associated_object(s, "o") unsignedLongValue];
    NSData *d = objc_get_associated_object(s, "d");
    aov_patch(o, (const char *)d.bytes, d.length);
    [s setTitle:@"KÍCH HOẠT OK!" forState:UIControlStateNormal];
    [s setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
}

// Giúp vẫn chơi được game khi menu đang hiện
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *v = [super hitTest:point withEvent:event];
    return (v == self) ? nil : v;
}
@end

static void CheckWindow() {
    UIWindow *w = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *s in [UIApplication sharedApplication].connectedScenes) {
            if (s.activationState == UISceneActivationStateForegroundActive) {
                w = s.windows.firstObject; break;
            }
        }
    }
    if (!w) w = [UIApplication sharedApplication].keyWindow;

    if (w) {
        [w addSubview:[[AOVMenu alloc] initWithFrame:w.bounds]];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            CheckWindow();
        });
    }
}

static __attribute__((constructor)) void aov_init() {
    // Đợi 25 giây để Liên Quân qua hết Logo TiMi/Garena và load sảnh
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        CheckWindow();
    });
}
