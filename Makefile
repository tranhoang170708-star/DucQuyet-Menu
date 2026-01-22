TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DucQuyetMenu

# Lệnh này sẽ tự tìm tất cả file .cpp bên trong folder gui
DucQuyetMenu_FILES = Tweak.xm $(wildcard gui/*.cpp)

# Thêm các thư viện hệ thống cần thiết cho iOS
DucQuyetMenu_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore
DucQuyetMenu_CFLAGS = -fobjc-arc -I. -Igui

include $(THEOS_MAKE_PATH)/tweak.mk
