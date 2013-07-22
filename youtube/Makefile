include theos/makefiles/common.mk

BUNDLE_NAME = YouTubeSearch
YouTubeSearch_FILES = YouTube.m
YouTubeSearch_INSTALL_PATH = /Library/SearchLoader/SearchBundles
YouTubeSearch_BUNDLE_EXTENSION = searchBundle
YouTubeSearch_LDFLAGS = -lspotlight
YouTubeSearch_PRIVATE_FRAMEWORKS = Search

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications
	cp -r InfoBundle/ $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications/YouTube.bundle

	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences/
	cp YouTube.plist $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences/
