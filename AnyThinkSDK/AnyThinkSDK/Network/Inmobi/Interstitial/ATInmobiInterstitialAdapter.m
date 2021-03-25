//
//  ATInmobiInterstitialAdapter.m
//  AnyThinkInmobiInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/8.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATInmobiInterstitialAdapter.h"
#import "ATInmobiInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATAPI+Internal.h"
#import "ATAppSettingManager.h"
#import "ATInmobiBaseManager.h"

@interface ATInmobiInterstitialAdapter()
@property(nonatomic, readonly) ATInmobiInterstitialCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATIMInterstitial> interstitial;
@property(nonatomic, readonly) NSDictionary *info;
@property(nonatomic, readonly) NSDictionary *localInfo;
@property(nonatomic, readonly) void (^LoadCompletionBlock)(NSArray<NSDictionary*> *assets, NSError *error);

@end

// MARK:- ATInmobiInterstitialBiddingDelegate
@interface ATInmobiInterstitialBiddingDelegate : NSObject<ATIMInterstitialDelegate>

@property(nonatomic, readonly) NSMutableDictionary<NSString *, ATInmobiBiddingRequest *> *requests;

@end

@implementation ATInmobiInterstitialBiddingDelegate

+ (instancetype)sharedInstance {
    static ATInmobiInterstitialBiddingDelegate *sharedDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[ATInmobiInterstitialBiddingDelegate alloc] init];
    });
    return sharedDelegate;
}

- (instancetype)init {
    self = [super init];
    _requests = [NSMutableDictionary dictionary];
    return self;
}

- (void)startWithRequestItem:(ATInmobiBiddingRequest *)request {
    [self.requests setValue:request forKey:request.unitID];
    if (NSClassFromString(@"IMInterstitial") != nil && NSClassFromString(@"IMSdk") != nil) {
        [[ATAPI sharedInstance] inspectInitFlagForNetwork:kNetworkNameInmobi usingBlock:^NSInteger(NSInteger currentValue) {
            
            switch (currentValue) {
                case 0:
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInitNotification:) name:kATInmobiSDKInitedNotification object:nil];
                    [ATInmobiBaseManager checkInitiationStatusWithServerInfo:request.customEvent.serverInfo requestItem:request];
                    return 1;
                    break;
                case 1:
                    [[NSNotificationCenter defaultCenter] removeObserver:self];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInitNotification:) name:kATInmobiSDKInitedNotification object:nil];
                    break;
                default:
                    [self startLoadWithRequest:request];
                    break;
            }
            return currentValue;
        }];
   } else {
       request.bidCompletion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Inmobi"]}]);
    }
}

