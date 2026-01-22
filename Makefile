export THEOS_DEVICE_IP = 127.0.0.1
export THEOS_DEVICE_PORT = 2222

# Đặt tên trùng với file .plist
TWEAK_NAME = DQMenu

DQMenu_FILES = Tweak.xm
DQMenu_CFLAGS = -fobjc-arc
DQMenu_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
