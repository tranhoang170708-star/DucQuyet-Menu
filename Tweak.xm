#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import <objc/runtime.h>

// --- HÀM PATCH BẰNG LỆNH HỆ THỐNG (KHÔNG DÙNG MSHookMemory) ---
// Cách này lách qua tất cả các bộ quét của Game vì nó là hàm chuẩn của Apple
void write_memory(uintptr_t offset, const char *data, size_t size) {
    uintptr_t vm_address = (uintptr_t)_dyld_get_image_header(0) + offset;
    kern_return_t kr;
    mach_port_t self_task = mach_task_self();

    // Cấp quyền ghi vào bộ nhớ
    kr = vm_protect(self_task, (vm_address_t)vm_address, size, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    if (kr == KERN_SUCCESS) {
        memcpy((void *)vm_address, data, size);
        // Khôi phục quyền cũ để game không phát hiện vùng nhớ bị can thiệp
        vm_protect(self_task, (vm_address_t)vm_address, size, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
    }
}

@interface DQStealthMenu : UIView
@property (nonatomic, strong) UIView *box;
@end

@implementation DQStealthMenu
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Nút bấm siêu nhỏ ở góc màn hình
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(5, 120, 35, 35);
        btn.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.3];
        btn.layer.cornerRadius = 17.5;
        [btn addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];

        self.box = [[UIView alloc] initWithFrame:CGRectMake(0,0,180,130)];
        self.box.center = self.center;
        self.box.backgroundColor = [UIColor colorWithWhite:0 alpha:0.95];
        self.box.layer.cornerRadius = 5;
        self.box.hidden = YES;
        [self addSubview:self.box];

        [self createBtn:@"MAP" y:20 o:0x1D2C4A0 h:"\x00\x00\x80\xD2\xC0\x03\x5F\xD6" l:8];
        [self createBtn:@"ANTEN" y:70 o:0x2E1A5C4 h:"\x00\x00\xA0\x43" l:4];
    }
    return self;
}

- (void)createBtn:(NSString*)n y:(float)y o:(uintptr_t)o h:(const char*)h l:(size_t)l {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.frame = CGRectMake(10, y, 160, 40);
    [b setTitle:n forState:UIControlStateNormal];
    [b addTarget:self action:@selector(doPatch:) forControlEvents:UIControlEventTouchUpInside];
    
    // Lưu thông tin patch vào nút bấm
    objc_setAssociated_object(b, "off", @(o), OBJC_ASSOCIATION_RETAIN);
    objc_setAssociated_object(b, "data", [NSData dataWithBytes:h length:l], OBJC_ASSOCIATION_RETAIN);
    [self.box addSubview:b];
}

- (void)toggle { self.box.hidden = !self.box.hidden; }
- (void)doPatch:(UIButton*)sender {
    uintptr_t o = [objc_get_associated_object(sender, "off") unsignedLongValue];
    NSData *d = objc_get_associated_object(sender, "data");
    write_memory(o, (const char *)d.bytes, d.length);
    [sender setTitle:@"OK!" forState:UIControlStateNormal];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    return (hit == self) ? nil : hit;
}
@end

// --- KHỞI TẠO TÀNG HÌNH ---
static __attribute__((constructor)) void start_service() {
    // Đợi hẳn 40 giây mới bắt đầu kiểm tra Window (Vượt qua hoàn toàn lúc khởi động)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 40 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIWindow *w = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *s in [UIApplication sharedApplication].connectedScenes) {
                if (s.activationState == UISceneActivationStateForegroundActive) {
                    w = s.windows.firstObject; break;
                }
            }
        }
        if (!w) w = [UIApplication sharedApplication].windows.firstObject;
        
        if (w) {
            [w addSubview:[[DQStealthMenu alloc] initWithFrame:w.bounds]];
        }
    });
}
