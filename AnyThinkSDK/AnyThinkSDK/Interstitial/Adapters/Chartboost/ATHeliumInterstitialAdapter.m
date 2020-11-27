//
//  ATHeliumInterstitialAdapter.m
//  AnyThinkChartboostInterstitialAdapter
//
//  Created by stephen on 7/9/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATHeliumInterstitialAdapter.h"
#import "ATHeliumInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
#import "ATThreadSafeAccessor.h"
#import "ATBidInfoManager.h"
#import "ATLogger.h"

NSString * HeliumErrorDesc_ATHeliumInterstitialAd( NSUInteger code ) {
    return @{
        @0:@"HeliumErrorCode_NoAdFound",
        @1:@"HeliumErrorCode_NoBid",
        @2:@"HeliumErrorCode_NoNetwork",
        @3:@"HeliumErrorCode_ServerError",
        @4:@"HeliumErrorCode_PartnerError",
        @5:@"HeliumErrorCode_StartUpError",
        @6:@"HeliumErrorCode_Unknown"}[@(code)];
}

static NSString *const kATHeliumInitNotification = @"com.anythink.HeliumInitNotification";
@interface ATHeliumInterstitialAdapter()
@property(nonatomic, readonly) ATHeliumInterstitialCustomEvent *customEvent;
@property(nonatomic, readonly) void (^LoadCompletionBlock)(NSArray<NSDictionary *> *, NSError *);
@property(nonatomic, readonly) NSDictionary *serverInfo;
@property(nonatomic, readonly) NSDictionary *localInfo;
@end

@interface ATHeliumInterstitialSharedDelegate:NSObject<CHBHeliumInterstitialAdDelegate>
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSMutableDictionary*> *heliumInterstitialAdStorage;
@property(nonatomic, readonly) ATThreadSafeAccessor *heliumInterstitialAdStorageAccessor;
@end

@implementation ATHeliumInterstitialSharedDelegate
+(instancetype) sharedDelegate {
    static ATHeliumInterstitialSharedDelegate *sharedDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[ATHeliumInterstitialSharedDelegate alloc] init];
    });
    return sharedDelegate;
}
-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _heliumInterstitialAdStorage = [NSMutableDictionary<NSString*, NSMutableDictionary*> dictionary];
        _heliumInterstitialAdStorageAccessor = [ATThreadSafeAccessor new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInitNotification:) name:kATHeliumInitNotification object:nil];
    }
    return self;
}

-(void) setHeliumInterstitialAdWithPlacementName:(NSString*)placementName dictionary:(NSMutableDictionary*)dictionary {
    __weak typeof(self) weakSelf = self;
    [_heliumInterstitialAdStorageAccessor writeWithBlock:^{
        [weakSelf.heliumInterstitialAdStorage setValue:dictionary forKey:placementName];
    }];
}

-(NSMutableDictionary *) getHeliumInterstitialAdWithPlacementName:(NSString*)placementName {
    __weak typeof(self) weakSelf = self;

    return [_heliumInterstitialAdStorageAccessor readWithBlock:^id{
        return [weakSelf.heliumInterstitialAdStorage objectForKey:placementName];
    }];
}

-(void) removeHeliumInterstitialAdWithPlacementName:(NSString*)placementName {
    __weak typeof(self) weakSelf = self;
    [_heliumInterstitialAdStorageAccessor writeWithBlock:^{
        [weakSelf.heliumInterstitialAdStorage removeObjectForKey:placementName];
    }];
}

-(void) handleInitNotification:(NSNotification*)notification {
    __weak typeof(self) weakSelf = self;

    [_heliumInterstitialAdStorageAccessor readWithBlock:^id{
        [weakSelf.heliumInterstitialAdStorage enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
//            ATPlacementModel *placementModel = (ATPlacementModel*)obj[@"at_placement_name_model"];
//            ATUnitGroupModel *unitGroupModel = (ATUnitGroupModel*)obj[@"at_unitgroup_model"];
            BOOL hasLoad = [obj[@"at_is_load"] boolValue];
            ATHeliumInterstitialCustomEvent * customEvent = (ATHeliumInterstitialCustomEvent *)obj[@"at_customevent"];
            NSDictionary *info = obj[@"at_info"];
            
            NSDictionary* userInfo = notification.userInfo;
            id<HeliumError> error = userInfo[@"key_error"];
            if(error == nil){
                if(!hasLoad){
                     [self loadAdWithInfo:info];
                }
            }else{
                if(customEvent.BidCompletionBlock != nil){
                    customEvent.BidCompletionBlock(nil, [NSError errorWithDomain:@"com.anythink.HeliumInterstitialHBFailure" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Bid request has failed", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat: @"Helium is initialize failed,reason:%@", HeliumErrorDesc_ATHeliumInterstitialAd(error.errorCode)]}]);
                }else{
                    customEvent.requestCompletionBlock(nil, [NSError errorWithDomain:@"com.anythink.HeliumInterstitialHBFailure" code:1 userInfo:@{NSLocalizedDescriptionKey:@"load request has failed", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat: @"Helium is initialize failed,reason:%@", HeliumErrorDesc_ATHeliumInterstitialAd(error.errorCode)]}]);
                }
                
            }
            
        }];
        return nil;
    }];
}

