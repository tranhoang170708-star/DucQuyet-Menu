export THEOS_DEVICE_IP = 127.0.0.1
export THEOS_DEVICE_PORT = 2222

# Tên tweak đồng nhất (Đã đổi để tránh bị game quét tên "longnguyen")
TWEAK_NAME = SystemAssetProvider

SystemAssetProvider_FILES = Tweak.xm
SystemAssetProvider_CFLAGS = -fobjc-arc
SystemAssetProvider_LDFLAGS = -Wl,-segalign,4000
# Thêm Framework để hiển thị UI
SystemAssetProvider_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
