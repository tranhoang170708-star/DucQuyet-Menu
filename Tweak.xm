#import <UIKit/UIKit.h>

// Gọi các file trong thư mục gui
#include "gui/imgui.h"
#include "gui/imgui_internal.h"

// Biến trạng thái
bool show_menu = true;
bool hack_1 = false;
bool hack_2 = false;
float speed_val = 1.0f;

// --- GIAO DIỆN MENU ---
void SetupDucQuyetStyle() {
    static bool style_loaded = false;
    if (style_loaded) return;
    
    ImGuiStyle& style = ImGui::GetStyle();
    style.WindowRounding = 10.0f;
    style.FrameRounding = 5.0f;
    
    ImVec4* colors = style.Colors;
    colors[ImGuiCol_WindowBg] = ImVec4(0.06f, 0.06f, 0.10f, 0.94f); 
    colors[ImGuiCol_TitleBgActive] = ImVec4(0.20f, 0.22f, 0.36f, 1.00f);
    colors[ImGuiCol_CheckMark] = ImVec4(0.28f, 0.56f, 1.00f, 1.00f); 
    
    style_loaded = true;
}

void DrawDucQuyetMenu() {
    // Chỉ vẽ khi ImGui đã được khởi tạo và đang có Context
    if (!show_menu || ImGui::GetCurrentContext() == NULL) return;

    SetupDucQuyetStyle();
    
    ImGui::Begin("--- DUC QUYET VIP ---", &show_menu, ImGuiWindowFlags_NoResize);
    ImGui::TextColored(ImVec4(1, 1, 0, 1), "ADMIN: DUC QUYET");
    ImGui::Separator();
    
    ImGui::Checkbox("Bat tu (God Mode)", &hack_1);
    ImGui::SliderFloat("Toc do", &speed_val, 1.0f, 10.0f);
    
    if (ImGui::Button("Dong Menu")) {
        show_menu = false;
    }
    
    ImGui::End();
}

// --- HOOK AN TOÀN ---
// Thay vì hook UIWindow, chúng ta hook vào hàm vẽ của Game (Unity/Metal)
// Nếu đây là Liên Quân, chúng ta nên dùng một cách hook nhẹ hơn

%hook UIViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"DucQuyet Menu: Game Loaded");
    });
}
%end

// Hàm này chạy liên tục nhưng an toàn hơn UIWindow
%hook UIView
- (void)drawRect:(CGRect)rect {
    %orig;
    // Chỉ vẽ menu nếu ImGui đã sẵn sàng
    if (show_menu) {
        DrawDucQuyetMenu();
    }
}
%end

// --- KHỞI TẠO ---
%ctor {
    // Đảm bảo dylib load xong mới chạy
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"DucQuyet Menu Ready");
        show_menu = true;
    });
}
