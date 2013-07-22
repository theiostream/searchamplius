include theos/makefiles/common.mk

BUNDLE_NAME = CydiaSearch
CydiaSearch_FILES = Cydia.mm
CydiaSearch_INSTALL_PATH = /System/Library/Spotlight/SearchBundles/
CydiaSearch_BUNDLE_EXTENSION = searchBundle
CydiaSearch_CFLAGS = -I./cydia/sysroot/usr/include/
CydiaSearch_LDFLAGS = -lspotlight -L./cydia/sysroot/usr/lib/ -lapt-pkg
CydiaSearch_PRIVATE_FRAMEWORKS = Spotlight

TOOL_NAME = CydiaDaemon
CydiaDaemon_FILES = CydiaDaemon.mm
CydiaDaemon_INSTALL_PATH = /Library/SearchLoader/Daemons/
CydiaDaemon_CFLAGS = -I./cydia/sysroot/usr/include/
CydiaDaemon_LDFLAGS = -L./cydia/sysroot/usr/lib/ -lapt-pkg
CydiaDaemon_PRIVATE_FRAMEWORKS = Search

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tool.mk

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications
	cp -r InfoBundle/ $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications/Cydia.bundle
	
	mkdir -p $(THEOS_STAGING_DIR)/Library/LaunchDaemons
	cp CydiaDaemon.plist $(THEOS_STAGING_DIR)/Library/LaunchDaemons/am.theiostre.spotlightplus.cydiad.plist
	
	mkdir -p $(THEOS_STAGING_DIR)/DEBIAN
	cp postinst.sh $(THEOS_STAGING_DIR)/DEBIAN/postinst
	cp prerm.sh $(THEOS_STAGING_DIR)/DEBIAN/prerm
