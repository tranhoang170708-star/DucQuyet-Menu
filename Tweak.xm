#import <UIKit/UIKit.h>
#import <Timer.h>

// Gọi các file trong thư mục gui
#include "gui/imgui.h"
#include "gui/imgui_internal.h"

// Biến trạng thái
bool show_menu = false;
bool hack_1 = false;
float speed_val = 1.0f;

// Hàm vẽ menu
void DrawDucQuyetMenu() {
    // Kiểm tra Context trước khi vẽ để tránh văng
    if (ImGui::GetCurrentContext() == NULL) return;

    ImGui::Begin("DUC QUYET VIP", &show_menu);
    ImGui::Text("Menu da load thanh cong!");
    ImGui::Checkbox("Bat tu", &hack_1);
    ImGui::End();
}

// Khởi tạo an toàn bằng ctor
%ctor {
    // Chạy trong một luồng riêng để không làm treo tiến trình khởi động của game
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"[DucQuyet] Dylib da vao game!");
        
        // Đợi 10 giây cho game vào hẳn màn hình chính rồi mới kích hoạt logic
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // Ở đây bạn cần một bộ Hook Metal chuẩn để tạo ImGui Context
            // Nếu chưa có Backend, tạm thời chúng ta chỉ in Log để kiểm tra xem có văng không
            show_menu = true;
            NSLog(@"[DucQuyet] Menu san sang!");
        });
    });
}
