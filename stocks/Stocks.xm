/*%%%%%
%% Stocks.m
%% Spotlight+ Weather Stocks Bundle
%% by theiostream
%%*/

#import <Foundation/Foundation.h>
#import <SearchLoader/TLLibrary.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "Stocks.h"
#include <netinet/in.h>
#include <objc/runtime.h>

static NSString *NSStringURLEncode(NSString *string) {
	return [(NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)string, NULL, CFSTR("!*'();:@&;=+$,/?%#[]"), kCFStringEncodingUTF8) autorelease];
}

@interface TLStocksDatastore : NSObject <SPSearchDatastore, TLSymbolValidatorDelegate> {
	SDSearchQuery *actor;
	//BOOL usingInternet;
}
@end

@implementation TLStocksDatastore
- (id)init {
	if ((self = [super init])) {
		actor = nil;
		//usingInternet = NO;
	}
	
	return self;
}

- (void)finish {
	CFStringRef mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
	if (mode != NULL) {
		CFRunLoopStop(CFRunLoopGetCurrent());
		CFRelease(mode);
	}
	
	//TLFinishInternetUsage(&usingInternet, self, actor);
	TLRequireInternet(NO);
	TLFinishQuery(actor);

	[actor release];
	actor = nil;
}

- (void)symbolValidator:(SymbolValidator *)validator didValidateSymbols:(NSArray *)symbols {
	NSMutableArray *results = [NSMutableArray array];
	for (NSDictionary *stock in symbols) {
		SPSearchResult *result = [[[SPSearchResult alloc] init] autorelease];
		//[result setDomain:TLDomain(@"com.apple.stocks", @"StocksSearch")];
		
		[result setTitle:[stock objectForKey:@"companyName"]];
		[result setSubtitle:[stock objectForKey:@"symbol"]];
		if ([stock objectForKey:@"exchange"]) [result setSummary:[stock objectForKey:@"exchange"]];
		[result setUrl:[NSString stringWithFormat:@"http://m.yahoo.com/w/yfinance/quote/%@/", NSStringURLEncode([stock objectForKey:@"symbol"])]];
		
		
		[results addObject:result];
	}
	
	//[actor appendResults:results];
	TLCommitResults(results, TLDomain(@"com.apple.stocks", @"StocksSearch"), actor);
	
	[self finish];
}

- (void)symbolValidator:(SymbolValidator *)validator didFailWithError:(id)error {
	[self finish];
}

- (void)performQuery:(SDSearchQuery *)query withResultsPipe:(SDSearchQuery *)results {
	NSString *searchString = [query searchString];
	actor = [results retain];
	
	SymbolValidator *validator = [[[SymbolValidator alloc] initWithDelegate:self] autorelease];
	if (!TLIsOS6) [validator setUsesGTServer:NO];

	int limit = [[[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/am.theiostre.spotlightplus.stocks.plist"] objectForKey:@"Limit"] intValue] ?: 5;
	[validator validateSymbol:searchString withMaxResults:limit];
	
	TLRequireInternet(YES);

	SInt32 ret = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 5, false);
	if (ret == kCFRunLoopRunTimedOut) [self finish];
}

- (NSArray *)searchDomains {
	return [NSArray arrayWithObject:[NSNumber numberWithInteger:TLDomain(@"com.apple.stocks", @"StocksSearch")]];
}

- (NSString *)displayIdentifierForDomain:(NSInteger)domain {
	return @"com.apple.stocks";
}

- (void)dealloc {
	if (actor != nil) [actor release];
	[super dealloc];
}
@end

%config(generator=internal)
%hook NetPreferences
- (BOOL)isNetworkReachable {
	// For some reason it returns NO even though there /is/ internet access.
	// So here we get rid of CPNetworkObserver and do our own SystemConfiguration stuff! :)
	
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zeroAddress);
	SCNetworkReachabilityFlags flags;
	SCNetworkReachabilityGetFlags(reachability, &flags);
	
	return ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
}
%end
