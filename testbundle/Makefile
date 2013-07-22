include theos/makefiles/common.mk

BUNDLE_NAME = TestSearch
TestSearch_FILES = Test.mm
TestSearch_INSTALL_PATH = /System/Library/Spotlight/SearchBundles/
TestSearch_BUNDLE_EXTENSION = searchBundle
TestSearch_PRIVATE_FRAMEWORKS = Search Spotlight

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications
	cp -r InfoBundle/ $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications/Test.bundle

