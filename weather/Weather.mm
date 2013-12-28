/*%%%%%
%% Weather.m
%% Spotlight+ Weather Search Bundle
%% by theiostream
%%%%%*/

#import <Foundation/Foundation.h>
#import <SearchLoader/TLLibrary.h>
#import "Weather.h"

// I need to quit perfectionism.
static NSString *TLCleanUpState(NSString *state) {
	if ([state length] == 2) {
		// AMERICANS ARE NOT ABOVE THE STANDARDS ANYMORE.
		// FUCK THE SYSTEM -lu0411a
		NSDictionary *unitedStates = [NSDictionary dictionaryWithObjectsAndKeys:
			@"Alabama (United States)", @"AL",
			@"Alaska (United States)", @"AK",
			@"Arizona (United States)", @"AZ",
			@"Arkansas (United States)", @"AR",
			@"California (United States)", @"CA",
			@"Colorado (United States)", @"CO",
			@"Connecticut (United States)", @"CT",
			@"District of Columbia (United States)", @"DC",
			@"Delaware (United States)", @"DE",
			@"Florida (United States)", @"FL",
			@"Georgia (United States)", @"GA",
			@"Hawaii (United States)", @"HI",
			@"Idaho (United States)", @"ID",
			@"Illinois (United States)", @"IL",
			@"Indiana (United States)", @"IN",
			@"Iowa (United States)", @"IA",
			@"Kansas (United States)", @"KS",
			@"Kentucky (United States)", @"KY",
			@"Louisiana (United States)", @"LA",
			@"Maine (United States)", @"ME",
			@"Maryland (United States)", @"MD",
			@"Massachusetts (United States)", @"MA",
			@"Michigan (United States)", @"MI",
			@"Minnesota (United States)", @"MN",
			@"Mississippi (United States)", @"MS",
			@"Missouri (United States)", @"MO",
			@"Montana (United States)", @"MT",
			@"Nebraska (United States)", @"NE",
			@"Nevada (United States)", @"NV",
			@"New Hampshire (United States)", @"NH",
			@"New Jersey (United States)", @"NJ",
			@"New Mexico (United States)", @"NM",
			@"New York (United States)", @"NY",
			@"North Carolina (United States)", @"NC",
			@"North Dakota (United States)", @"ND",
			@"Ohio (United States)", @"OH",
			@"Oklahoma (United States)", @"OK",
			@"Oregon (United States)", @"OR",
			@"Pennsylvania (United States)", @"PA",
			@"Rhode Island (United States)", @"RI",
			@"South Carolina (United States)", @"SC",
			@"South Dakota (United States)", @"SD",
			@"Tennessee (United States)", @"TN",
			@"Texas (United States)", @"TX",
			@"Utah (United States)", @"UT",
			@"Vermont (United States)", @"VT",
			@"Virginia (United States)", @"VA",
			@"Washington (United States)", @"WA",
			@"West Virginia (United States)", @"WV",
			@"Wisconsin (United States)", @"WI",
			@"Wyoming (United States)", @"WY", nil];
		__block NSString *unitedStatesState = nil;
		[unitedStates enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
			if ([state isEqualToString:key]) { unitedStatesState = obj; *stop = YES; }
		}];
		if (unitedStatesState) return unitedStatesState;
	}
	
	NSMutableString *decentState = [NSMutableString string];
	[decentState setString:state];
	
	NSUInteger index = [decentState rangeOfString:@"("].location;
	if (index != NSNotFound) 
		[decentState insertString:@" " atIndex:index];
	
	return decentState;
}

@interface TLWeatherDatastore : NSObject <SPSearchDatastore, WeatherValidatorDelegate> {
	SDSearchQuery *actor;
	//BOOL blockComplete;
}
@end

@implementation TLWeatherDatastore
- (id)init {
	if ((self = [super init])) {
		actor = nil;
		//blockComplete = NO;
	}
	
	return self;
}

- (void)finish {
	CFStringRef mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
	if (mode != NULL) {
		CFRunLoopStop(CFRunLoopGetCurrent());
		CFRelease(mode);
	}
	
	TLRequireInternet(YES);
	/*else {
		[actor storeCompletedSearch:self];
		blockComplete = YES;
	}*/

	TLFinishQuery(actor);
	
	[actor release];
	actor = nil;
}

- (void)didValidateLocation:(NSArray *)locations {
	NSMutableArray *results = [NSMutableArray array];
	for (City *city in locations) {
		SPSearchResult *result = [[[SPSearchResult alloc] init] autorelease];
		[result setTitle:[city name]];
		[result setSummary:TLCleanUpState([city state])];
		[result setUrl:[NSString stringWithFormat:@"http://m.weather.com/weather/today/%@", [city locationID]]];
		//[result setIdentifier:strtoull([[city woeid] UTF8String], NULL, 0)];
		
		[results addObject:result];
	}
	
	TLCommitResults(results, TLDomain(@"com.apple.weather", @"WeatherSearch"), actor);
	[self finish];
}

- (void)didFailWithError:(id)error {
	[self finish];
}

- (void)startSearchWithSearchString:(NSString *)searchString {
	WeatherValidator *validator = [WeatherValidator sharedWeatherValidator];
	[validator setDelegate:self];
	
	if (TLIsOS6) [validator validateLocation:searchString];
	else [validator validateLocation:searchString usingSecondaryService:NO];
}

- (void)performQuery:(SDSearchQuery *)query withResultsPipe:(SDSearchQuery *)results {
	NSString *searchString = [query searchString];
	actor = [results retain];
	
	/*NSString *(*WeatherYQLBaseURL)(void) = reinterpret_cast<NSString *(*)(void)>(dlsym(RTLD_DEFAULT, "WeatherYQLBaseURL"));	
	NSLog(@"WeatherYQLBaseURL=%p; res=%s", WeatherYQLBaseURL, [(*WeatherYQLBaseURL)() UTF8String]);
	if (!IsReachable([(*WeatherYQLBaseURL)() UTF8String])) {
		NSLog(@"Weather: Unreachable! Quit!");
		[self finish];
		return;
	}*/
	
	[self startSearchWithSearchString:searchString];
	TLRequireInternet(YES);

	SInt32 ret = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 5, false);
	if (ret == kCFRunLoopRunTimedOut) { NSLog(@"Timeout! End."); [self finish]; }
}

- (NSArray *)searchDomains {
	return [NSArray arrayWithObject:[NSNumber numberWithInteger:TLDomain(@"com.apple.weather", @"WeatherSearch")]];
}

- (NSString *)displayIdentifierForDomain:(NSInteger)domain {
	return @"com.apple.weather";
}

/*- (BOOL)blockDatastoreComplete {
	return blockComplete;
}*/

- (void)dealloc {
	if (actor != nil) [actor release];
	[super dealloc];
}

+ (void)load {
	NSLog(@"LOADED");
}
@end
