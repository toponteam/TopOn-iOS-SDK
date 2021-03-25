//
//  ATInmobiBannerAdapter.m
//  AnyThinkInmobiBannerAdapter
//
//  Created by Martin Lau on 2018/10/8.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATInmobiBannerAdapter.h"
#import "ATInmobiBannerCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
#import "ATInmobiBaseManager.h"

@interface ATInmobiBannerAdapter()
@property(nonatomic, readonly) id<ATIMBanner> banner;
@property(nonatomic, readonly) ATInmobiBannerCustomEvent *customEvent;
@property(nonatomic, readonly) NSDictionary *info;
@property(nonatomic, readonly) NSDictionary *localInfo;
@property(nonatomic, readonly) void (^LoadCompletionBlock)(NSArray<NSDictionary*> *assets, NSError *error);

@end

// MARK:- ATInmobiBannerBiddingDelegate
@interface ATInmobiBannerBiddingDelegate : NSObject<IMBannerDelegate>

@property(nonatomic, readonly) NSMutableDictionary<NSString *, ATInmobiBiddingRequest *> *requests;

@end

@implementation ATInmobiBannerBiddingDelegate

+ (instancetype)sharedInstance {
    static ATInmobiBannerBiddingDelegate *sharedDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[ATInmobiBannerBiddingDelegate alloc] init];
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
    if (NSClassFromString(@"IMBanner") != nil && NSClassFromString(@"IMSdk") != nil) {
        [[ATAPI sharedInstance] inspectInitFlagForNetwork:kNetworkNameInmobi usingBlock:^NSInteger(NSInteger currentValue) {
            
            switch (currentValue) {
                case 0:
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInitNotification:) name:kATInmobiSDKInitedNotification object:nil];
                    [ATInmobiBaseManager checkInitiationStatusWithServerInfo:request.serverInfo requestItem:request];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        id<ATIMBanner> banner = [[NSClassFromString(@"IMBanner") alloc] initWithFrame:request.bannerFrame placementId:[request.unitID longLongValue]];
        request.customObject = banner;
        banner.unitID = request.unitID;
        banner.delegate = self;
        banner.refreshInterval = request.refreshInterval;
        [banner.preloadManager preload];
    });
}


// IMBannerDelegate
- (void)banner:(id<ATIMBanner>)banner didReceiveWithMetaInfo:(id<ATIMAdMetaInfo>)info {
    ATInmobiBiddingRequest *request = self.requests[banner.unitID];
    if (request == nil) {
        return;
    }
    NSString *price = [NSString stringWithFormat:@"%@",info.bidInfo[ATInMobiBuyerPriceKey]];
    ATBidInfo *bidInfo = [ATBidInfo bidInfoWithPlacementID:request.placementID unitGroupUnitID:request.unitGroup.unitID token:info.creativeID price:price expirationInterval:request.unitGroup.bidTokenTime customObject:banner];
    if (request.bidCompletion) {
        request.bidCompletion(bidInfo, nil);
    }
}

- (void)banner:(id<ATIMBanner>)banner didFailToReceiveWithError:(id)error {
    ATInmobiBiddingRequest *request = self.requests[banner.unitID];
    if (request == nil) {
        return;
    }
    if (error && request.bidCompletion) {
        request.bidCompletion(nil, error);
    }
}

@end

// MARK:- ATInmobiBannerAdapter

