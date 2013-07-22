@protocol WeatherValidatorDelegate
- (void)didValidateLocation:(NSArray *)results;
- (void)didFailWithError:(id)error;
@end

@interface WeatherXMLHTTPRequest : NSObject <NSURLConnectionDelegate>
@end

@interface WeatherValidator : WeatherXMLHTTPRequest
+ (id)sharedWeatherValidator;
- (void)setDelegate:(id<WeatherValidatorDelegate>)delegate;
- (void)validateLocation:(id)location;
- (void)validateLocation:(id)location usingSecondaryService:(BOOL)use;
@end

#import <Foundation2/NSCalendarDate.h>
@interface City : NSObject
- (NSString *)name;
- (NSString *)displayName;
- (NSString *)locationID;
- (NSString *)zip;
- (NSString *)link;
- (NSString *)state;
- (NSString *)cityAndState;
@property(copy, nonatomic) NSString *woeid;
@property(nonatomic) BOOL isLocalWeatherCity;

- (NSUInteger)bigIcon;

- (NSArray *)dayForecasts;
- (NSArray *)hourlyForecasts;

- (NSInteger)weatherDataAge;
- (NSUInteger)observationTime;
- (NSUInteger)sunsetTime;
- (NSUInteger)sunriseTime;
- (NSUInteger)moonPhase;

- (int)lastUpdateStatus;
- (int)lastUpdateDetail;
- (NSCalendarDate *)updateTime;
- (NSString *)updateTimeString;

- (BOOL)isDataCelsius;
@property(nonatomic) BOOL isHourlyDataCelsius;

- (NSString *)temperature;
@property(nonatomic) float heatIndex;
@property(nonatomic) float feelsLike;
@property(nonatomic) float dewPoint;
@property(nonatomic) int pressureRising;
@property(nonatomic) float pressure;
@property(nonatomic) float visibility;
@property(nonatomic) unsigned int humidity;
@property(nonatomic) unsigned int windSpeed;
@property(nonatomic) unsigned int windDirection;
@property(copy, nonatomic) NSString *windChill;
@end
