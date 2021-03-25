//
//  ATMyTargetInterstitialAdapter.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/12/25.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATMyTargetInterstitialAdapter.h"
#import "ATMyTargetBaseManager.h"
#import "ATAdManager+Interstitial.h"
#import "ATInterstitial.h"
#import "ATMyTargetInterstitialApis.h"
#import "ATMyTargetInterstitialCustomEvent.h"

@interface ATMyTargetInterstitialAdapter ()

@property(nonatomic, strong) id<ATMTRGInterstitialAd> interstitial;

@end

@implementation ATMyTargetInterstitialAdapter

// MARK:- basic methods
+ (NSDictionary*)headerBiddingParametersWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel extra:(NSDictionary *)extra {
   
    NSString *buyerID = [NSClassFromString(@"MTRGManager") getBidderToken];
    return @{@"display_manager_ver":[NSClassFromString(@"MTRGVersion") currentVersion],
             @"unit_id":unitGroupModel.content[@"slot_id"] ? unitGroupModel.content[@"slot_id"] : @"",
             @"app_id":unitGroupModel.content[@"app_id"] ? unitGroupModel.content[@"app_id"] : @"",
             @"buyeruid":buyerID ? buyerID : @"",
             @"nw_firm_id":@(unitGroupModel.networkFirmID),
             @"ad_format":@(ATAdFormatBanner).stringValue
    };
}

- (instancetype)initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    
    self = [super init];
    if (self != nil) {
        [ATMyTargetBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

- (void)loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    
    Class interstitialClass = NSClassFromString(@"MTRGInterstitialAd");
    if (interstitialClass == nil) {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"MyTarget"]}]);
        return;
    }
    
    
    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
    ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
    NSString *requestID = serverInfo[kAdapterCustomInfoRequestIDKey];
    ATBidInfo *bidInfo = [[ATBidInfoManager sharedManager] bidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
    if (bidInfo.nURL) { dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{ [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:bidInfo.nURL]] resume]; });
    }
//    [(id<ATMTRGAdView>)NSClassFromString(@"MTRGAdView") setDebugMode:YES];
    
    _customEvent = [[ATMyTargetInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.price = bidInfo ? bidInfo.price : unitGroupModel.price;
    _customEvent.bidID = bidInfo.bidId;
    _customEvent.requestCompletionBlock = completion;
    
    self.interstitial = (id<ATMTRGInterstitialAd>)[[interstitialClass alloc] initWithSlotId:[serverInfo[@"slot_id"] integerValue]];
    self.interstitial.delegate = _customEvent;
    if (bidInfo.bidId) {
        [self.interstitial loadFromBid:bidInfo.bidId];
        [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
        return;
    }
    [self.interstitial load];
}

+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return customObject;
}

+ (void)showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    
    ATMyTargetInterstitialCustomEvent *customEvent = (ATMyTargetInterstitialCustomEvent *)interstitial.customEvent;
    customEvent.delegate = delegate;

    id<ATMTRGBaseInterstitialAd> interAd = (id<ATMTRGBaseInterstitialAd>)interstitial.customObject;
    [interAd showWithController:viewController];
}

+ (NSString*)adsourceRemoteKeyWithContent:(NSDictionary*)content unitGroupModel:(ATUnitGroupModel *)unitGroupModel{
    return content[@"slot_id"];
}

@end
