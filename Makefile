# Ép kiến trúc arm64/arm64e và target iOS cao để hỗ trợ chip mới
TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

# Tắt cảnh báo về phiên bản cũ
DucQuyetMenu_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable

export THEOS_DEVICE_IP = 127.0.0.1
export THEOS_DEVICE_PORT = 2222

TWEAK_NAME = DucQuyetMenu
DucQuyetMenu_FILES = Tweak.xm
DucQuyetMenu_FRAMEWORKS = UIKit CoreGraphics QuartzCore

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
