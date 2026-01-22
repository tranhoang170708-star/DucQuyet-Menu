TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DucQuyetMenu

# Đã đổi từ ImGui/*.cpp thành gui/*.cpp
DucQuyetMenu_FILES = Tweak.xm $(wildcard gui/*.cpp)

# Thêm các Framework cần thiết để vẽ giao diện
DucQuyetMenu_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore
# Đã đổi -IImGui thành -Igui
DucQuyetMenu_CFLAGS = -fobjc-arc -I. -Igui

include $(THEOS_MAKE_PATH)/tweak.mk
