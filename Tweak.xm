#import <UIKit/UIKit.h>

// Gọi các file trong thư mục gui
#include "gui/imgui.h"
#include "gui/imgui_internal.h"

// Biến lưu trạng thái bật tắt
bool show_menu = true;
bool hack_1 = false;
bool hack_2 = false;
float speed_val = 1.0f;

// Hàm tạo màu sắc "Siêu đẹp" cho DucQuyet Menu
void SetupDucQuyetStyle() {
    ImGuiStyle& style = ImGui::GetStyle();
    
    // Bo góc cửa sổ và các nút
    style.WindowRounding = 10.0f;
    style.FrameRounding = 5.0f;
    // Đã sửa: Xóa HeaderRounding bị lỗi và thay bằng ChildRounding/GrabRounding
    style.ChildRounding = 5.0f;
    style.GrabRounding = 5.0f;

    // Bảng màu Neon/Dark (Tím - Xanh dương)
    ImVec4* colors = style.Colors;
    colors[ImGuiCol_WindowBg] = ImVec4(0.06f, 0.06f, 0.10f, 0.94f); // Nền tối
    colors[ImGuiCol_TitleBgActive] = ImVec4(0.20f, 0.22f, 0.36f, 1.00f);
    colors[ImGuiCol_CheckMark] = ImVec4(0.28f, 0.56f, 1.00f, 1.00f); // Dấu tích xanh neon
    colors[ImGuiCol_SliderGrab] = ImVec4(0.28f, 0.56f, 1.00f, 1.00f);
    colors[ImGuiCol_Button] = ImVec4(0.20f, 0.25f, 0.35f, 1.00f);
    colors[ImGuiCol_ButtonHovered] = ImVec4(0.28f, 0.56f, 1.00f, 1.00f);
}

void DrawDucQuyetMenu() {
    if (!show_menu) return;

    SetupDucQuyetStyle();

    // Kích thước menu
    ImGui::SetNextWindowSize(ImVec2(400, 320), ImGuiCond_FirstUseEver);

    // Bắt đầu vẽ
    if (ImGui::Begin("--- DUC QUYET VIP PREMIUM ---", &show_menu, ImGuiWindowFlags_NoResize)) {

        ImGui::TextColored(ImVec4(1, 1, 0, 1), "ADMIN: DUC QUYET");
        ImGui::Text("Phien ban: 1.0.0 (Demo UI)");
        ImGui::Separator();

        // Chia Tab cho chuyên nghiệp
        if (ImGui::BeginTabBar("Tabs")) {
            
            if (ImGui::BeginTabItem("Chuc Nang")) {
                ImGui::Dummy(ImVec2(0, 10)); // Khoảng cách
                ImGui::Checkbox("Bat tu (God Mode)", &hack_1);
                ImGui::Checkbox("Hien xuyen tuong (ESP)", &hack_2);
                ImGui::SliderFloat("Toc do chay", &speed_val, 1.0f, 50.0f);
                ImGui::EndTabItem();
            }

            if (ImGui::BeginTabItem("Mau Sac")) {
                ImGui::Text("Tuy chinh mau Menu o day...");
                static float color[4] = { 0.4f, 0.7f, 0.0f, 0.5f };
                ImGui::ColorEdit4("Chon mau", color);
                ImGui::EndTabItem();
            }

            if (ImGui::BeginTabItem("Thong Tin")) {
                ImGui::Text("Menu nay duoc thiet ke boi DucQuyet.");
                ImGui::Text("Lien he: Zalo/Telegram DucQuyet");
                if (ImGui::Button("Sao chep ID thiet bi")) {
                    // Code copy UDID
                }
                ImGui::EndTabItem();
            }
            ImGui::EndTabBar();
        }

        ImGui::Separator();
        ImGui::TextColored(ImVec4(0.5f, 0.5f, 0.5f, 1.0f), "He thong dang cho kich hoat...");
    }
    ImGui::End();
}
