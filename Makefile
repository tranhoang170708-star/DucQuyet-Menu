TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DucQuyetMenu

DucQuyetMenu_FILES = Tweak.xm $(wildcard gui/*.cpp)
DucQuyetMenu_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore Metal MetalKit
DucQuyetMenu_CFLAGS = -fobjc-arc -I. -Igui

include $(THEOS_MAKE_PATH)/tweak.mk
