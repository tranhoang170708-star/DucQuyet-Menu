#import <UIKit/UIKit.h>

// Gọi các file trong thư mục gui (Đảm bảo folder gui có các file này)
#include "gui/imgui.h"
#include "gui/imgui_internal.h"

static bool show_menu = true;

// Hàm vẽ Menu đơn giản
void DrawDucQuyetMenu() {
    if (!show_menu) return;
    
    // Kiểm tra ImGui Context để tránh văng game
    if (ImGui::GetCurrentContext() != NULL) {
        ImGui::Begin("DUC QUYET VIP", &show_menu);
        ImGui::Text("Menu phien ban 2026");
        if (ImGui::Button("Tat Menu")) show_menu = false;
        ImGui::End();
    }
}

// Hook vào giao diện để hiện Menu
%hook UIView
- (void)layoutSubviews {
    %orig;
    DrawDucQuyetMenu();
}
%end

%ctor {
    NSLog(@"[DucQuyet] Tweak da kich hoat!");
}
