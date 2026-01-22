#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// Gọi các file trong thư mục gui
#include "gui/imgui.h"
#include "gui/imgui_internal.h"

// Biến lưu trạng thái bật tắt
bool show_menu = true;
bool hack_1 = false;
bool hack_2 = false;
float speed_val = 1.0f;

// --- GIAO DIỆN MENU ---
void SetupDucQuyetStyle() {
    ImGuiStyle& style = ImGui::GetStyle();
    style.WindowRounding = 10.0f;
    style.FrameRounding = 5.0f;
    style.ChildRounding = 5.0f;
    style.GrabRounding = 5.0f;

    ImVec4* colors = style.Colors;
    colors[ImGuiCol_WindowBg] = ImVec4(0.06f, 0.06f, 0.10f, 0.94f); 
    colors[ImGuiCol_TitleBgActive] = ImVec4(0.20f, 0.22f, 0.36f, 1.00f);
    colors[ImGuiCol_CheckMark] = ImVec4(0.28f, 0.56f, 1.00f, 1.00f); 
    colors[ImGuiCol_SliderGrab] = ImVec4(0.28f, 0.56f, 1.00f, 1.00f);
    colors[ImGuiCol_Button] = ImVec4(0.20f, 0.25f, 0.35f, 1.00f);
    colors[ImGuiCol_ButtonHovered] = ImVec4(0.28f, 0.56f, 1.00f, 1.00f);
}

void DrawDucQuyetMenu() {
    if (!show_menu) return;

    SetupDucQuyetStyle();
    ImGui::SetNextWindowSize(ImVec2(400, 320), ImGuiCond_FirstUseEver);

    if (ImGui::Begin("--- DUC QUYET VIP PREMIUM ---", &show_menu, ImGuiWindowFlags_NoResize)) {
        ImGui::TextColored(ImVec4(1, 1, 0, 1), "ADMIN: DUC QUYET");
        ImGui::Text("Phien ban: 1.0.0 (Pro)");
        ImGui::Separator();

        if (ImGui::BeginTabBar("Tabs")) {
            if (ImGui::BeginTabItem("Chuc Nang")) {
                ImGui::Dummy(ImVec2(0, 10));
                ImGui::Checkbox("Bat tu (God Mode)", &hack_1);
                ImGui::Checkbox("Hien xuyen tuong (ESP)", &hack_2);
                ImGui::SliderFloat("Toc do chay", &speed_val, 1.0f, 50.0f);
                ImGui::EndTabItem();
            }
            if (ImGui::BeginTabItem("Thong Tin")) {
                ImGui::Text("Menu thiet ke boi DucQuyet.");
                ImGui::Text("Lien he: Zalo DucQuyet");
                ImGui::EndTabItem();
            }
            ImGui::EndTabBar();
        }
        ImGui::Separator();
        ImGui::TextColored(ImVec4(0.5f, 0.5f, 0.5f, 1.0f), "Trang thai: Da kich hoat!");
    }
    ImGui::End();
}

// --- HOOK ĐỂ HIỂN THỊ MENU ---
// Hook vào Windows chính của Game để chèn lớp vẽ ImGui
%hook UIWindow
- (void)layoutSubviews {
    %orig;
    // Gọi hàm vẽ menu mỗi khi màn hình cập nhật
    DrawDucQuyetMenu();
}
%end

// --- LỆNH KÍCH HOẠT KHI VÀO GAME ---
%ctor {
    NSLog(@"--- DUC QUYET MENU DANG LOAD... ---");
    
    // Đợi 5 giây sau khi mở Game để hiện Menu
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        show_menu = true;
        NSLog(@"--- DUC QUYET MENU DA HIEN THI! ---");
    });
}
