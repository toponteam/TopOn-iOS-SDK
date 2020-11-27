//
//  ATHeliumRewardedVideoAdapter.m
//  AnyThinkChartboostRewardedVideoAdapter
//
//  Created by stephen on 7/9/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATHeliumRewardedVideoAdapter.h"
#import "ATHeliumRewardedVideoCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATRewardedVideoManager.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
#import "ATThreadSafeAccessor.h"
#import "ATBidInfoManager.h"

NSString * HeliumErrorDesc_ATHeliumRewardedVideoAd( NSUInteger code ) {
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
@interface ATHeliumRewardedVideoAdapter()
@property(nonatomic, readonly) ATHeliumRewardedVideoCustomEvent *customEvent;
@property(nonatomic, readonly) void (^LoadCompletionBlock)(NSArray<NSDictionary *> *, NSError *);
@property(nonatomic, readonly) NSDictionary *serverInfo;
@property(nonatomic, readonly) NSDictionary *localInfo;
@end

@interface ATHeliumRewardedVideoSharedDelegate:NSObject<CHBHeliumRewardedAdDelegate>
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSMutableDictionary*> *heliumRewardedVideoAdStorage;
@property(nonatomic, readonly) ATThreadSafeAccessor *heliumRewardedVideoAdStorageAccessor;
@end

@implementation ATHeliumRewardedVideoSharedDelegate
+(instancetype) sharedDelegate {
    static ATHeliumRewardedVideoSharedDelegate *sharedDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[ATHeliumRewardedVideoSharedDelegate alloc] init];
    });
    return sharedDelegate;
}
-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _heliumRewardedVideoAdStorage = [NSMutableDictionary<NSString*, NSMutableDictionary*> dictionary];
        _heliumRewardedVideoAdStorageAccessor = [ATThreadSafeAccessor new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInitNotification:) name:kATHeliumInitNotification object:nil];
    }
    return self;
}

-(void) setHeliumRewardedVideoAdWithPlacementName:(NSString*)placementName dictionary:(NSMutableDictionary*)dictionary {
    __weak typeof(self) weakSelf = self;
    [_heliumRewardedVideoAdStorageAccessor writeWithBlock:^{
        [weakSelf.heliumRewardedVideoAdStorage setValue:dictionary forKey:placementName];
    }];
}

-(NSMutableDictionary *) getHeliumRewardedVideoAdWithPlacementName:(NSString*)placementName {
    __weak typeof(self) weakSelf = self;

    return [_heliumRewardedVideoAdStorageAccessor readWithBlock:^id{
        return [weakSelf.heliumRewardedVideoAdStorage objectForKey:placementName];
    }];
}

-(void) removeHeliumRewardedVideoAdWithPlacementName:(NSString*)placementName {
    __weak typeof(self) weakSelf = self;

    [_heliumRewardedVideoAdStorageAccessor writeWithBlock:^{
        [weakSelf.heliumRewardedVideoAdStorage removeObjectForKey:placementName];
    }];
}

-(void) handleInitNotification:(NSNotification*)notification {
    __weak typeof(self) weakSelf = self;

    [_heliumRewardedVideoAdStorageAccessor readWithBlock:^id{
        [weakSelf.heliumRewardedVideoAdStorage enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
            
//            ATPlacementModel *placementModel = (ATPlacementModel*)obj[@"at_placement_name_model"];
//            ATUnitGroupModel *unitGroupModel = (ATUnitGroupModel*)obj[@"at_unitgroup_model"];
            BOOL hasLoad = [obj[@"at_is_load"] boolValue];
            ATHeliumRewardedVideoCustomEvent * customEvent = (ATHeliumRewardedVideoCustomEvent *)obj[@"at_customevent"];
            NSDictionary *info = obj[@"at_info"];
            
            NSDictionary* userInfo = notification.userInfo;
            id<HeliumError> error = userInfo[@"key_error"];
            if(error == nil){
                if(!hasLoad){
                     [self loadAdWithInfo:info];
                }
            }else{
                if(customEvent.BidCompletionBlock != nil){
                    customEvent.BidCompletionBlock(nil, [NSError errorWithDomain:@"com.anythink.HeliumInterstitialHBFailure" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Bid request has failed", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat: @"Helium is initialize failed,reason:%@", HeliumErrorDesc_ATHeliumRewardedVideoAd(error.errorCode)]}]);
                }else{
                    customEvent.requestCompletionBlock(nil, [NSError errorWithDomain:@"com.anythink.HeliumInterstitialHBFailure" code:1 userInfo:@{NSLocalizedDescriptionKey:@"load request has failed", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat: @"Helium is initialize failed,reason:%@", HeliumErrorDesc_ATHeliumRewardedVideoAd(error.errorCode)]}]);
                }
                
            }
            
        }];
        return nil;
    }];
}