-(void) loadAdWithInfo:(NSDictionary*)info {
    NSMutableDictionary* cacheDictionary = [self getHeliumInterstitialAdWithPlacementName:info[@"placement_name"]];
    id<HeliumInterstitialAd> interstitialAd = cacheDictionary[@"at_helium_interstitial"];
    ATHeliumInterstitialCustomEvent* customevent = cacheDictionary[@"at_customevent"];
    if(interstitialAd == nil){
        interstitialAd = [(id<ATHeliumSdk>)[NSClassFromString(@"HeliumSdk") sharedHelium] interstitialAdProviderWithDelegate:self andPlacementName:info[@"placement_name"]];
        cacheDictionary[@"at_helium_interstitial"] = interstitialAd;
    }
    customevent.interstitialAd = interstitialAd;
    [interstitialAd loadAd];
}

-(void) initHeliumSDKWithInfo:(NSDictionary*)info unitGroupModel:(ATUnitGroupModel *) unitGroupModel{
    void(^blk)(void) = ^{
        BOOL set = NO;
        [(id<ATHeliumSdk>)[NSClassFromString(@"HeliumSdk") sharedHelium] startWithAppId:info[@"app_id"] andAppSignature:info[@"app_signature"] delegate:self];
        BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
        [(id<ATHeliumSdk>)[NSClassFromString(@"HeliumSdk") sharedHelium] setSubjectToGDPR:!limit];
        [(id<ATHeliumSdk>)[NSClassFromString(@"HeliumSdk") sharedHelium] setUserHasGivenConsent:!limit];
    };
    if ([NSThread currentThread].isMainThread) blk();
    else dispatch_sync(dispatch_get_main_queue(), blk);
}

- (void)heliumDidStartWithError:(id<HeliumError>)error  {
    [ATLogger logMessage:[NSString stringWithFormat:@"HeliumInterstitial::heliumDidStartWithError:error:%@", error != nil ? HeliumErrorDesc_ATHeliumInterstitialAd(error.errorCode) : @""] type:ATLogTypeExternal];
    if (error == nil) {
        [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameHelium];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kATHeliumInitNotification object:nil userInfo:@{@"key_error":error}];
}

- (void)heliumInterstitialAdWithPlacementName:(NSString*)placementName
                             didLoadWithError:(id<HeliumError>)error  {
    [ATLogger logMessage:[NSString stringWithFormat:@"HeliumInterstitial::didLoadWithError:placementName:%@,error:%@", placementName, error != nil ? HeliumErrorDesc_ATHeliumInterstitialAd(error.errorCode) : @""] type:ATLogTypeExternal];
    NSMutableDictionary* cacheDictionary = [self getHeliumInterstitialAdWithPlacementName:placementName];
    ATHeliumInterstitialCustomEvent* customevent = cacheDictionary[@"at_customevent"];
    id<HeliumInterstitialAd> interstitialAd = cacheDictionary[@"at_helium_interstitial"];
    if([cacheDictionary[@"at_is_loaded"] isEqual: @NO]){
        if (error == nil) {
            if(customevent.BidCompletionBlock == nil){
                [customevent trackInterstitialAdLoaded:interstitialAd adExtra:nil];
            }
        } else {
            //when bid return
            if(customevent.BidCompletionBlock != nil){
                customevent.BidCompletionBlock(nil, [NSError errorWithDomain:@"com.anythink.HeliumInterstitalLoading" code:error.errorCode userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to bid", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Helium has failed to cache interstitial with code:%@", HeliumErrorDesc_ATHeliumInterstitialAd(error.errorCode)]}]);
            }else{
                [customevent trackInterstitialAdLoadFailed:[NSError errorWithDomain:@"com.anythink.HeliumInterstitalLoading" code:error.errorCode userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load interstitial", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Helium has failed to cache interstitial with code:%@", HeliumErrorDesc_ATHeliumInterstitialAd(error.errorCode)]}]];
            }
        }
        cacheDictionary[@"at_is_loaded"] = @YES;
    }
    
}
- (void)heliumInterstitialAdWithPlacementName:(NSString*)placementName
                             didShowWithError:(id<HeliumError>)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"HeliumInterstitial::didShowWithError:error:%@", error != nil ? HeliumErrorDesc_ATHeliumInterstitialAd(error.errorCode) : @""] type:ATLogTypeExternal];
    NSMutableDictionary* cacheDictionary = [self getHeliumInterstitialAdWithPlacementName:placementName];
    ATHeliumInterstitialCustomEvent* customevent = cacheDictionary[@"at_customevent"];
