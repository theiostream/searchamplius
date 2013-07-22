include theos/makefiles/common.mk

BUNDLE_NAME = StoreSearch
StoreSearch_FILES = Store.m
StoreSearch_INSTALL_PATH = /Library/SearchLoader/SearchBundles
StoreSearch_BUNDLE_EXTENSION = searchBundle
StoreSearch_LDFLAGS = -lspotlight
StoreSearch_PRIVATE_FRAMEWORKS = Search StoreServices

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications
	cp -r InfoBundle/ $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications/Store.bundle

	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences
	cp Store.plist $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences/AppStore.plist
