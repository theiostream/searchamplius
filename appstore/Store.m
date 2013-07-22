/*%%%%%
%% Store.m
%% Spotlight+ Store Search Bundle
%% by theiostream
%%
%% iTunes Search API: http://www.apple.com/itunes/affiliates/resources/documentation/itunes-store-web-service-search-api.html
%%*/

#import <Foundation/Foundation.h>
#import <SearchLoader/TLLibrary.h>
#import "CountryCode.h"

static NSString *NSStringURLEncode(NSString *string) {
	return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)string, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
}

@interface SSAccount : NSObject
- (NSString *)storeFrontIdentifier;
@end

@interface SSAccountStore : NSObject
+ (id)defaultStore;
- (SSAccount *)activeAccount;
@end

static inline NSString *CountryCode_(NSString *storeFront) {
	return CountryCode([[storeFront componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]] objectAtIndex:0]);
}

@interface TLStoreDatastore : NSObject <TLSearchDatastore> {
	BOOL $usingInternet;
}
@end

@implementation TLStoreDatastore
- (void)performQuery:(SDSearchQuery *)query withResultsPipe:(SDSearchQuery *)results {
	NSString *searchString = [query searchString];
	
	int limit = [[[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/am.theiostre.spotlightplus.appstore.plist"] objectForKey:@"Limit"] intValue] ?: 5;
	
	NSString *storeFront = [[[SSAccountStore defaultStore] activeAccount] storeFrontIdentifier];
	NSString *countryCode = storeFront ? CountryCode_(storeFront) : @"US";
	
	NSString *format = [NSString stringWithFormat:@"http://itunes.apple.com/search?term=%@&entity=software&attribute=songTerm&country=%@&limit=%d", NSStringURLEncode(searchString), countryCode, limit];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:format] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
	
	$usingInternet = YES;
	TLRequireInternet(YES);

	NSOperationQueue *operationQueue = [[[NSOperationQueue alloc] init] autorelease];
	[NSURLConnection sendAsynchronousRequest:request queue:operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
		if (data != nil) {
			NSMutableArray *searchResults = [NSMutableArray array];
			
			NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
			NSArray *items = [root objectForKey:@"results"];
			
			for (NSDictionary *item in items) {
				SPSearchResult *result = [[[SPSearchResult alloc] init] autorelease];
				
				NSNumber *price_ = [item objectForKey:@"price"];
				NSString *price = [price_ intValue] != 0 ? [@"$" stringByAppendingString:[price_ stringValue]] : @"Free";
				
				NSString *rating;
				if ([item objectForKey:@"userRatingCount"] != nil)
					rating = [NSString stringWithFormat:@"%@/5", [[item objectForKey:@"averageUserRating"] stringValue]];
				else
					rating = @"NR";
				
				[result setTitle:[item objectForKey:@"trackName"]];
				[result setSubtitle:price];
				[result setSummary:[NSString stringWithFormat:@"%@ \u2014 %@", [item objectForKey:@"artistName"], rating]];
				
				NSString *url = [item objectForKey:@"trackViewUrl"];
				if (TLIsOS6) [result setUrl:url];
				else [result setURL:[NSURL URLWithString:url]];
				
				[searchResults addObject:result];
			}
			
			TLCommitResults(searchResults, TLDomain(@"com.apple.AppStore", @"StoreSearch"), results);
		}
		
		TLRequireInternet(NO);
		$usingInternet = NO;
		[results storeCompletedSearch:self];

		TLFinishQuery(results);
	}];
}

- (NSArray *)searchDomains {
	return [NSArray arrayWithObject:[NSNumber numberWithInteger:TLDomain(@"com.apple.AppStore", @"StoreSearch")]];
}

- (NSString *)displayIdentifierForDomain:(NSInteger)domain {
	return @"com.apple.AppStore";
}

- (BOOL)blockDatastoreComplete {
	return $usingInternet;
}
@end