//    id<HeliumInterstitialAd> interstitialAd = cacheDictionary[@"at_helium_interstitial"];
    if (error == nil) {
        [customevent trackInterstitialAdShow];
    } else {
        [customevent trackInterstitialAdShowFailed:[NSError errorWithDomain:@"com.anythink.HeliumInterstitialShow" code:error.errorCode userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to show interstitial", NSLocalizedFailureReasonErrorKey:@"Helium SDK has failed to show interstitial"}]];
    }
}
- (void)heliumInterstitialAdWithPlacementName:(NSString*)placementName
                            didCloseWithError:(id<HeliumError>)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"HeliumInterstitial::didCloseWithError:error:%@", error != nil ? HeliumErrorDesc_ATHeliumInterstitialAd(error.errorCode) : @""] type:ATLogTypeExternal];
    NSMutableDictionary* cacheDictionary = [self getHeliumInterstitialAdWithPlacementName:placementName];
    ATHeliumInterstitialCustomEvent* customevent = cacheDictionary[@"at_customevent"];
    if (error == nil) {
        [customevent trackInterstitialAdClose];
    }
}

- (void)heliumInterstitialAdWithPlacementName:(NSString*)placementName
                    didLoadWinningBidWithInfo:(NSDictionary*)bidInfo {
    [ATLogger logMessage:[NSString stringWithFormat:@"HeliumInterstitial::didLoadWinningBidWithInfo:%@", bidInfo] type:ATLogTypeExternal];
    NSMutableDictionary* cacheDictionary = [self getHeliumInterstitialAdWithPlacementName:placementName];
    ATHeliumInterstitialCustomEvent* customevent = cacheDictionary[@"at_customevent"];
    id<HeliumInterstitialAd> interstitialAd = cacheDictionary[@"at_helium_interstitial"];
    if(customevent.BidCompletionBlock != nil){
        NSString *price = [NSString stringWithFormat:@"%@",bidInfo[@"price"]];
//        NSInteger tmpPrice = (NSInteger)(price * 100000000);
        customevent.BidCompletionBlock([ATBidInfo bidInfoWithPlacementID:customevent.placementModel.placementID unitGroupUnitID:customevent.unitGroupModel.unitID token:bidInfo[@"auction-id"] price:price expirationInterval:customevent.unitGroupModel.bidTokenTime customObject:interstitialAd], nil);
        customevent.BidCompletionBlock = nil;
    }
}
- (void)heliumInterstitialAdWithPlacementName:(NSString*)placementName
                            didClickWithError:(id<HeliumError>)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"HeliumInterstitial::didClickWithError:error:%@", error != nil ? HeliumErrorDesc_ATHeliumInterstitialAd(error.errorCode) : @""] type:ATLogTypeExternal];
    NSMutableDictionary* cacheDictionary = [self getHeliumInterstitialAdWithPlacementName:placementName];
    ATHeliumInterstitialCustomEvent* customevent = cacheDictionary[@"at_customevent"];
//    id<HeliumInterstitialAd> interstitialAd = cacheDictionary[@"at_helium_interstitial"];
    if (error == nil) {
        [customevent trackInterstitialAdClick];
    }
}


@end

@implementation ATHeliumInterstitialAdapter

