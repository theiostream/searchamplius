@interface XMLHTTPRequest : NSObject <NSURLConnectionDelegate>
@end

@protocol TLSymbolValidatorDelegate;
@interface SymbolValidator : XMLHTTPRequest
- (id)initWithDelegate:(id <TLSymbolValidatorDelegate>)delegate;
- (void)setUsesGTServer:(BOOL)use;
- (void)validateSymbol:(NSString *)symbol withMaxResults:(NSInteger)max;
@end

@protocol TLSymbolValidatorDelegate
- (void)symbolValidator:(SymbolValidator *)validator didValidateSymbols:(NSArray *)symbols;
- (void)symbolValidator:(SymbolValidator *)validator didFailWithError:(id)error;
@end

@interface Stock : NSObject
@property(retain, nonatomic) NSString *symbol;
@property(retain, nonatomic) NSString *companyName;
@property(retain, nonatomic) NSString *exchange;
@end