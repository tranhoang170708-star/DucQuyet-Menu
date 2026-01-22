TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DucQuyetMenu

# Lệnh này giúp tự động nhận diện các file ImGui nếu bạn upload chúng lên
DucQuyetMenu_FILES = Tweak.xm $(wildcard ImGui/*.cpp)
DucQuyetMenu_CFLAGS = -fobjc-arc -IImGui

include $(THEOS_MAKE_PATH)/tweak.mk
