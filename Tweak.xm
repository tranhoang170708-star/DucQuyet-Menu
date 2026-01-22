#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface DucQuyetMenu : UIView
@end

@implementation DucQuyetMenu {
    UIButton *_menuBtn;
    UIView *_panel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.layer.zPosition = 1000000; // Ép lên trên cùng

        // Nút tròn mở Menu
        _menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _menuBtn.frame = CGRectMake(40, 100, 60, 60);
        _menuBtn.backgroundColor = [UIColor colorWithRed:1.0 green:0.2 blue:0.2 alpha:0.8];
        _menuBtn.layer.cornerRadius = 30;
        [_menuBtn setTitle:@"QUYẾT" forState:UIControlStateNormal];
        [_menuBtn addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_menuBtn];

        // Khung Menu chức năng
        _panel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 200)];
        _panel.center = self.center;
        _panel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.9];
        _panel.layer.cornerRadius = 15;
        _panel.hidden = YES;
        [self addSubview:_panel];

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 250, 30)];
        title.text = @"DUC QUYET MENU";
        title.textColor = [UIColor yellowColor];
        title.textAlignment = NSTextAlignmentCenter;
        [_panel addSubview:title];
    }
    return self;
}

- (void)toggle { _panel.hidden = !_panel.hidden; }

// Quan trọng: Không cho menu chặn cảm ứng của game
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    if (hit == self) return nil;
    return hit;
}
@end

// Hàm nạp menu vào Window
static void SetupMenu() {
    UIWindow *win = [UIApplication sharedApplication].keyWindow;
    if (win && ![win viewWithTag:178178]) {
        DucQuyetMenu *m = [[DucQuyetMenu alloc] initWithFrame:win.bounds];
        m.tag = 178178;
        [win addSubview:m];
    }
}

%ctor {
    // Lắng nghe sự kiện ngay khi Window của game xuất hiện
    [[NSNotificationCenter defaultCenter] addObserverForName:UIWindowDidBecomeKeyNotification 
                                                      object:nil 
                                                       queue:[NSOperationQueue mainQueue] 
                                                  usingBlock:^(NSNotification *note) {
        SetupMenu();
    }];
    
    // Dự phòng: Ép chạy sau 5 giây nếu sự kiện trên bị lỡ
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        SetupMenu();
    });
}
