/*%%%%%
%% Maps.m
%% Maps plugin for Spotlight by theiostream
%% (c) 2013 Bacon Coding Company, LLC
%% Blame CLGeocoder for map issues.
%%%%%*/

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/ABPerson.h>
#import <SearchLoader/TLLibrary.h>

@interface TLMapsDatastore: NSObject <TLSearchDatastore> {
	BOOL $isProcessing;
}
@end

@implementation TLMapsDatastore
- (void)performQuery:(SDSearchQuery *)query withResultsPipe:(SDSearchQuery *)results {
	NSString *searchString = [query searchString];
	CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];

	$isProcessing = YES;
	TLRequireInternet(YES);

	[geocoder geocodeAddressString:searchString completionHandler:^(NSArray *placemarks, NSError *error){
		for (CLPlacemark *placemark in placemarks) {
			CLLocationCoordinate2D location = [[placemark location] coordinate];
			
			NSArray *content = [NSArray arrayWithObjects:
				(id)[placemark name] ?: (id)[NSNull null],
				(id)[placemark thoroughfare] ? [NSString stringWithFormat:@"%@%@", [[placemark subThoroughfare] stringByAppendingString:@" "] ?: @"", [placemark thoroughfare]] : (id)[NSNull null],
				(id)[placemark subLocality] ?: (id)[NSNull null],
				(id)[placemark locality] ?: (id)[NSNull null],
				(id)[placemark subAdministrativeArea] ?: (id)[NSNull null],
				(id)[placemark administrativeArea] ?: (id)[NSNull null],
				(id)[placemark country] ?: (id)[NSNull null],
				(id)[placemark ocean] ?: (id)[NSNull null],
				[NSString stringWithFormat:@"(%g, %g)", location.latitude, location.longitude],
				[NSString string],
				nil];

			unsigned int element = 0;
			while (element < [content count]) {
				if ([content objectAtIndex:element] != [NSNull null]) break;
				element++;
			}

			int subtitleElement[8] = { 1, 3, 3, 4, 5, 6, -1, -1 };
			int summaryElement[8] =  { 3, 5, 5, 5, 6, -1, -1, -1 };
			
			NSLog(@"element=%d subtitleElement=%d summaryElement=%d", element, subtitleElement[element], summaryElement[element]);
			
			// dude i need to clean this up
			SPSearchResult *result = [[[SPSearchResult alloc] init] autorelease];
			[result setTitle:[content objectAtIndex:element]];
			[result setSubtitle:(subtitleElement[element] < 0 ? nil : [content objectAtIndex:subtitleElement[element]] != [NSNull null] ? [content objectAtIndex:subtitleElement[element]] : @"Unknown")];
			[result setSummary:(summaryElement[element] < 0 ? nil : [NSString stringWithFormat:@"%@ %@", [content objectAtIndex:summaryElement[element]] != [NSNull null] ? [content objectAtIndex:summaryElement[element]] : @"Unknown", (element>0 && element<4 ? [NSString stringWithFormat:@"(%@)", [placemark ISOcountryCode] ?: @"Unknown"] : @"")])];
			
			NSString *url = [NSString stringWithFormat:@"http://maps.apple.com/?q=%g,%g", location.latitude, location.longitude];
			if (TLIsOS6) [result setUrl:url];
			else [result setURL:[NSURL URLWithString:url]];

			TLCommitResults([NSArray arrayWithObject:result], TLDomain(@"com.apple.Maps", @"MapsSearch"), results);
		}

		TLRequireInternet(NO);
		$isProcessing = NO;
		[results storeCompletedSearch:self];

		TLFinishQuery(results);
	}];
}

- (NSArray *)searchDomains {
	return [NSArray arrayWithObject:[NSNumber numberWithInteger:TLDomain(@"com.apple.Maps", @"MapsSearch")]];
}

- (NSString *)displayIdentifierForDomain:(NSInteger)domain {
	return @"com.apple.Maps";
}

- (BOOL)blockDatastoreComplete {
	return $isProcessing;
}
@end
