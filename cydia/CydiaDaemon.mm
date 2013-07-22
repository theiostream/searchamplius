// CydiaDaemon.mm
// by theiostream

#include <stdio.h>
#include <assert.h>

#include <apt-pkg/init.h>
#include <apt-pkg/error.h>
#include <apt-pkg/pkgcache.h>

#import <SearchLoader/TLLibraryInternal.h>
#include "SearchCytore.h"

@interface SPDomainManager : NSObject
+ (SPDomainManager *)defaultManager;
- (void)notifyIndexer;
@end

int main() {
	//assert(pkgInitConfig(*_config));
	//assert(pkgInitSystem(*_config, _system));
	
	// This will _assert() if metadata.cb0 is being used.
	Cytore::File<MetaValue> metafile;
	metafile.Open("/var/lib/cydia/metadata.cb0");
	
	// This unsigned integer works fine to check out the difference between recent Cydia update count changes, but it does not seem to match
	// pkgCache::PkgIterator's count! So, how does this work?!
	uint32_t count = metafile->active_;
	if (count == 0) {
		NSLog(@"[CydiaDaemon] Empty metadata.cb0");
		return 1;
	}

	// <3 DHowett, thanks!
	uint32_t stored = 0;
	FILE *fp = fopen("/Library/SearchLoader/Daemons/cydia_data.bin", "rb");
	if (fp == NULL) {
		if (errno != ENOENT) {
			NSLog(@"[CydiaDaemon] Failed reading cydia_data.bin");
			return 1;
		}
	}
	else {
		fread(&stored, sizeof(stored), 1, fp);
		fclose(fp);
	}
	
	NSLog(@"count=%u stored=%u", count, stored);

	if (stored != count) {
		// SPSpotlightManager sucks for this; I hate this workaround since we should use some specific Search.framework function.
		if (![[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Library/Spotlight/com.saurik.Cydia" error:nil]) {
			NSLog(@"[CydiaDaemon] Failed to purge Cydia Index.");
			return 1;
		}
		[[SPDomainManager defaultManager] notifyIndexer];

		/*//NSZone *zone = NSCreateZone(1024 * 1024, 256 * 1024, NO);
		//apr

		pkgCacheFile cache;
		OpProgress progress;
		
		open:
		if (!cache.Open(progress, true)) {
			while (!_error->empty()) {
				std::string error;
				_error->PopMessage(error);
				
				if (error == "dpkg was interrupted, you must manually run 'dpkg --configure -a' to correct the problem. ") {
					system("dpkg --configure -a");
					_error->Discard();
					goto open;
				}
			}

			NSLog(@"[CydiaDaemon] Failed to open APT cache.");
			return 2;
		}
		
		NSLog(@"Time Before Start.");
		
		CFMutableArrayRef packages = CFArrayCreateMutable(NULL, count + 1024, NULL);
		
		for (pkgCache::PkgIterator iterator = cache->PkgBegin(); !iterator.end(); ++iterator) {
			const char *name = iterator.Name();
			const char *display = iterator.Display();
			
			int len = 10 + strlen(name) + strlen(display);
			char *fmt = (char *)malloc(len * sizeof(char));
			
			strcpy(fmt, "name:");
			strcat(fmt, display);
			
			strcat(fmt, ";id:");
			strcat(fmt, name);
			
			CFStringRef identifier = CFStringCreateWithCString(NULL, fmt, kCFStringEncodingUTF8);
			free(fmt);

			//CFStringRef identifier = CFStringCreateWithFormat(NULL, NULL, CFSTR("name:%s;id:%s;"), iterator.Display(), iterator.Name());
			CFArrayAppendValue(packages, identifier);
		}

		NSLog(@"count ended as %d", CFArrayGetCount(packages));

		[manager application:@"com.saurik.Cydia" modifiedRecordIDs:(NSArray *)packages forCategory:@"CydiaSearch"];
		NSLog(@"Manager sent everything to AppIndexer.");
		
		CFArrayApplyFunction(packages, CFRangeMake(0, CFArrayGetCount(packages)), reinterpret_cast<CFArrayApplierFunction>(&CFRelease), NULL);
		CFRelease(packages);
		*/

		fp = fopen("/Library/SearchLoader/Daemons/cydia_data.bin", "wb");
		if (fp == NULL) {
			NSLog(@"[CydiaDaemon] Failed writing to cydia_data.bin. Fail!");
			return 1;
		}

		fwrite(&count, sizeof(count), 1, fp);
		NSLog(@"fwrote %d", count);
		fclose(fp);
	}

	return 0;
}

