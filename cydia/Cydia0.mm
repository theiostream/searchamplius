// Cydia.mm
// by theiostream

#import <Foundation/Foundation.h>
#import <SearchLoader/TLLibrary.h>

#include <apt-pkg/init.h>
#include <apt-pkg/error.h>
#include <apt-pkg/pkgcache.h>
#include <apt-pkg/sourcelist.h>
#include <apt-pkg/pkgcachegen.h>

#define NSSTRING_WITH_APT_CSTRING(cstr) \
	([NSString stringWithUTF8String: cstr ] ?: [NSString stringWithCString: cstr  encoding:NSISOLatin1StringEncoding])

@interface TLCydiaDatastore : NSObject <SPSpotlightDatastore> {
	pkgCache *$cache;
}
@end

@implementation TLCydiaDatastore
- (id)init {
	if ((self = [super init])) {
		// We need to do this instead of using pkgCacheFile because we're not root.
		// This is completely copied from apt-cache.cc
		MMap *map = 0;
		if (!_config->FindB("APT::Cache::Generate", true))
			map = new MMap(*new FileFd(_config->FindFile("Dir::Cache::pkgcache"), FileFd::ReadOnly), MMap::Public | MMap::ReadOnly);
		else {
			pkgSourceList *srcList = new pkgSourceList;
			srcList->ReadMainList();

			OpProgress prog;
			pkgMakeStatusCache(*srcList, prog, &map, true);
		}
		
		$cache = new pkgCache(map);
	}

	return self;
}

- (NSDictionary *)contentToIndexForID:(NSString *)identifier inCategory:(NSString *)category {
	NSMutableDictionary *ret = [NSMutableDictionary dictionary];
	
	clock_t t = clock();
	NSLog(@"current clock: %d", t);

	pkgCache::PkgIterator package = $cache->FindPkg([identifier UTF8String]);
	if (package == 0) return nil;
	
	NSLog(@"FindPackage clock: %d", clock() - t);
	t = clock();

	const char *name = package.Name();
	const char *display = package.Display();
	
	NSLog(@"get chars clock: %d", clock() - t);
	t = clock();

	[ret setObject:NSSTRING_WITH_APT_CSTRING(name) forKey:kSPContentSummaryKey];
	[ret setObject:NSSTRING_WITH_APT_CSTRING(display ?: name) forKey:kSPContentContentKey];
	[ret setObject:NSSTRING_WITH_APT_CSTRING(display ?: name) forKey:kSPContentTitleKey];
	
	NSLog(@"build dict clock: %d", clock() - t);
	t = clock();
	
	NSLog(@"End absolute clock: %d", t);
	return ret;
}

- (NSArray *)allIdentifiersInCategory:(NSString *)category {
	NSLog(@"CyData Cydia datastore starting all identifiers for category");

	const CFArrayCallBacks releaseCallBacks = { 0, NULL, kCFTypeArrayCallBacks.release, NULL, NULL };
	CFMutableArrayRef packages = CFArrayCreateMutable(NULL, 0, &releaseCallBacks);
	
	for (pkgCache::PkgIterator iterator = $cache->PkgBegin(); !iterator.end(); ++iterator) {
		CFStringRef identifier = CFStringCreateWithCString(NULL, iterator.Name(), kCFStringEncodingUTF8);
		CFArrayAppendValue(packages, identifier);
	}
	
	NSLog(@"Cydia datastore returning all identifiers for category.");
	return (NSArray *)packages;
}

- (void)dealloc {
	delete[] $cache;
	[super dealloc];
}
@end

__attribute__((constructor))
static void TLCydiaDatastoreInitialize() {
	// TODO: Handle failure of these.
	pkgInitConfig(*_config);
	pkgInitSystem(*_config, _system);
}
