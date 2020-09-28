//
//  ATMintegralInterstitialAdapter.m
//  AnyThinkMintegralInterstitialAdapter
//
//  Created by Martin Lau on 25/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMintegralInterstitialAdapter.h"
#import "ATMintegralInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
#import "ATCapsManager.h"
#import <objc/runtime.h>
#import "ATBidInfo.h"
#import "ATBidInfoManager.h"
#import "ATNetworkingManager.h"

@interface ATMintegralInterstitialAdapter()
@property(nonatomic, readonly) id<ATMTGInterstitialVideoAdManager> videoAdManager;
@property(nonatomic, readonly) id<ATMTGInterstitialAdManager> interstitialAdManager;
@property(nonatomic, readonly) id<ATMTGBidInterstitialVideoAdManager> bidInterstitialAdManager;
@property(nonatomic, readonly) ATMintegralInterstitialCustomEvent *customEvent;
@end
@implementation ATMintegralInterstitialAdapter
+(NSDictionary*)headerBiddingParametersWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel {
    return @{@"display_manager_ver":@"6.2.0",
             @"unit_id":unitGroupModel.content[@"unitid"] != nil ? unitGroupModel.content[@"unitid"] : @"",
             @"app_id":unitGroupModel.content[@"appid"] != nil ? unitGroupModel.content[@"appid"] : @"",
             @"nw_firm_id":@(unitGroupModel.networkFirmID),
             @"buyeruid":[NSClassFromString(@"MTGBiddingSDK") buyerUID] != nil ? [NSClassFromString(@"MTGBiddingSDK") buyerUID] : @"",
             @"ad_format":@(ATAdFormatInterstitial).stringValue
    };
}

+(void) bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMintegral]) {
        [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"MTGSDK") sdkVersion] forNetwork:kNetworkNameMintegral];
        [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMintegral];
        void(^blk)(void) = ^{
            BOOL set = NO;
            BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
            if (set) { ((id<ATMTGSDK>)[NSClassFromString(@"MTGSDK") sharedInstance]).consentStatus = !limit; }
            [[NSClassFromString(@"MTGSDK") sharedInstance] setAppID:info[@"appid"] ApiKey:info[@"appkey"]];
        };
        if ([NSThread currentThread].isMainThread) blk();
        else dispatch_sync(dispatch_get_main_queue(), blk);
    }
    
    if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) { [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[info[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:2 unitId:info[@"unitid"]]; }
    [NSClassFromString(@"MTGBiddingRequest") getBidWithRequestParameter:[[NSClassFromString(@"MTGBiddingRequestParameter") alloc] initWithPlacementId:info[@"placement_id"] unitId:info[@"unitid"] basePrice:@0] completionHandler:^(id<ATMTGBiddingResponse> bidResponse) {
        if (completion != nil) { completion(bidResponse.success ? [ATBidInfo bidInfoWithPlacementID:placementModel.placementID unitGroupUnitID:unitGroupModel.unitID token:bidResponse.bidToken price:bidResponse.price expirationInterval:unitGroupModel.bidTokenTime customObject:bidResponse] : nil, bidResponse.success ? nil : (bidResponse.error != nil ? bidResponse.error : [NSError errorWithDomain:@"com.anythink.MTGInterstitialHBFailure" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Bid request has failed", NSLocalizedFailureReasonErrorKey:@"MTGSDK has failed to get bid info"}])); }
    }];
}

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    if ([customObject respondsToSelector:@selector(isVideoReadyToPlay:)]) {
        return [customObject isVideoReadyToPlay:info[@"unitid"]];
    } else {
        return customObject != nil;
    }
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    id mtgInterstitial = interstitial.customObject;
    
    if ([mtgInterstitial respondsToSelector:@selector(showWithDelegate:presentingViewController:)]) {
        [mtgInterstitial showWithDelegate:(ATMintegralInterstitialCustomEvent*)interstitial.customEvent presentingViewController:viewController];
    } else if ([mtgInterstitial respondsToSelector:@selector(showFromViewController:)]) {
        [mtgInterstitial showFromViewController:viewController];
    }
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"MTGSDK") sdkVersion] forNetwork:kNetworkNameMintegral];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMintegral]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMintegral];
                void(^blk)(void) = ^{
                    BOOL set = NO;
                    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                    BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                    if (set) { ((id<ATMTGSDK>)[NSClassFromString(@"MTGSDK") sharedInstance]).consentStatus = !limit; }
                    [[NSClassFromString(@"MTGSDK") sharedInstance] setAppID:serverInfo[@"appid"] ApiKey:serverInfo[@"appkey"]];
                };
                if ([NSThread currentThread].isMainThread) blk();
                else dispatch_sync(dispatch_get_main_queue(), blk);
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary*> *assets, NSError *error))completion {
    if (NSClassFromString(@"MTGInterstitialVideoAdManager") != nil && NSClassFromString(@"MTGInterstitialAdManager") != nil) {
        _customEvent = [[ATMintegralInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        if ([serverInfo[@"is_video"] boolValue]) {
            _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
            ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
            ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
            NSString *requestID = serverInfo[kAdapterCustomInfoRequestIDKey];
            ATBidInfo *bidInfo = [[ATBidInfoManager sharedManager] bidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
             if (bidInfo != nil) {
                 if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) {
                     [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[serverInfo[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:1 unitId:serverInfo[@"unitid"]];
                 }
                 if (bidInfo.nURL != nil) { dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{ [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:bidInfo.nURL]] resume]; }); }
                 
                 _customEvent.price = bidInfo.price;
                 _bidInterstitialAdManager = [[NSClassFromString(@"MTGBidInterstitialVideoAdManager") alloc] initWithPlacementId:serverInfo[@"placement_id"] unitId:serverInfo[@"unitid"] delegate:_customEvent];
                 [_bidInterstitialAdManager loadAdWithBidToken:bidInfo.token];
                 [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
            } else {
                if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) {
                    [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[serverInfo[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:0 unitId:serverInfo[@"unitid"]];
                }
                _videoAdManager = [[NSClassFromString(@"MTGInterstitialVideoAdManager") alloc] initWithPlacementId:serverInfo[@"placement_id"] unitId:serverInfo[@"unitid"] delegate:_customEvent];
                _videoAdManager.delegate = _customEvent;
                [_videoAdManager loadAd];
            }
        } else {
            if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) {
                [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[serverInfo[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:0 unitId:serverInfo[@"unitid"]];
            }
            _interstitialAdManager = [[NSClassFromString(@"MTGInterstitialAdManager") alloc] initWithPlacementId:serverInfo[@"placement_id"] unitId:serverInfo[@"unitid"] adCategory:0];
            [_interstitialAdManager loadWithDelegate:_customEvent];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Mintegral"]}]);
    }
}

@end
