SUBPROJECTS = calculator appstore musicstore weather stocks maps cydia youtube #testbundle

TARGET = ::4.3

include theos/makefiles/common.mk

TWEAK_NAME = extendedwatcher
extendedwatcher_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Missing/$(ECHO_END)
	$(ECHO_NOTHING)mkdir $(THEOS_STAGING_DIR)/Library/SearchLoader/Missing/Pad/$(ECHO_END)
	$(ECHO_NOTHING)cp Icons/*.png $(THEOS_STAGING_DIR)/Library/SearchLoader/Missing/$(ECHO_END)
	$(ECHO_NOTHING)cp Icons/Pad/*.png $(THEOS_STAGING_DIR)/Library/SearchLoader/Missing/Pad/$(ECHO_END)

	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Internal/$(ECHO_END)
	$(ECHO_NOTHING)touch $(THEOS_STAGING_DIR)/Library/SearchLoader/Internal/extendedwatcher.dat$(ECHO_END)

internal-after-install::
	install.exec "killall -9 backboardd searchd AppIndexer &>/dev/null"
