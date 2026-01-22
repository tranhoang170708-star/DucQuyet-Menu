TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DucQuyetMenu

# Quan trọng: Dòng này trỏ đến các file trong thư mục ImGui bạn vừa up
DucQuyetMenu_FILES = Tweak.xm $(wildcard ImGui/*.cpp)
# Thêm đường dẫn header
DucQuyetMenu_CFLAGS = -fobjc-arc -IImGui

include $(THEOS_MAKE_PATH)/tweak.mk
