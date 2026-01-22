#import <UIKit/UIKit.h>
#include "gui/imgui.h"

static bool show_menu = true;

// Hàm khởi tạo Menu
void RenderMenu() {
    if (!show_menu) return;

    if (ImGui::GetCurrentContext() != NULL) {
        ImGui::Begin("DUC QUYET MENU", &show_menu);
        ImGui::Text("Phien ban Mod 2026");
        ImGui::Separator();
        
        if (ImGui::Button("Bat Hack")) {
            // Logic hack của bạn ở đây
        }
        
        if (ImGui::Button("Dong Menu")) {
            show_menu = false;
        }
        ImGui::End();
    }
}

// Hook vào View để hiển thị
%hook UIView
- (void)layoutSubviews {
    %orig;
    RenderMenu();
}
%end

%ctor {
    NSLog(@"[DucQuyet] Tweak Loaded!");
}
