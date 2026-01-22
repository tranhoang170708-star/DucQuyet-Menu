export THEOS = /opt/theos
DEBUG = 0
FINALPACKAGE = 1
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DucQuyetMenu
DucQuyetMenu_FILES = Tweak.xm
DucQuyetMenu_CFLAGS = -fobjc-arc
DucQuyetMenu_FRAMEWORKS = UIKit CoreGraphics QuartzCore

include $(THEOS)/makefiles/tweak.mk