-(void) loadAdWithInfo:(NSDictionary*)info {
    NSMutableDictionary* cacheDictionary = [self getHeliumRewardedVideoAdWithPlacementName:info[@"placement_name"]];
    id<HeliumRewardedAd> rewardedAd = cacheDictionary[@"at_helium_rewardad"];
    ATHeliumRewardedVideoCustomEvent* customevent = cacheDictionary[@"at_customevent"];
    if(rewardedAd == nil){
        rewardedAd = [(id<ATHeliumSdk>)[NSClassFromString(@"HeliumSdk") sharedHelium] rewardedAdProviderWithDelegate:self andPlacementName:info[@"placement_name"]];
        cacheDictionary[@"at_helium_rewardad"] = rewardedAd;
    }
    customevent.rewardedAd = rewardedAd;
    [rewardedAd loadAd];
}


-(void) initHeliumSDKWithInfo:(NSDictionary*)info unitGroupModel:(ATUnitGroupModel *) unitGroupModel{
    void(^blk)(void) = ^{
        BOOL set = NO;
        BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
        [(id<ATHeliumSdk>)[NSClassFromString(@"HeliumSdk") sharedHelium] setSubjectToGDPR:!limit];
        [(id<ATHeliumSdk>)[NSClassFromString(@"HeliumSdk") sharedHelium] setUserHasGivenConsent:!limit];
        [(id<ATHeliumSdk>)[NSClassFromString(@"HeliumSdk") sharedHelium] startWithAppId:info[@"app_id"] andAppSignature:info[@"app_signature"] delegate:self];
    };
    if ([NSThread currentThread].isMainThread) blk();
    else dispatch_sync(dispatch_get_main_queue(), blk);
}

- (void)heliumDidStartWithError:(id<HeliumError>)error  {
    [ATLogger logMessage:[NSString stringWithFormat:@"HeliumRewardedVideo::heliumDidStartWithError:error:%@", error != nil ? HeliumErrorDesc_ATHeliumRewardedVideoAd(error.errorCode) : @""] type:ATLogTypeExternal];
    if (error == nil) {
        [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameHelium];
        [[NSNotificationCenter defaultCenter] postNotificationName:kATHeliumInitNotification object:nil];
    }
}


- (void)heliumRewardedAdWithPlacementName:(NSString*)placementName
                         didLoadWithError:(id<HeliumError>)error  {
    [ATLogger logMessage:[NSString stringWithFormat:@"HeliumRewardedVideo::didLoadWithError:placementName:%@,error:%@", placementName, error != nil ? HeliumErrorDesc_ATHeliumRewardedVideoAd(error.errorCode) : @""] type:ATLogTypeExternal];
    NSMutableDictionary* cacheDictionary = [self getHeliumRewardedVideoAdWithPlacementName:placementName];
    ATHeliumRewardedVideoCustomEvent* customevent = cacheDictionary[@"at_customevent"];
    id<HeliumRewardedAd> rewardedAd = cacheDictionary[@"at_helium_rewardad"];
    if([cacheDictionary[@"at_is_loaded"] isEqual:@NO]){
        if (error == nil) {
            if(customevent.BidCompletionBlock == nil){
                [customevent trackRewardedVideoAdLoaded:rewardedAd adExtra:nil];
            }
            
        } else {
            //when bid return
            if(customevent.BidCompletionBlock != nil){
                customevent.BidCompletionBlock(nil, [NSError errorWithDomain:@"com.anythink.HeliumInterstitalLoading" code:error.errorCode userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to bid", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Helium has failed to cache interstitial with code:%@", HeliumErrorDesc_ATHeliumRewardedVideoAd(error.errorCode)]}]);
                customevent.BidCompletionBlock = nil;
            }else{
                [customevent trackRewardedVideoAdLoadFailed:[NSError errorWithDomain:@"com.anythink.HeliumRewardedLoading" code:error.errorCode userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load rewardedad", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Helium has failed to cache rewardedad with code:%@", HeliumErrorDesc_ATHeliumRewardedVideoAd(error.errorCode)]}]];
            }
        }
        cacheDictionary[@"at_is_loaded"] = @YES;
    }
    
}
- (void)heliumRewardedAdWithPlacementName:(NSString*)placementName
                         didShowWithError:(id<HeliumError>)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"HeliumRewardedVideo::didShowWithError:error:%@", error != nil ? HeliumErrorDesc_ATHeliumRewardedVideoAd(error.errorCode) : @""] type:ATLogTypeExternal];
    NSMutableDictionary* cacheDictionary = [self getHeliumRewardedVideoAdWithPlacementName:placementName];
    ATHeliumRewardedVideoCustomEvent* customevent = cacheDictionary[@"at_customevent"];
    if (error == nil) {
        [customevent trackRewardedVideoAdShow];
        [customevent trackRewardedVideoAdVideoStart];
    }else {
        [customevent trackRewardedVideoAdPlayEventWithError:[NSError errorWithDomain:@"com.anythink.HeliumRewardedVideoShow" code:error.errorCode userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to show rewardedad", NSLocalizedFailureReasonErrorKey:@"Helium SDK has failed to show rewardedad"}]];
    }
}
- (void)heliumRewardedAdWithPlacementName:(NSString*)placementName
                        didCloseWithError:(id<HeliumError>)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"HeliumRewardedVideo::didCloseWithError:error:%@", error != nil ? HeliumErrorDesc_ATHeliumRewardedVideoAd(error.errorCode) : @""] type:ATLogTypeExternal];
    NSMutableDictionary* cacheDictionary = [self getHeliumRewardedVideoAdWithPlacementName:placementName];
    ATHeliumRewardedVideoCustomEvent* customevent = cacheDictionary[@"at_customevent"];
    if (error == nil) {
        [customevent trackRewardedVideoAdVideoEnd];
        [customevent trackRewardedVideoAdCloseRewarded:customevent.rewardGranted];
    }
}

- (void)heliumRewardedAdWithPlacementName:(NSString*)placementName
                             didGetReward:(NSInteger)reward {
    NSMutableDictionary* cacheDictionary = [self getHeliumRewardedVideoAdWithPlacementName:placementName];
    ATHeliumRewardedVideoCustomEvent* customevent = cacheDictionary[@"at_customevent"];
    [customevent trackRewardedVideoAdRewarded];
}
- (void)heliumRewardedAdWithPlacementName:(NSString*)placementName
                didLoadWinningBidWithInfo:(NSDictionary*)bidInfo {
    NSMutableDictionary* cacheDictionary = [self getHeliumRewardedVideoAdWithPlacementName:placementName];
    ATHeliumRewardedVideoCustomEvent* customevent = cacheDictionary[@"at_customevent"];
    id<HeliumRewardedAd> rewardedAd = cacheDictionary[@"at_helium_rewardad"];
    if(customevent.BidCompletionBlock != nil){
        NSString *price = [NSString stringWithFormat:@"%@",bidInfo[@"price"]];
        customevent.BidCompletionBlock([ATBidInfo bidInfoWithPlacementID:customevent.placementModel.placementID unitGroupUnitID:customevent.unitGroupModel.unitID token:bidInfo[@"auction-id"] price:price expirationInterval:customevent.unitGroupModel.bidTokenTime customObject:rewardedAd], nil);
        customevent.BidCompletionBlock = nil;
    }
}
- (void)heliumRewardedAdWithPlacementName:(NSString*)placementName
                        didClickWithError:(id<HeliumError>)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"HeliumRewardedVideo::didClickWithError:error:%@", error != nil ? HeliumErrorDesc_ATHeliumRewardedVideoAd(error.errorCode) : @""] type:ATLogTypeExternal];
    NSMutableDictionary* cacheDictionary = [self getHeliumRewardedVideoAdWithPlacementName:placementName];
    ATHeliumRewardedVideoCustomEvent* customevent = cacheDictionary[@"at_customevent"];
    if (error == nil) {
        [customevent trackRewardedVideoAdClick];
    }
}

@end

@implementation ATHeliumRewardedVideoAdapter

+(void) bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    if (NSClassFromString(@"HeliumSdk") == nil) {
        if (completion != nil) { completion( nil, [NSError errorWithDomain:@"com.anythink.HeliumRewardedVideoHBFailure" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Bid request has failed", NSLocalizedFailureReasonErrorKey:@"Helium is not imported"}]); }
    }
    ATHeliumRewardedVideoSharedDelegate* delegate = [ATHeliumRewardedVideoSharedDelegate sharedDelegate];
    ATHeliumRewardedVideoCustomEvent* customEvent = [[ATHeliumRewardedVideoCustomEvent alloc] initWithInfo:info localInfo:nil];
    customEvent.BidCompletionBlock = completion;
    customEvent.placementModel = placementModel;
    customEvent.unitGroupModel = unitGroupModel;
    
    NSMutableDictionary* cacheDictionary = [delegate getHeliumRewardedVideoAdWithPlacementName:info[@"placement_name"]];
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
        [delegate setHeliumRewardedVideoAdWithPlacementName:info[@"placement_name"] dictionary:cacheDictionary];
        
        [delegate initHeliumSDKWithInfo:info unitGroupModel:unitGroupModel];
    }else{
        cacheDictionary[@"at_is_load"] = @YES;
        [delegate setHeliumRewardedVideoAdWithPlacementName:info[@"placement_name"] dictionary:cacheDictionary];
        
        [delegate loadAdWithInfo:info];
    }
}


+(BOOL) adReadyWithCustomObject:(id<HeliumRewardedAd>)customObject info:(NSDictionary*)info {
    return [customObject readyToShow];
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    rewardedVideo.customEvent.delegate = delegate;
    [(id<HeliumRewardedAd>)(rewardedVideo.customObject) showAdWithViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"HeliumSdk") == nil) {
        if (completion != nil) { completion( nil, [NSError errorWithDomain:@"com.anythink.HeliumRewardedVideoLoadFailure" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Request has failed", NSLocalizedFailureReasonErrorKey:@"Helium is not imported"}]); }
    }
    _serverInfo = serverInfo;
    _localInfo = localInfo;
    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
    ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
    NSString *requestID = serverInfo[kAdapterCustomInfoRequestIDKey];
    ATBidInfo *bidInfo = [[ATBidInfoManager sharedManager] bidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
    ATHeliumRewardedVideoSharedDelegate* delegate = [ATHeliumRewardedVideoSharedDelegate sharedDelegate];
    NSMutableDictionary* cacheDictionary = [delegate getHeliumRewardedVideoAdWithPlacementName:serverInfo[@"placement_name"]];
    if(cacheDictionary == nil){
        cacheDictionary = [[NSMutableDictionary alloc] init];
    }
    
    
    if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameHelium]) {
        _customEvent = [[ATHeliumRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.placementModel = placementModel;
        _customEvent.unitGroupModel = unitGroupModel;
        _customEvent.requestCompletionBlock = completion;
        cacheDictionary[@"at_placement_name_model"] = placementModel;
        cacheDictionary[@"at_unitgroup_model"] = unitGroupModel;
        cacheDictionary[@"at_customevent"] = _customEvent;
        cacheDictionary[@"at_info"] = serverInfo;
        cacheDictionary[@"at_is_load"] = @NO;
        cacheDictionary[@"at_is_loaded"] = @NO;
        [delegate setHeliumRewardedVideoAdWithPlacementName:serverInfo[@"placement_name"] dictionary:cacheDictionary];
        [delegate initHeliumSDKWithInfo:serverInfo unitGroupModel:unitGroupModel];
    }else{
        if(cacheDictionary != nil){
            _customEvent = cacheDictionary[@"at_customevent"];
            _customEvent.requestCompletionBlock = completion;
            if([_customEvent.rewardedAd readyToShow]){
                [_customEvent trackRewardedVideoAdLoaded:_customEvent.rewardedAd adExtra:@{kAdAssetsPriceKey:bidInfo.price}];
                cacheDictionary[@"at_is_loaded"] = @YES;
            } else {
                [_customEvent.rewardedAd loadAd];
            }
            [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
        }else{
            _customEvent = [[ATHeliumRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
            _customEvent.placementModel = placementModel;
            _customEvent.unitGroupModel = unitGroupModel;
            _customEvent.requestCompletionBlock = completion;
            [delegate loadAdWithInfo:serverInfo];
        }
    }
    
}



@end