- (void)handleInitNotification:(NSNotification *)notify {
    for (ATInmobiBiddingRequest *request in self.requests.allValues) {
        [self startLoadWithRequest:request];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startLoadWithRequest:(ATInmobiBiddingRequest *)request {
    id<ATIMInterstitial> interstitial = (id<ATIMInterstitial>)[[NSClassFromString(@"IMInterstitial") alloc] initWithPlacementId:[request.unitID longLongValue] delegate:self];
    interstitial.unitID = request.unitID;
    request.customObject = interstitial;
    [interstitial.preloadManager preload];
}

// MARK:- ATIMInterstitialDelegate
- (void)interstitial:(id<ATIMInterstitial>)interstitial didReceiveWithMetaInfo:(id<ATIMAdMetaInfo>)metaInfo {
    ATInmobiBiddingRequest *request = self.requests[interstitial.unitID];
    if (request == nil) {
        return;
    }
    NSString *price = [NSString stringWithFormat:@"%@",metaInfo.bidInfo[ATInMobiBuyerPriceKey]];
    ATBidInfo *bidInfo = [ATBidInfo bidInfoWithPlacementID:request.placementID unitGroupUnitID:request.unitGroup.unitID token:metaInfo.creativeID price:price expirationInterval:request.unitGroup.bidTokenTime customObject:interstitial];
    if (request.bidCompletion) {
        request.bidCompletion(bidInfo, nil);
    }
}

- (void)interstitial:(id<ATIMInterstitial>)interstitial didFailToReceiveWithError:(NSError*)error {
    ATInmobiBiddingRequest *request = self.requests[interstitial.unitID];
    if (request == nil) {
        return;
    }
    if (error && request.bidCompletion) {
        request.bidCompletion(nil, error);
    }
}
@end

static NSString *const kUnitIDKey = @"unit_id";
@implementation ATInmobiInterstitialAdapter

+(BOOL) adReadyWithCustomObject:(id<ATIMInterstitial>)customObject info:(NSDictionary*)info {
    return [customObject isReady];
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    [((id<ATIMInterstitial>)interstitial.customObject) showFromViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATInmobiBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    _info = [NSMutableDictionary dictionaryWithDictionary:serverInfo];
    if (NSClassFromString(@"IMInterstitial") != nil && NSClassFromString(@"IMSdk") != nil) {
        [[ATAPI sharedInstance] inspectInitFlagForNetwork:kNetworkNameInmobi usingBlock:^NSInteger(NSInteger currentValue) {
            if (currentValue == 0) {//not inited
                BOOL set = NO;
                ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                if (set) { [NSClassFromString(@"IMSdk") updateGDPRConsent:@{@"gdpr_consent_available":limit ? @"false" : @"true", @"gdpr":[[ATAPI sharedInstance] inDataProtectionArea] ? @"1" : @"0"}]; }
                [NSClassFromString(@"IMSdk") initWithAccountID:serverInfo[@"app_id"] andCompletionHandler:^(NSError *error) {
                    if (error == nil) {
                        [[ATAPI sharedInstance] setInitFlag:2 forNetwork:kNetworkNameInmobi];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kATInmobiSDKInitedNotification object:serverInfo[kUnitIDKey]];
                        [self loadADUsingInfo:serverInfo localInfo:localInfo completion:completion];
                    } else {
                        completion(nil, error != nil ? error : [NSError errorWithDomain:@"com.anythink.InmobiInterstitialLoading" code:0 userInfo:@{NSLocalizedDescriptionKey:ATSDKAdLoadFailedErrorMsg, NSLocalizedFailureReasonErrorKey:@"IMSDK has failed to initialize"}]);
                    }
                }];
                return 1;
            } else if (currentValue == 1) {//initing
                self->_info = serverInfo;
                self->_localInfo = localInfo;
                self->_LoadCompletionBlock = completion;
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInitNotification:) name:kATInmobiSDKInitedNotification object:nil];
                
                return currentValue;
            } else if (currentValue == 2) {//inited
                [self loadADUsingInfo:serverInfo localInfo:localInfo completion:completion];
                return currentValue;
            }
            return currentValue;
        }];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Inmobi"]}]);
    }
}

-(void) handleInitNotification:(NSNotification*)notification {
    [self loadADUsingInfo:self.info localInfo:self.localInfo completion:self.LoadCompletionBlock];
}

-(void) loadADUsingInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary*> *assets, NSError *error))completion {
    _customEvent = [[ATInmobiInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestNumber = 1;
    _customEvent.requestCompletionBlock = completion;
    
    NSString *requestID = serverInfo[kAdapterCustomInfoRequestIDKey];
    ATUnitGroupModel *unitGroupModel = (ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
    ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
    
    ATBidInfo *bidInfo = [[ATBidInfoManager sharedManager] bidInfoForPlacementID:placementModel.placementID
                            unitGroupModel:unitGroupModel
                            requestID:requestID];
    _customEvent.price = bidInfo ? bidInfo.price : unitGroupModel.price;
    _customEvent.bidID = bidInfo ? bidInfo.bidId : @"";
    
    if (bidInfo) {
        if (bidInfo.nURL) {
          dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:bidInfo.nURL]] resume];
          });
        }
        
        if (bidInfo.customObject) {
            _interstitial = bidInfo.customObject;
            _interstitial.delegate = _customEvent;
            [_interstitial.preloadManager load];
            
            [[ATInmobiInterstitialBiddingDelegate sharedInstance].requests removeObjectForKey:serverInfo[kUnitIDKey]];
            [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
        }
    }else {
        _interstitial = (id<ATIMInterstitial>)[[NSClassFromString(@"IMInterstitial") alloc] initWithPlacementId:[serverInfo[kUnitIDKey] integerValue]  delegate:_customEvent];
        [_interstitial load];
    }
}

// MARK:- bid
+(void) bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    
    if (NSClassFromString(@"IMInterstitial") == nil || NSClassFromString(@"IMSdk") == nil) {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Inmobi"]}]);
        return;
    }
    
    ATInmobiInterstitialCustomEvent *customEvent = [[ATInmobiInterstitialCustomEvent alloc] initWithInfo:info localInfo:nil];
    customEvent.requestNumber = 1;
    
    ATInmobiBiddingRequest *request = [ATInmobiBiddingRequest new];
    request.unitGroup = unitGroupModel;
    request.placementID = placementModel.placementID;
    request.customEvent = customEvent;
    request.bidCompletion = completion;
    request.unitID = info[kUnitIDKey];
    
    ATInmobiInterstitialBiddingDelegate *biddingDelegate = [ATInmobiInterstitialBiddingDelegate sharedInstance];
    [biddingDelegate startWithRequestItem:request];
}

@end