static NSString *const kUnitIDKey = @"unit_id";
@implementation ATInmobiBannerAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATInmobiBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"IMBanner") != nil && NSClassFromString(@"IMSdk") != nil) {
        [[ATAPI sharedInstance] inspectInitFlagForNetwork:kNetworkNameInmobi usingBlock:^NSInteger(NSInteger currentValue) {
            if (currentValue == 0) {//not inited
                BOOL set = NO;
                ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                if (set) { [NSClassFromString(@"IMSdk") updateGDPRConsent:@{@"gdpr_consent_available":limit ? @"false" : @"true", @"gdpr":[[ATAPI sharedInstance] inDataProtectionArea] ? @"1" : @"0"}]; }
                [NSClassFromString(@"IMSdk") initWithAccountID:serverInfo[@"app_id"] andCompletionHandler:^(NSError *error) {
                    if (error == nil) {
                        [[ATAPI sharedInstance] setInitFlag:2 forNetwork:kNetworkNameInmobi];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kATInmobiSDKInitedNotification object:nil];
                        [self loadADUsingInfo:serverInfo localInfo:localInfo completion:completion];
                    } else {
                        completion(nil, error != nil ? error : [NSError errorWithDomain:@"com.anythink.InmobiBannerLoading" code:0 userInfo:@{NSLocalizedDescriptionKey:ATSDKAdLoadFailedErrorMsg, NSLocalizedFailureReasonErrorKey:@"IMSDK has failed to initialize"}]);
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
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Inmobi"]}]);
    }
}

-(void) handleInitNotification:(NSNotification*)notification {
    [self loadADUsingInfo:self.info localInfo:self.localInfo completion:self.LoadCompletionBlock];
}

-(void) loadADUsingInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary*> *assets, NSError *error))completion {
    _customEvent = [[ATInmobiBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    
    ATUnitGroupModel *unitGroupModel = (ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
    ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
    NSString *requestID = serverInfo[kAdapterCustomInfoRequestIDKey];
      
    ATBidInfo *bidInfo = [[ATBidInfoManager sharedManager] bidInfoForPlacementID:placementModel.placementID
                            unitGroupModel:unitGroupModel
                            requestID:requestID];
    _customEvent.price = bidInfo ? bidInfo.price : unitGroupModel.price;
    _customEvent.bidID = bidInfo ? bidInfo.bidId : @"";
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (bidInfo) {
            if (bidInfo.nURL) {
              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:bidInfo.nURL]] resume];
              });
            }
            
            self->_banner = bidInfo.customObject;
            self->_banner.delegate = self->_customEvent;
            [self->_banner.preloadManager load];
            
            [[ATInmobiBannerBiddingDelegate sharedInstance].requests removeObjectForKey:serverInfo[kUnitIDKey]];
            [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
            return;
        }else{
            self->_banner = [[NSClassFromString(@"IMBanner") alloc] initWithFrame:CGRectMake(.0f, .0f, unitGroupModel.adSize.width, unitGroupModel.adSize.height) placementId:[serverInfo[kUnitIDKey] longLongValue] delegate:self->_customEvent];
            self->_banner.refreshInterval = [serverInfo[@"nw_rft"] integerValue] / 1000;
            [self->_banner load];
        }
    });
}

// MARK:- bid
+(void) bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    
    if (NSClassFromString(@"IMBanner") == nil || NSClassFromString(@"IMSdk") == nil) {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Inmobi"]}]);
        return;
    }
    
    NSInteger interval = [info[@"nw_rft"] integerValue] / 1000;
    ATInmobiBannerCustomEvent *customEvent = [[ATInmobiBannerCustomEvent alloc] initWithInfo:info localInfo:nil];
    
    ATInmobiBiddingRequest *request = [ATInmobiBiddingRequest new];
    request.unitGroup = unitGroupModel;
    request.placementID = placementModel.placementID;
    request.customEvent = customEvent;
    request.bidCompletion = completion;
    request.unitID = info[kUnitIDKey];
    request.bannerFrame = CGRectMake(.0f, .0f, unitGroupModel.adSize.width, unitGroupModel.adSize.height);
    request.refreshInterval = interval;
    
    [[ATInmobiBannerBiddingDelegate sharedInstance] startWithRequestItem:request];
}

+(void) showBanner:(ATBanner*)banner inView:(UIView*)view presentingViewController:(UIViewController*)viewController {
    id<ATIMBanner> bannerAd = (id<ATIMBanner>)banner.customObject;
    [view addSubview:(UIView*)bannerAd];
}

@end

