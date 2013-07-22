/*%%%%%
%% Cydia.m
%% Cydia Search
%% by theiostream
%%
%% apt-cache (@ svn.telesphoreo.org) and Cydia (@ git.saurik.com) were huge references.
%% http://fossies.org/dox/apt_0.9.7.8/ <- Undocumented API List.
%%*/

#import <Foundation/Foundation.h>
#import <SearchLoader/TLLibrary.h>

#include <apt-pkg/init.h>
#include <apt-pkg/error.h>
#include <apt-pkg/configuration.h>
#include <apt-pkg/pkgsystem.h>
#include <apt-pkg/sourcelist.h>
#include <apt-pkg/progress.h>
#include <apt-pkg/mmap.h>
#include <apt-pkg/pkgcache.h>
#include <apt-pkg/pkgcachegen.h>
#include <apt-pkg/cacheiterators.h>
#include <apt-pkg/pkgrecords.h>

#define searchAssert(x) do { if (!(x)) { kill(getpid(), SIGKILL); } } while(0)
#define NSSTR(cstr) ((cstr != NULL) ? [NSString stringWithUTF8String:cstr] : nil)
#define CSTR(cppstr) ((!cppstr.empty()) ? cppstr.c_str() : NULL)

static inline BOOL TLCydiaMatch(NSString *a, NSString *b) {
	if (a == nil || b == nil) return NO;
	return [a rangeOfString:b options:NSLiteralSearch | NSCaseInsensitiveSearch].location != NSNotFound;
}

@interface TLCydiaDatastore : NSObject <SPSearchDatastore> {
	SDSearchQuery *$query;
}
@end

@implementation TLCydiaDatastore
- (void)commitResultWithIdentifier:(NSString *)identifier name:(NSString *)name author:(NSString *)author shortDescription:(NSString *)shortDescription rank:(int)rank {
	SPSearchResult *result = [[[SPSearchResult alloc] init] autorelease];
	[result setTitle:name];
	[result setSummary:shortDescription];
	[result setSubtitle:author];
	
	NSString *url = [NSString stringWithFormat:@"cydia://package/%@", identifier];
	if (TLIsOS6) [result setUrl:url];
	else [result setURL:[NSURL URLWithString:url]];
	
	TLCommitResults([NSArray arrayWithObject:result], TLDomain(@"com.saurik.Cydia", @"CydiaSearch"), $query);
}

- (void)performQuery:(SDSearchQuery *)query withResultsPipe:(SDSearchQuery *)results {
	NSLog(@"Performing Cydia query");
	
	searchAssert(pkgInitConfig(*_config));
	searchAssert(pkgInitSystem(*_config, _system));
	
	$query = [results retain];
	NSString *searchString = [query searchString];
	
	MMap *Map = 0;
	if (!_config->FindB("APT::Cache::Generate", true)) {
		Map = new MMap(*new FileFd(_config->FindFile("Dir::Cache::pkgcache"), FileFd::ReadOnly), MMap::Public | MMap::ReadOnly);
	}
	else {
		pkgSourceList *SrcList = new pkgSourceList;
		SrcList->ReadMainList();
		
		OpProgress Prog;
		pkgMakeStatusCache(*SrcList, Prog, &Map, true);
	}
	searchAssert(!_error->PendingError());
	
	NSLog(@"Generated the cache.");
	
	pkgCache Cache(Map);
	pkgCache::PkgIterator iterator = Cache.PkgBegin();
	bool All = _config->FindB("APT::Cache::AllNames", "false");
	
	NSLog(@"Got Iterators.");
	
	pkgRecords records = pkgRecords(Cache);
	for (; !iterator.end(); ++iterator) {
		if (!All && iterator->VersionList == 0) continue;
		
		BOOL willMatch = NO;
		int rank = 4;
		
		NSString *identifier = NSSTR(iterator.Name());
		willMatch |= TLCydiaMatch(identifier, searchString);
		
		NSString *name = NSSTR(iterator.Display()) ?: identifier;
		if (!willMatch) {
			willMatch |= TLCydiaMatch(name, searchString);
			rank--;
		}
		
		NSString *shortDescription = nil,
				 *author = nil;
		
		pkgCache::VerIterator verIterator = iterator.VersionList();
		if (verIterator.end()) continue;
		
		pkgCache::VerFileIterator verFileIterator = verIterator.FileList();
		for (; !verFileIterator.end(); verFileIterator++) {
			if ((verFileIterator.File()->Flags & pkgCache::Flag::NotSource) == 0)
				break;
		}
		if (verFileIterator.end()) verFileIterator = verIterator.FileList();
		
		if (!verFileIterator.end()) {
			pkgRecords::Parser &parser = records.Lookup(verFileIterator);
			
			shortDescription = NSSTR(CSTR(parser.ShortDesc()));
			if (!willMatch) {
				willMatch |= TLCydiaMatch(shortDescription, searchString);
				rank--;
			}
			
			const char *start, *end;
			if (parser.Find("author", start, end)) {
				char *final = (char *)malloc((end - start) * sizeof(char));
				strncpy(final, start, end - start);
				char *final_ = strsep(&final, "<");
				
				author = NSSTR(final_); free(final_);
				if (!willMatch) {
					willMatch |= TLCydiaMatch(author, searchString);
					rank--;
				}
			}
		}
		
		if (willMatch)
			[self commitResultWithIdentifier:identifier name:name author:author shortDescription:shortDescription rank:rank];
	}
	
	NSLog(@"####!!!! Ended Iterations. !!!!####");
	
	if (!TLIsOS6) [$query queryFinishedWithError:nil];
	
	[$query release];
	
	NSLog(@"GOODBYE BLUE SKY");
}

- (NSArray *)searchDomains {
	return [NSArray arrayWithObject:[NSNumber numberWithInteger:TLDomain(@"com.saurik.Cydia", @"CydiaSearch")]];
}

- (NSString *)displayIdentifierForDomain:(NSInteger)domain {
	return @"com.saurik.Cydia";
}
@end
