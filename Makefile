export THEOS_DEVICE_IP = 127.0.0.1
export THEOS_DEVICE_PORT = 2222

TWEAK_NAME = SystemProvider

SystemProvider_FILES = Tweak.xm
SystemProvider_CFLAGS = -fobjc-arc -Wno-unguarded-availability-new -Wno-error
SystemProvider_LDFLAGS = -Wl,-segalign,4000
SystemProvider_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
