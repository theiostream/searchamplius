include theos/makefiles/common.mk

BUNDLE_NAME = WeatherSearch
WeatherSearch_FILES = Weather.mm
WeatherSearch_INSTALL_PATH = /Library/SearchLoader/SearchBundles
WeatherSearch_BUNDLE_EXTENSION = searchBundle
WeatherSearch_LDFLAGS = -lspotlight
WeatherSearch_FRAMEWORKS = SystemConfiguration
WeatherSearch_PRIVATE_FRAMEWORKS = Search Weather

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications
	cp -r InfoBundle/ $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications/Weather.bundle
