export THEOS_DEVICE_IP = 127.0.0.1
export THEOS_DEVICE_PORT = 2222

# Nếu file của bạn là DucQuyetMenu.plist thì đặt tên này:
TWEAK_NAME = DucQuyetMenu

DucQuyetMenu_FILES = Tweak.xm
DucQuyetMenu_CFLAGS = -fobjc-arc
DucQuyetMenu_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
