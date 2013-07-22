// Tweak.xm
// extendedwatcher
// Experimental shit for Results/TL.

/*%group TLExtendedHooks
%hook SMSSearchDatastore
- (NSDictionary *)contentToIndexForID:(NSString *)identifier inCategory:(NSString *)category {
	%log;
	return %orig;
}

- (NSArray *)allIdentifiersInCategory:(NSString *)category {
	%log;
	NSArray *k = %orig; NSLog(@"k = %@", k);
	return k;
}
%end
%end

%hook AppIndexer
- (void)beginIndexing { %log; %orig; }
- (id)initWithDisplayID:(NSString *)identifier andCategory:(NSString *)category { %log; return %orig; }
- (id)_loadBundle { %log; id x = %orig; %init(TLExtendedHooks); return x; }
- (NSArray *)_getUpdateIDsFromDatastore:(id)datastore { %log; return %orig; }
%end

MSHook(int, logLevel) {
	return 1;
}

%ctor {
	%init;
	MSHookFunction(MSFindSymbol(NULL, "_logLevel"), (void *)&$logLevel, (void **)&_logLevel);
}*/

/*%hook SDSearchQuery
-(void)storeCompletedSearch:(id)store {
	%log;
	//NSLog(@"%@", [NSThread callStackSymbols]);
	NSLog(@"crash, brb");
	raise(SIGSEGV);
	%orig;
}
%end*/

/*%hook SDClient
- (void)_beginCrashHandlingForStore:(id)store andQuery:(id)query {
	%log;
	%orig;
	[self _endCrashHandling];
}
%end*/

/*%hook SPSpotlightManager
+ (id)sharedManager { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)eraseIndexForApplication:(id)arg1 category:(id)arg2 { %log; %orig; }
- (void)application:(id)arg1 modifiedRecordIDs:(id)arg2 forCategory:(id)arg3 { %log; %orig; }
- (void)appModifiedRecordIDs:(id)arg1 forCategory:(id)arg2 { %log; %orig; }
- (void)_processIdentifiers:(id)arg1 forApplication:(id)arg2 andCategory:(id)arg3 { %log; %orig; }
- (void)dealloc { %log; %orig; }
- (id)init { %log; id r = %orig; NSLog(@" = %@", r); return r; }
%end*/

%hook SBSearchModel
- (void)searchDaemonQueryCompleted:(id)qry { %log; %orig; }
- (void)searchDaemonQuery:(id)qry encounteredError:(id)error { %log; %orig; }
- (void)searchDaemonQuery:(id)qry addedResults:(id)results { %log; %orig; }
%end

%hook SPSearchAgent
- (void)searchDaemonQueryCompleted:(id)qry { %log; %orig; }
%end
