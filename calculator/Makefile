include theos/makefiles/common.mk

BUNDLE_NAME = CalculatorSearch
CalculatorSearch_FILES = Calculator.m
CalculatorSearch_INSTALL_PATH = /Library/SearchLoader/SearchBundles
CalculatorSearch_BUNDLE_EXTENSION = searchBundle
CalculatorSearch_LDFLAGS = -lspotlight
CalculatorSearch_PRIVATE_FRAMEWORKS = Search Calculate

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications
	cp -r InfoBundle/ $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications/Calculator.bundle
