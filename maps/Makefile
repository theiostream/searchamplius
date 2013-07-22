include theos/makefiles/common.mk

BUNDLE_NAME = MapsSearch
MapsSearch_FILES = Maps.m
MapsSearch_INSTALL_PATH = /Library/SearchLoader/SearchBundles
MapsSearch_BUNDLE_EXTENSION = searchBundle
MapsSearch_LDFLAGS = -lspotlight
MapsSearch_FRAMEWORKS = CoreLocation AddressBook
MapsSearch_PRIVATE_FRAMEWORKS = Search

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications
	cp -r InfoBundle/ $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications/Maps.bundle
