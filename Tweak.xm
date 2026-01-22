#import <UIKit/UIKit.h>

// Gọi các file trong thư mục gui
#include "gui/imgui.h"
#include "gui/imgui_internal.h"

bool show_menu = true;

void DrawDucQuyetMenu() {
    if (!show_menu || ImGui::GetCurrentContext() == NULL) return;
    
    ImGui::Begin("DUC QUYET VIP", &show_menu);
    ImGui::Text("Menu Loaded Successfully!");
    if (ImGui::Button("Close")) show_menu = false;
    ImGui::End();
}

// Hook đơn giản vào UIView để hiện menu
%hook UIView
- (void)layoutSubviews {
    %orig;
    if (show_menu) {
        DrawDucQuyetMenu();
    }
}
%end

%ctor {
    NSLog(@"[DucQuyet] Tweak Loaded");
    // Hiện menu sau 5 giây
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        show_menu = true;
    });
}
