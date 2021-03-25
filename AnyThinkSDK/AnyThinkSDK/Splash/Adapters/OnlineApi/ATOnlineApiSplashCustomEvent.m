//
//  ATOnlineApiSplashCustomEvent.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/22.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiSplashCustomEvent.h"
#import "ATOnlineApiLoadingDelegate.h"
#import "ATOnlineApiSplashDelegate.h"
#import "ATOnlineApiSplashAdManager.h"
#import "ATLogger.h"
#import "ATOnlineApiLoader.h"
#import "ATOnlineApiOfferModel.h"
#import "Utilities.h"

@interface ATOnlineApiSplashCustomEvent ()<ATOnlineApiLoadingDelegate, ATOnlineApiSplashDelegate>

@end
@implementation ATOnlineApiSplashCustomEvent

// MARK:- ATOnlineApiLoadingDelegate
- (void)didFailToLoadADWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID error:(NSError *)error {
    [ATLogger logError:[NSString stringWithFormat:@"ATOnlineApiSplashCustomEvent::didLoadADSuccessWithPlacementID::didFailToLoadADWithPlacementID:%@ unitId:%@ error:%@", placementID, unitID, error] type:ATLogTypeExternal];
    [self trackSplashAdLoadFailed:error];
}

- (void)didLoadADSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID {
    [ATLogger logMessage:[NSString stringWithFormat:@"ATOnlineApiSplashCustomEvent::didLoadADSuccessWithPlacementID:%@ unitId:%@", placementID, unitID] type:ATLogTypeExternal];
    self.offerModel =  [[ATOnlineApiLoader sharedLoader] readyOnlineApiAdWithUnitGroupModelID:self.unitGroupModel.unitID placementID:placementID];
    [self trackSplashAdLoaded:self adExtra:nil];
}

- (void)didLoadMetaDataSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID {
    [ATLogger logMessage:[NSString stringWithFormat:@"ATOnlineApiSplashCustomEvent::didLoadMetaDataSuccessWithPlacementID:%@ unitId:%@", placementID, unitID] type:ATLogTypeExternal];
}

// MARK:- ATOnlineApiSplashDelegate
- (void)onlineApiSplashFailToShowOffer:(ATOnlineApiOfferModel *)offer error:(NSError *)error {
    [ATLogger logMessage:@"ATOnlineApiSplashCustomEvent::onlineApiSplashFailToShowOffer:" type:ATLogTypeExternal];
}

- (void)onlineApiSplashDeepLinkOrJumpResult:(BOOL)success offer:(ATOnlineApiOfferModel *)offer {
    [ATLogger logMessage:@"ATOnlineApiSplashCustomEvent::onlineApiSplashDeepLinkOrJumpResult:" type:ATLogTypeExternal];
    [self trackSplashAdDeeplinkOrJumpResult:success];
}

- (void)onlineApiSplashShowOffer:(ATOnlineApiOfferModel *)offer {
    [ATLogger logMessage:@"ATOnlineApiSplashCustomEvent::onlineApiSplashShowOffer:" type:ATLogTypeExternal];
    [self trackSplashAdShow];
}

- (void)onlineApiSplashClickOffer:(ATOnlineApiOfferModel *)offer {
    [ATLogger logMessage:@"ATOnlineApiSplashCustomEvent::onlineApiSplashClickOffer:" type:ATLogTypeExternal];
    [self trackSplashAdClick];
}

- (void)onlineApiSplashCloseOffer:(ATOnlineApiOfferModel *)offer {
    [ATLogger logMessage:@"ATOnlineApiSplashCustomEvent::onlineApiSplashCloseOffer:" type:ATLogTypeExternal];
    [self trackSplashAdClosed];
}

-(NSString*) lifeCircleIDForOffer:(ATOnlineApiOfferModel *)offer {
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
