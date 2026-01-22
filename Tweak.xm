#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface DQMenu : UIView
@end

@implementation DQMenu {
    UIView *_container;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.layer.zPosition = 9999; // Lớp rất cao

        // Nút Menu nhỏ ở góc
        UIButton *mainBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        mainBtn.frame = CGRectMake(20, 100, 50, 50);
        mainBtn.backgroundColor = [UIColor redColor];
        mainBtn.layer.cornerRadius = 25;
        [mainBtn setTitle:@"M" forState:UIControlStateNormal];
        [mainBtn addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:mainBtn];

        // Khung chức năng (ẩn lúc đầu)
        _container = [[UIView alloc] initWithFrame:CGRectMake(80, 100, 180, 100)];
        _container.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        _container.layer.cornerRadius = 10;
        _container.hidden = YES;
        [self addSubview:_container];

        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 180, 30)];
        lbl.text = @"MENU ACTIVE";
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        [_container addSubview:lbl];
    }
    return self;
}

- (void)toggleMenu { _container.hidden = !_container.hidden; }

// Quan trọng: Cho phép chạm xuyên qua lớp nền của UIView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) return nil;
    return hitView;
}
@end

// Hook vào quá trình khởi tạo ứng dụng để nạp Menu ngay
%hook UnityAppController

- (void)applicationDidBecomeActive:(id)arg1 {
    %orig;
    UIWindow *keyWin = [UIApplication sharedApplication].keyWindow;
    if (keyWin && ![keyWin viewWithTag:7777]) {
        DQMenu *menu = [[DQMenu alloc] initWithFrame:keyWin.bounds];
        menu.tag = 7777;
        [keyWin addSubview:menu];
    }
}
%end
