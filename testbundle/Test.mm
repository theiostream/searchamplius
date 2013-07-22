// Cydia.mm
// by theiostream

#import <Foundation/Foundation.h>
#import <SearchLoader/TLLibrary.h>

/*
extern "C" NSString *const kSPContentTitleKey;
extern "C" NSString *const kSPContentContentKey;
extern "C" NSString *const kSPContentSummaryKey;
*/

@interface TLTestDatastore : NSObject <SPSpotlightDatastore>
@end

@implementation TLTestDatastore
- (NSDictionary *)contentToIndexForID:(NSString *)identifier inCategory:(NSString *)category {
	NSLog(@"-[%@ contentToIndexForID:%@ inCategory:%@]", identifier, category);
	return [NSDictionary dictionaryWithObjectsAndKeys:@"Daniel", kSPContentContentKey, @"Daniel", kSPContentTitleKey, @"Daniel", kSPContentSummaryKey, nil];
}

- (NSArray *)allIdentifiersInCategory:(NSString *)category {
	NSLog(@"-[%@ allIdentifiersInCategory:%@]", category);
	NSArray *r = [NSArray arrayWithObject:@"DANIEL FERREIRA IS AWESOME"];
	
	NSLog(@"r = %@", r);
	return r;
}
@end
