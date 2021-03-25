//
//  ATOnlineApiBannerCustomEvent.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/22.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiBannerCustomEvent.h"
#import "ATOnlineApiBannerDelegate.h"
#import "ATOnlineApiLoadingDelegate.h"
#import "ATLogger.h"
#import "ATOfferBannerView.h"
#import "ATOnlineApiLoader.h"
#import "ATOnlineApiBannerAdManager.h"
#import "ATBannerManager.h"
#import "ATOnlineApiOfferModel.h"
#import "Utilities.h"

@interface ATOnlineApiBannerCustomEvent ()<ATOnlineApiLoadingDelegate>

@end

@implementation ATOnlineApiBannerCustomEvent

// MARK:- ATOnlineApiLoadingDelegate
- (void)didLoadADSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID {
    [ATLogger logMessage:[NSString stringWithFormat:@"ATOnlineApiBannerCustomEvent::didLoadADSuccessWithPlacementID:%@ unitId:%@", placementID, unitID] type:ATLogTypeExternal];
    
    ATOnlineApiOfferModel *model =  [[ATOnlineApiLoader sharedLoader] readyOnlineApiAdWithUnitGroupModelID:self.unitGroupModel.unitID placementID:placementID];
    self.offerModel = model;
    ATOfferBannerView *banner =  [[ATOnlineApiBannerAdManager sharedManager] retrieveBannerViewWithOfferModel:model setting:_setting extra:self.localInfo delegate:self];
    if (banner) {
        [self trackBannerAdLoaded:banner adExtra:nil];
        return;
    }
    [self trackBannerAdLoadFailed:[NSError errorWithDomain:@"com.anythink.onlineApiBanner" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"onlineApi has failed to show banner", NSLocalizedFailureReasonErrorKey:@"Banner's not ready for resource"}]];
}

- (void)didLoadMetaDataSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID {
    [ATLogger logMessage:[NSString stringWithFormat:@"ATOnlineApiBannerCustomEvent::didLoadMetaDataSuccessWithPlacementID:%@ unitId:%@", placementID, unitID] type:ATLogTypeExternal];
}

- (void)didFailToLoadADWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID error:(NSError *)error {
    [ATLogger logError:[NSString stringWithFormat:@"ATOnlineApiBannerCustomEvent::didFailToLoadADWithPlacementID:%@ unitId:%@ error:%@", placementID, unitID, error] type:ATLogTypeExternal];
    [self trackBannerAdLoadFailed:error];
}

// MARK:- ATOnlineApiLoadingDelegate
- (void)onlineApiBannerFailToShowOffer:(ATOnlineApiOfferModel *)offer error:(NSError *)error {
    [ATLogger logMessage:@"ATOnlineApiBannerCustomEvent::onlineApiBannerFailToShowOffer:" type:ATLogTypeExternal];
}

- (void)onlineApiBannerShowOffer:(ATOnlineApiOfferModel *)offer {
    [ATLogger logMessage:@"ATOnlineApiBannerCustomEvent::onlineApiBannerShowOffer:" type:ATLogTypeExternal];
    [self trackShow];
    [[ATOnlineApiLoader sharedLoader] recordShownAdWithOfferID:offer.offerID unitID:offer.unitID];
    [[ATOnlineApiLoader sharedLoader] removeOfferModel:offer];

//    [Utilities reportProfit:self.ad time:self.sdkTime];
}

- (void)onlineApiBannerDeepLinkOrJumpResult:(BOOL)success offer:(ATOnlineApiOfferModel *)offer {
    [ATLogger logMessage:@"ATOnlineApiBannerCustomEvent::onlineApiBannerDeepLinkOrJumpResult:" type:ATLogTypeExternal];

    [self trackBannerAdDeeplinkOrJumpResult:success];
}
- (void)onlineApiBannerClickOffer:(ATOnlineApiOfferModel *)offer {
    [ATLogger logMessage:@"ATOnlineApiBannerCustomEvent::onlineApiBannerClickOffer:" type:ATLogTypeExternal];
    [self trackBannerAdClick];
}

- (void)onlineApiBannerCloseOffer:(ATOnlineApiOfferModel *)offer {
    [ATLogger logMessage:@"ATOnlineApiBannerCustomEvent::onlineApiBannerCloseOffer:" type:ATLogTypeExternal];
    [self trackBannerAdClosed];
}

- (NSString *)lifeCircleIDForOffer:(ATOnlineApiOfferModel *)offer {
    return self.serverInfo[kAdapterCustomInfoRequestIDKey];
}

- (NSString *)networkUnitId {
    return _unitGroupModel.unitID;
}

- (NSDictionary *)networkCustomInfo {
    if (self.offerModel != nil) {
        BOOL isDeepLink = NO;
        if ([Utilities isEmpty:self.offerModel.deeplinkUrl] == NO || [Utilities isEmpty:self.offerModel.jumpUrl] == NO) {
            isDeepLink = YES;
        }
        NSDictionary *extInfo = @{kATADDelegateExtraOfferIDKey:self.offerModel.offerID != nil ? self.offerModel.offerID : @"", kATADDelegateExtraCreativeIDKey:self.offerModel.resourceID != nil ? self.offerModel.resourceID : @"", kATADDelegateExtraIsDeeplinkKey:@(isDeepLink)};
        return extInfo;
    }else {
        return nil;
    }
}

@end
