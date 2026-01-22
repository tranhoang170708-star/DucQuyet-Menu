export THEOS_DEVICE_IP = 127.0.0.1
export THEOS_DEVICE_PORT = 2222

# Đổi DucQuyetMenu thành tên gì đó vô hại như "SystemSoundFix"
TWEAK_NAME = longnguyen 

SystemSoundFix_FILES = Tweak.xm
SystemSoundFix_CFLAGS = -fobjc-arc
SystemSoundFix_LDFLAGS = -Wl,-segalign,4000

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
