#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>

// --- Hàm ghi bộ nhớ (Cấp quyền ghi và khôi phục quyền thực thi) ---
void patch_memory(uintptr_t offset, const char *data, size_t size) {
    uintptr_t address = (uintptr_t)_dyld_get_image_header(0) + offset;
    mach_port_t task = mach_task_self();
    if (vm_protect(task, (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY) == KERN_SUCCESS) {
        memcpy((void *)address, data, size);
        vm_protect(task, (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
    }
}

@interface DQMenu : UIView
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) UIView *box;
@end

@implementation DQMenu {
    BOOL _isHackActive;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.tag = 178; // Gắn tag để không bị nạp chồng
        self.layer.zPosition = 1000000;

        // 1. Nút DQ tròn màu Cyan Neon
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn.frame = CGRectMake(60, 160, 58, 58);
        _btn.backgroundColor = [UIColor colorWithRed:0.0 green:0.7 blue:0.9 alpha:0.85];
        _btn.layer.cornerRadius = 29;
        _btn.layer.borderWidth = 2;
        _btn.layer.borderColor = [UIColor whiteColor].CGColor;
        [_btn setTitle:@"DQ" forState:UIControlStateNormal];
        _btn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [_btn addTarget:self action:@selector(toggleBox) forControlEvents:UIControlEventTouchUpInside];
        
        // Thêm kéo thả cho nút
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
        [_btn addGestureRecognizer:pan];
        [self addSubview:_btn];

        // 2. Bảng Menu điều khiển
        _box = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 180)];
        _box.center = self.center;
        _box.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.1 alpha:0.95];
        _box.layer.cornerRadius = 20;
        _box.layer.borderWidth = 1.5;
        _box.layer.borderColor = [UIColor cyanColor].CGColor;
        _box.hidden = YES;
        [self addSubview:_box];

        // Tiêu đề Menu
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 250, 30)];
        title.text = @"ĐỨC QUYẾT VIP MENU";
        title.textColor = [UIColor cyanColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont boldSystemFontOfSize:17];
        [_box addSubview:title];

        // Nút bấm Hack Map
        UIButton *sw = [UIButton buttonWithType:UIButtonTypeCustom];
        sw.frame = CGRectMake(25, 65, 200, 50);
        sw.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
        sw.layer.cornerRadius = 12;
        [sw setTitle:@"HACK MAP: OFF" forState:UIControlStateNormal];
        [sw setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        sw.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [sw addTarget:self action:@selector(switchMap:) forControlEvents:UIControlEventTouchUpInside];
        [_box addSubview:sw];

        UILabel *credit = [[UILabel alloc] initWithFrame:CGRectMake(0, 140, 250, 20)];
        credit.text = @"Safe Mode - Anti Ban v1";
        credit.textColor = [UIColor grayColor];
        credit.font = [UIFont systemFontOfSize:10];
        credit.textAlignment = NSTextAlignmentCenter;
        [_box addSubview:credit];
    }
    return self;
}

// Logic Bật/Tắt (CHỈ thực thi khi bấm nút)
- (void)switchMap:(UIButton *)sender {
    _isHackActive = !_isHackActive;
    
    // OFFSET HACK MAP (Địa chỉ cần Patch)
    uintptr_t mapOffset = 0x1D2C4A0; 

    if (_isHackActive) {
        // --- KHI BẬT: Patch mã Hack ---
        patch_memory(mapOffset, "\x00\x00\x80\xD2\xC0\x03\x5F\xD6", 8);
        
        [sender setTitle:@"HACK MAP: ON" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor colorWithRed:0.0 green:0.6 blue:0.2 alpha:1]; // Xanh lá
    } else {
        // --- KHI TẮT: Trả về mã GỐC của game ---
        // Nếu tắt không mất, hãy kiểm tra 8 bytes gốc này có đúng với bản game của bạn không
        patch_memory(mapOffset, "\xFF\x43\x00\xD1\xF4\x4F\x01\xA9", 8); 
        
        [sender setTitle:@"HACK MAP: OFF" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1]; // Màu xám
    }
}

- (void)handleDrag:(UIPanGestureRecognizer *)g {
    CGPoint t = [g translationInView:self];
    g.view.center = CGPointMake(g.view.center.x + t.x, g.view.center.y + t.y);
    [g setTranslation:CGPointZero inView:self];
}

- (void)toggleBox { _box.hidden = !_box.hidden; }

// hitTest để bấm được vào Game phía dưới Menu
- (UIView *)hitTest:(CGPoint)p withEvent:(UIEvent *)e {
    UIView *v = [super hitTest:p withEvent:e];
    return (v == self) ? nil : v;
}
@end

// Hàm nạp Menu vào Window của Game
static void ShowMenu() {
    UIWindow *win = nil;
    for (UIWindow *w in [UIApplication sharedApplication].windows) {
        if (w.isKeyWindow || [w isKindOfClass:NSClassFromString(@"UIWindow")]) {
            win = w;
            break;
        }
    }
    
    if (win && ![win viewWithTag:178]) {
        DQMenu *menu = [[DQMenu alloc] initWithFrame:win.bounds];
        [win addSubview:menu];
    } else if (!win) {
        // Nếu chưa tìm thấy Window, thử lại sau 1s
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            ShowMenu();
        });
    }
}

// KHỞI TẠO: Chỉ nạp giao diện, KHÔNG được nạp Patch ở đây
static __attribute__((constructor)) void init() {
    // Đợi 7 giây để qua màn hình Logo Garena
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 7 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        ShowMenu();
    });
}
