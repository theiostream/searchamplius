include theos/makefiles/common.mk

BUNDLE_NAME = MusicStoreSearch
MusicStoreSearch_FILES = Store.m
MusicStoreSearch_INSTALL_PATH = /Library/SearchLoader/SearchBundles
MusicStoreSearch_BUNDLE_EXTENSION = searchBundle
MusicStoreSearch_LDFLAGS = -lspotlight
MusicStoreSearch_PRIVATE_FRAMEWORKS = Search StoreServices

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications
	cp -r InfoBundle/ $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications/MusicStore.bundle

	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences
	cp Store.plist $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences/MusicStore.plist
