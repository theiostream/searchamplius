include theos/makefiles/common.mk

BUNDLE_NAME = StocksSearch
StocksSearch_FILES = Stocks.xm
StocksSearch_INSTALL_PATH = /Library/SearchLoader/SearchBundles/
StocksSearch_BUNDLE_EXTENSION = searchBundle
StocksSearch_LDFLAGS = -lspotlight
StocksSearch_FRAMEWORKS = SystemConfiguration
StocksSearch_PRIVATE_FRAMEWORKS = Search Stocks

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications
	cp -r InfoBundle/ $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications/Stocks.bundle

	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences
	cp Stocks.plist $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences
