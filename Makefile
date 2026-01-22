export THEOS = /opt/theos
DEBUG = 0
FINALPACKAGE = 1
# Target cho iOS 14 trở lên
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DucQuyetMenu

# Liệt kê các file nguồn (Sửa lại tên file .xm của bạn cho đúng)
DucQuyetMenu_FILES = Tweak.xm $(wildcard gui/*.cpp)
DucQuyetMenu_CFLAGS = -fobjc-arc -Igui
DucQuyetMenu_FRAMEWORKS = UIKit CoreGraphics QuartzCore

include $(THEOS)/makefiles/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
