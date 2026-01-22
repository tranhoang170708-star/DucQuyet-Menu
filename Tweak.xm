#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import <objc/runtime.h>

// --- HÀM PATCH (GIỮ NGUYÊN BẢN TÀNG HÌNH) ---
void write_memory(uintptr_t offset, const char *data, size_t size) {
    uintptr_t vm_address = (uintptr_t)_dyld_get_image_header(0) + offset;
    mach_port_t self_task = mach_task_self();
    vm_protect(self_task, (vm_address_t)vm_address, size, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    memcpy((void *)vm_address, data, size);
    vm_protect(self_task, (vm_address_t)vm_address, size, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
}

@interface DQFinalMenu : UIView
@property (nonatomic, strong) UIView *box;
@end

@implementation DQFinalMenu
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.layer.zPosition = 9999; // Đảm bảo luôn nằm trên cùng

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(10, 150, 40, 40);
        btn.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.6];
        btn.layer.cornerRadius = 20;
        [btn setTitle:@"DQ" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];

        self.box = [[UIView alloc] initWithFrame:CGRectMake(0,0,200,140)];
        self.box.center = self.center;
        self.box.backgroundColor = [UIColor colorWithWhite:0 alpha:0.9];
        self.box.hidden = YES;
        [self addSubview:self.box];

        [self addB:@"HACK MAP" y:20 o:0x1D2C4A0 h:"\x00\x00\x80\xD2\xC0\x03\x5F\xD6" l:8];
        [self addB:@"ANTEN" y:80 o:0x2E1A5C4 h:"\x00\x00\xA0\x43" l:4];
    }
    return self;
}

- (void)addB:(NSString*)n y:(float)y o:(uintptr_t)o h:(const char*)h l:(size_t)l {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.frame = CGRectMake(10, y, 180, 40);
    [b setTitle:n forState:UIControlStateNormal];
    [b addTarget:self action:@selector(patch:) forControlEvents:UIControlEventTouchUpInside];
    objc_set_associated_object(b, "o", @(o), OBJC_ASSOCIATION_RETAIN);
    objc_set_associated_object(b, "d", [NSData dataWithBytes:h length:l], OBJC_ASSOCIATION_RETAIN);
    [self.box addSubview:b];
}

- (void)toggle { self.box.hidden = !self.box.hidden; }
- (void)patch:(UIButton*)s {
    uintptr_t o = [objc_get_associated_object(s, "o") unsignedLongValue];
    NSData *d = objc_get_associated_object(s, "d");
    write_memory(o, (const char *)d.bytes, d.length);
    [s setTitle:@"DONE!" forState:UIControlStateNormal];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    return (hit == self) ? nil : hit;
}
@end

// --- VÒNG LẶP KIỂM TRA WINDOW ---
static void InjectMenu() {
    static int attempts = 0;
    UIWindow *keyWin = nil;
    
    // Thử lấy window theo scene
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                keyWin = scene.windows.firstObject;
                break;
            }
        }
    }
    if (!keyWin) keyWin = [UIApplication sharedApplication].keyWindow;

    if (keyWin) {
        DQFinalMenu *menu = [[DQFinalMenu alloc] initWithFrame:keyWin.bounds];
        [keyWin addSubview:menu];
        NSLog(@"[DQ] Menu Injected!");
    } else if (attempts < 20) { 
        // Nếu chưa thấy Window, thử lại sau 2 giây (tối đa 20 lần)
        attempts++;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            InjectMenu();
        });
    }
}

static __attribute__((constructor)) void start() {
    // Đợi 15 giây bắt đầu tìm window
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        InjectMenu();
    });
}
