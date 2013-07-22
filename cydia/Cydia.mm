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
	pkgRecords *$records;
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
		$records = new pkgRecords(*$cache);
	}

	return self;
}

- (NSDictionary *)contentToIndexForID:(NSString *)identifier inCategory:(NSString *)category {
	NSMutableDictionary *ret = [NSMutableDictionary dictionary];
	
	NSArray *keys = [identifier componentsSeparatedByString:@"\036"];
	
	for (NSString *pair in keys) {
		NSArray *members = [pair componentsSeparatedByString:@"\037"];

		NSString *key = [members objectAtIndex:0];
		NSString *value = [members objectAtIndex:1];

		if ([value isEqualToString:@"%_TL_NOINFO"])
			value = @"?";
		
		if ([key isEqualToString:@"name"]) {
			[ret setObject:[NSString stringWithFormat:@"cydia://%@", value] forKey:@"actionURL"];
		}
		else if ([key isEqualToString:@"display"]) {
			[ret setObject:value forKey:kSPContentContentKey];
			[ret setObject:value forKey:kSPContentTitleKey];
		}
		else if ([key isEqualToString:@"author"]) {
			// Again, no premature optimization.
			[ret setObject:value forKey:kSPContentSubtitleKey];
		}
		else if ([key isEqualToString:@"description"]) {
			[ret setObject:value forKey:kSPContentSummaryKey];
		}
		else if ([key isEqualToString:@"paid"]) {
			// Premature optimization sucks - UNIX Philosophy
			if ([value isEqualToString:@"1"])
				[ret setObject:[@"$ \u2014 " stringByAppendingString:[ret objectForKey:kSPContentSubtitleKey]] forKey:kSPContentSubtitleKey];
		}
	}

	return ret;
}

- (NSArray *)allIdentifiersInCategory:(NSString *)category {
	NSLog(@"CyData Cydia datastore starting all identifiers for category");

	//const CFArrayCallBacks releaseCallBacks = { 0, NULL, kCFTypeArrayCallBacks.release, NULL, NULL };
	CFMutableArrayRef packages = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
	
	for (pkgCache::PkgIterator iterator = $cache->PkgBegin(); !iterator.end(); ++iterator) {
		const char *name = iterator.Name();
		const char *display = iterator.Display() ?: name;
		
		pkgCache::VerIterator verIterator = iterator.VersionList();
	
		pkgCache::VerFileIterator file;
		if (!verIterator.end()) file = verIterator.FileList();
		else {
			file = pkgCache::VerFileIterator(*$cache, $cache->VerFileP);
		}
		if (file.end()) continue;

		const char *start, *end;
		pkgRecords::Parser &parser = $records->Lookup(file);
		
		// TODO: Instead of having this error string just don't include this field in the format string.
		char *description;
		if (!parser.ShortDesc(start, end)) description = (char *)"%_TL_NOINFO";
		else {
			// Remove line breaks from short description.
			const char *stop = reinterpret_cast<const char *>(memchr(start, '\n', end - start));
			if (stop == NULL)
				stop = end;
			while (stop != start && stop[-1] == '\r')
				--stop;

			description = (char *)malloc((stop - start + 1) * sizeof(char));
			strncpy(description, start, stop - start);
			description[stop - start] = '\0';
			
			if (stop - start == 0) description = (char *)"%_TL_NOINFO";
		}

		char *author;
		if (!parser.Find("author", start, end)) author = (char *)"%_TL_NOINFO";
		else {
			if (end - start == 0) author = (char *)"%_TL_NOINFO";
			
			// Remove the e-mail address from the author field.
			const char *stop = reinterpret_cast<const char *>(memchr(start, '<', end - start));
			if (stop == NULL)
				stop = end;
			while (stop != start && stop[-1] == ' ')
				--stop;

			author = (char *)malloc((stop - start + 1) * sizeof(char));
			strncpy(author, start, stop - start);
			author[stop - start] = '\0';
		}

		int paid = 0;
		for (pkgCache::TagIterator taglist = iterator.TagList(); !taglist.end(); ++taglist) {
			const char *tag = taglist.Name();
			if (tag == NULL) continue;

			if (strcmp(tag, "cydia::commercial") == 0) {
				paid = 1;
				break;
			}
		}

		CFStringRef identifier = CFStringCreateWithFormat(NULL, NULL, CFSTR("name\037%s\036display\037%s\036author\037%s\036description\037%s\036paid\037%d"), name, display, author, description, paid);
		CFArrayAppendValue(packages, identifier);

		/*free(author);
		free(description);*/
	}
	

	NSLog(@"Cydia datastore returning all identifiers for category.");
	return (NSArray *)packages;
}

- (void)dealloc {
	delete[] $cache;
	$cache = NULL;

	delete[] $records;
	$records = NULL;

	[super dealloc];
}
@end

__attribute__((constructor))
static void TLCydiaDatastoreInitialize() {
	// TODO: Handle failure of these.
	pkgInitConfig(*_config);
	pkgInitSystem(*_config, _system);
}
