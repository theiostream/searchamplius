/*%%%%%
%% Store.m
%% Spotlight+ Store Search Bundle
%% by theiostream
%%
%% iTunes Search API: http://www.apple.com/itunes/affiliates/resources/documentation/itunes-store-web-service-search-api.html
%%*/

#import <Foundation/Foundation.h>
#import <SearchLoader/TLLibrary.h>

// This is not source-controlled.
// Create your own "key.h" header file which #defines YOUTUBE_KEY to your API key to the YouTube API.
#import "key.h"

static NSString *NSStringURLEncode(NSString *string) {
	return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)string, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
}

static NSString *ParseTime(NSString *time) {
	NSScanner *scanner = [NSScanner scannerWithString:time];
	[scanner setScanLocation:2];
	
	int tm[3] = {0, 0, 0};

	int scanned;
	while ([scanner scanInt:&scanned]) {
		NSString *character;
		if (![scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"HMS"] intoString:&character]) break;

		int idx = [character isEqualToString:@"H"] ? 0 : [character isEqualToString:@"M"] ? 1 : [character isEqualToString:@"S"] ? 2 : 3;
		if (idx == 3) break;

		tm[idx] = scanned;
	}
	
	return [NSString stringWithFormat:@"%@%@:%@", tm[0]>0 ? [NSString stringWithFormat:@"%d:", tm[0]] : @"", tm[1]<10 ? [NSString stringWithFormat:@"0%d", tm[1]] : [NSString stringWithFormat:@"%d", tm[1]], tm[2]<10 ? [NSString stringWithFormat:@"0%d", tm[2]] : [NSString stringWithFormat:@"%d", tm[2]]];
}

@interface TLYouTubeDatastore : NSObject <TLSearchDatastore> {
	BOOL $usingInternet;
}
@end

@implementation TLYouTubeDatastore
- (void)performQuery:(SDSearchQuery *)query withResultsPipe:(SDSearchQuery *)results {
	NSString *searchString = [query searchString];
	
	int limit = [[[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/am.theiostre.spotlightplus.youtube.plist"] objectForKey:@"Limit"] intValue] ?: 5;
	NSString *format = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=id&q=%@&type=video&maxResults=%d&key=%s", NSStringURLEncode(searchString), limit, YOUTUBE_KEY];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:format] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3];
	
	TLRequireInternet(YES);
	$usingInternet = YES;

	NSOperationQueue *operationQueue = [[[NSOperationQueue alloc] init] autorelease];
	[NSURLConnection sendAsynchronousRequest:request queue:operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
		if (data != nil) {
			NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
			NSArray *items = [root objectForKey:@"items"];
			
			for (NSDictionary *item in items) {
				if (![[item objectForKey:@"kind"] isEqualToString:@"youtube#searchResult"] || ![item objectForKey:@"id"])
					continue;
				
				NSString *format2 = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?part=snippet,contentDetails&id=%@&key=%s", [[item objectForKey:@"id"] objectForKey:@"videoId"], YOUTUBE_KEY];
				NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:format2] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3];
				
				NSData *data2 = [NSURLConnection sendSynchronousRequest:request2 returningResponse:NULL error:NULL];
				if (data2 != nil) {
					NSDictionary *root2 = [NSJSONSerialization JSONObjectWithData:data2 options:kNilOptions error:nil];
					NSDictionary *details = [[root2 objectForKey:@"items"] objectAtIndex:0];
					
					NSDictionary *snippet = [details objectForKey:@"snippet"];
					NSDictionary *contentDetails = [details objectForKey:@"contentDetails"];

					SPSearchResult *result = [[[SPSearchResult alloc] init] autorelease];
					[result setTitle:[snippet objectForKey:@"title"]];
					[result setSubtitle:[NSString stringWithFormat:@"%@ (%@)", [snippet objectForKey:@"channelTitle"], ParseTime([contentDetails objectForKey:@"duration"])]];
					[result setSummary:[snippet objectForKey:@"description"]];
					[result setUrl:[NSString stringWithFormat:@"http://youtube.com/watch?v=%@", [details objectForKey:@"id"]]];
					
					TLCommitResults([NSArray arrayWithObject:result], TLDomain(@"com.google.ios.youtube", @"YouTubeSearch"), results);
				}
			}
		}
		
		TLRequireInternet(NO);
		$usingInternet = NO;
		[results storeCompletedSearch:self];

		TLFinishQuery(results);
	}];
}

- (NSArray *)searchDomains {
	return [NSArray arrayWithObject:[NSNumber numberWithInteger:TLDomain(@"com.google.ios.youtube", @"YouTubeSearch")]];
}

- (NSString *)displayIdentifierForDomain:(NSInteger)domain {
	return @"com.google.ios.youtube";
}

- (BOOL)blockDatastoreComplete {
	return $usingInternet;
}
@end
