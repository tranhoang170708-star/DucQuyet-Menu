#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import <objc/runtime.h>

// Đảm bảo compiler hiểu UIButton có addTarget
@interface UIButton (Fix)
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
@end

// Hàm ghi bộ nhớ an toàn
void safe_write(uintptr_t offset, const char *data, size_t size) {
    uintptr_t address = (uintptr_t)_dyld_get_image_header(0) + offset;
    mach_port_t task = mach_task_self();
    if (vm_protect(task, (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY) == KERN_SUCCESS) {
        memcpy((void *)address, data, size);
        vm_protect(task, (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
    }
}

@interface AOVMenu : UIView
@end

@implementation AOVMenu {
    UIView *_box;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.layer.zPosition = 1000000;

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(15, 120, 50, 50);
        btn.backgroundColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:0.8];
        btn.layer.cornerRadius = 25;
        [btn setTitle:@"LQ" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];

        _box = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 220, 160)];
        _box.center = self.center;
        _box.backgroundColor = [UIColor colorWithWhite:0 alpha:0.95];
        _box.layer.cornerRadius = 10;
        _box.hidden = YES;
        [self addSubview:_box];

        [self addOpt:@"HACK MAP" y:30 o:0x1D2C4A0 d:"\x00\x00\x80\xD2\xC0\x03\x5F\xD6" l:8];
        [self addOpt:@"ANTEN" y:90 o:0x2E1A5C4 d:"\x00\x00\xA0\x43" l:4];
    }
    return self;
}

- (void)addOpt:(NSString*)n y:(float)y o:(uintptr_t)o d:(const char*)d l:(size_t)l {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.frame = CGRectMake(10, y, 200, 40);
    [b setTitle:n forState:UIControlStateNormal];
    [b addTarget:self action:@selector(patch:) forControlEvents:UIControlEventTouchUpInside];
    objc_setAssociatedObject(b, "o", @(o), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(b, "d", [NSData dataWithBytes:d length:l], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [_box addSubview:b];
}

- (void)toggle { _box.hidden = !_box.hidden; }

- (void)patch:(UIButton*)s {
    uintptr_t o = [(NSNumber *)objc_getAssociatedObject(s, "o") unsignedLongValue];
    NSData *d = (NSData *)objc_getAssociatedObject(s, "d");
    if (d) {
        safe_write(o, (const char *)d.bytes, d.length);
        [s setTitle:@"SUCCESS!" forState:UIControlStateNormal];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    if (hit == self) return nil;
    return hit;
}
@end

static void Inject() {
    UIWindow *w = nil;
    
    // Cách tìm Window chuẩn xác hỗ trợ cả iOS cũ và mới để tránh crash
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                w = scene.windows.firstObject;
                break;
            }
        }
    } else {
        w = [UIApplication sharedApplication].keyWindow;
    }

    if (w) {
        if (![w viewWithTag:888]) {
            AOVMenu *m = [[AOVMenu alloc] initWithFrame:w.bounds];
            m.tag = 888;
            [w addSubview:m];
        }
    } else {
        // Thử lại sau 2 giây nếu chưa tìm thấy Window
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            Inject();
        });
    }
}

static __attribute__((constructor)) void init() {
    // Đợi 15 giây để game ổn định rồi mới hiện Menu
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        Inject();
    });
}
