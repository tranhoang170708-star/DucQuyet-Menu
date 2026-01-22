TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DucQuyetMenu

# Tự động tìm tất cả file trong folder gui
DucQuyetMenu_FILES = Tweak.xm $(wildcard gui/*.cpp) $(wildcard gui/*.mm)
DucQuyetMenu_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore Metal MetalKit
DucQuyetMenu_CFLAGS = -fobjc-arc -I. -Igui

include $(THEOS_MAKE_PATH)/tweak.mk
