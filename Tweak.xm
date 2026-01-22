#import <UIKit/UIKit.h>
#include "gui/imgui.h"

static bool show_menu = true;
static bool is_initialized = false;

// Hàm khởi tạo giao diện ImGui
void SetupImGui(UIView *view) {
    if (is_initialized) return;
    
    // Tạo ImGui Context
    ImGui::CreateContext();
    // Cấu hình style (tùy chọn)
    ImGui::StyleColorsDark();
    
    is_initialized = true;
}

void RenderMenu() {
    if (!show_menu) return;

    // Kiểm tra an toàn trước khi vẽ
    if (ImGui::GetCurrentContext() != NULL) {
        ImGui::Begin("DUC QUYET MENU", &show_menu, ImGuiWindowFlags_AlwaysAutoResize);
        ImGui::Text("Version 2026 - Anti Crash");
        ImGui::Separator();
        
        static bool hack1 = false;
        if (ImGui::Checkbox("Bật Hack 1", &hack1)) {
            // Logic hack
        }
        
        if (ImGui::Button("Đóng Menu")) {
            show_menu = false;
        }
        ImGui::End();
    }
}

// HOOK AN TOÀN: Chỉ hook vào UIWindow thay vì UIView để tránh văng
%hook UIWindow
- (void)layoutSubviews {
    %orig;
    
    // Chỉ khởi tạo và vẽ nếu đây là cửa sổ chính
    if ([self isKindOfClass:NSClassFromString(@"UIWindow")]) {
        SetupImGui(self);
        RenderMenu();
    }
}
%end

%ctor {
    // Chạy trong một luồng nhẹ để tránh làm game bị treo lúc khởi động
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"[DucQuyet] Menu Ready!");
    });
}