+(void) bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    if (NSClassFromString(@"HeliumSdk") == nil) {
        if (completion != nil) { completion( nil, [NSError errorWithDomain:@"com.anythink.HeliumInterstitialHBFailure" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Bid request has failed", NSLocalizedFailureReasonErrorKey:@"Helium is not imported"}]); }
        return;
    }
    ATHeliumInterstitialSharedDelegate* delegate = [ATHeliumInterstitialSharedDelegate sharedDelegate];
    ATHeliumInterstitialCustomEvent* customEvent = [[ATHeliumInterstitialCustomEvent alloc] initWithInfo:info localInfo:nil];
    customEvent.BidCompletionBlock = completion;
    customEvent.placementModel = placementModel;
    customEvent.unitGroupModel = unitGroupModel;
    
    NSMutableDictionary* cacheDictionary = [delegate getHeliumInterstitialAdWithPlacementName:info[@"placement_name"]];
    if(cacheDictionary == nil){
        cacheDictionary = [[NSMutableDictionary alloc] init];
    }
    cacheDictionary[@"at_placement_name_model"] = placementModel;
    cacheDictionary[@"at_unitgroup_model"] = unitGroupModel;
    cacheDictionary[@"at_customevent"] = customEvent;
    cacheDictionary[@"at_info"] = info;
    cacheDictionary[@"at_is_loaded"] = @NO;
    
    if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameHelium]) {
        //init helium sdk
        
        cacheDictionary[@"at_is_load"] = @NO;
        [delegate setHeliumInterstitialAdWithPlacementName:info[@"placement_name"] dictionary:cacheDictionary];
        
        [delegate initHeliumSDKWithInfo:info unitGroupModel:unitGroupModel];
    }else{
        cacheDictionary[@"at_is_load"] = @YES;
        [delegate setHeliumInterstitialAdWithPlacementName:info[@"placement_name"] dictionary:cacheDictionary];
        
        [delegate loadAdWithInfo:info];
    }
}


+(BOOL) adReadyWithCustomObject:(id<HeliumInterstitialAd>)customObject info:(NSDictionary*)info {
    return [customObject readyToShow];
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    [(id<HeliumInterstitialAd>)(interstitial.customObject) showAdWithViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"HeliumSdk") == nil) {
        if (completion != nil) { completion( nil, [NSError errorWithDomain:@"com.anythink.HeliumInterstitialLoadFailure" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Request has failed", NSLocalizedFailureReasonErrorKey:@"Helium is not imported"}]); }
    }
    _serverInfo = serverInfo;
    _localInfo = localInfo;
    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
    ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
    NSString *requestID = serverInfo[kAdapterCustomInfoRequestIDKey];
    ATBidInfo *bidInfo = [[ATBidInfoManager sharedManager] bidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
    ATHeliumInterstitialSharedDelegate* delegate = [ATHeliumInterstitialSharedDelegate sharedDelegate];
    NSMutableDictionary* cacheDictionary = [delegate getHeliumInterstitialAdWithPlacementName:serverInfo[@"placement_name"]];
    if(cacheDictionary == nil){
        cacheDictionary = [[NSMutableDictionary alloc] init];
    }
    
    if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameHelium]) {
        _customEvent = [[ATHeliumInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.placementModel = placementModel;
        _customEvent.unitGroupModel = unitGroupModel;
        _customEvent.requestCompletionBlock = completion;
        cacheDictionary[@"at_placement_name_model"] = placementModel;
        cacheDictionary[@"at_unitgroup_model"] = unitGroupModel;
        cacheDictionary[@"at_customevent"] = _customEvent;
        cacheDictionary[@"at_info"] = serverInfo;
        cacheDictionary[@"at_is_load"] = @NO;
        cacheDictionary[@"at_is_loaded"] = @NO;
        [delegate setHeliumInterstitialAdWithPlacementName:serverInfo[@"placement_name"] dictionary:cacheDictionary];
        [delegate initHeliumSDKWithInfo:serverInfo unitGroupModel:unitGroupModel];
    }else{
        if(cacheDictionary != nil){
            _customEvent = cacheDictionary[@"at_customevent"];
            _customEvent.requestCompletionBlock = completion;
            if([_customEvent.interstitialAd readyToShow]){
                [_customEvent trackInterstitialAdLoaded:_customEvent.interstitialAd adExtra:@{kAdAssetsPriceKey:bidInfo.price}];
                cacheDictionary[@"at_is_loaded"] = @YES;
            } else {
                [_customEvent.interstitialAd loadAd];
            }
            [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
        }else{
            _customEvent = [[ATHeliumInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
            _customEvent.placementModel = placementModel;
            _customEvent.unitGroupModel = unitGroupModel;
            _customEvent.requestCompletionBlock = completion;
            [delegate loadAdWithInfo:serverInfo];
        }
    }
    
}



@end
