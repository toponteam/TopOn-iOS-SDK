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
#import "ATMintegralBaseManager.h"

@interface ATMintegralInterstitialAdapter()
@property(nonatomic, readonly) id<ATMTGInterstitialVideoAdManager> videoAdManager;
@property(nonatomic, readonly) id<ATMTGInterstitialAdManager> interstitialAdManager;
@property(nonatomic, readonly) id<ATMTGBidInterstitialVideoAdManager> bidInterstitialAdManager;
@property(nonatomic, readonly) ATMintegralInterstitialCustomEvent *customEvent;
@end
@implementation ATMintegralInterstitialAdapter
+(NSDictionary*)headerBiddingParametersWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel extra:(NSDictionary *)extra {
    return @{@"display_manager_ver":@"6.2.0",
             @"unit_id":unitGroupModel.content[@"unitid"] != nil ? unitGroupModel.content[@"unitid"] : @"",
             @"app_id":unitGroupModel.content[@"appid"] != nil ? unitGroupModel.content[@"appid"] : @"",
             @"nw_firm_id":@(unitGroupModel.networkFirmID),
             @"buyeruid":[NSClassFromString(@"MTGBiddingSDK") buyerUID] != nil ? [NSClassFromString(@"MTGBiddingSDK") buyerUID] : @"",
             @"ad_format":@(ATAdFormatInterstitial).stringValue
    };
}

+(void) bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    [ATMintegralBaseManager bidRequestWithPlacementModel:placementModel unitGroupModel:unitGroupModel info:info completion:completion];
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
        [ATMintegralBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary*> *assets, NSError *error))completion {
    if (NSClassFromString(@"MTGInterstitialVideoAdManager") != nil && NSClassFromString(@"MTGInterstitialAdManager") != nil) {
        _customEvent = [[ATMintegralInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
        ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
        if ([serverInfo[@"is_video"] boolValue]) {
            _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
            NSString *requestID = serverInfo[kAdapterCustomInfoRequestIDKey];
            ATBidInfo *bidInfo = [[ATBidInfoManager sharedManager] bidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
            _customEvent.price = bidInfo ? bidInfo.price : unitGroupModel.price;
            _customEvent.bidId = bidInfo ? bidInfo.bidId : @"";
             if (bidInfo != nil) {
                 if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) {
                     [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[serverInfo[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:1 unitId:serverInfo[@"unitid"]];
                 }
                 if (bidInfo.nURL != nil) { dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                     [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:bidInfo.nURL]] resume];
                 });
                 }
                 
                 _bidInterstitialAdManager = [[NSClassFromString(@"MTGBidInterstitialVideoAdManager") alloc] initWithPlacementId:serverInfo[@"placement_id"] unitId:serverInfo[@"unitid"] delegate:_customEvent];
                 [_bidInterstitialAdManager loadAdWithBidToken:bidInfo.bidId];
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
            _customEvent.price = unitGroupModel.price;
            _customEvent.bidId = @"";
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

+(NSString*) adsourceRemoteKeyWithContent:(NSDictionary*)content unitGroupModel:(ATUnitGroupModel *)unitGroupModel {
    return content[@"unitid"];
}

@end
