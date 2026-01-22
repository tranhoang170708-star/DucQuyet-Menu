export THEOS_DEVICE_IP = 127.0.0.1
export THEOS_DEVICE_PORT = 2222

TWEAK_NAME = AOVHelper

AOVHelper_FILES = Tweak.xm
AOVHelper_CFLAGS = -fobjc-arc
AOVHelper_LDFLAGS = -Wl,-segalign,4000
AOVHelper_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
