//
//  ATGDTInterstitialCustomEvent.m
//  AnyThinkGDTInterstitialAdapter
//
//  Created by Martin Lau on 21/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATGDTInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
@implementation ATGDTInterstitialCustomEvent
- (void)interstitialSuccessToLoadAd:(id<ATGDTMobInterstitial>)interstitial {
    [ATLogger logMessage:@"GDTInterstitial::interstitialSuccessToLoadAd" type:ATLogTypeExternal];
    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:interstitial, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @""}];
}

- (void)interstitialFailToLoadAd:(id<ATGDTMobInterstitial>)interstitial error:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"GDTInterstitial::interstitialFailToLoadAd:error:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (void)interstitialWillPresentScreen:(id<ATGDTMobInterstitial>)interstitial {
    [ATLogger logMessage:@"GDTInterstitial::interstitialWillPresentScreen" type:ATLogTypeExternal];
}

- (void)interstitialDidPresentScreen:(id<ATGDTMobInterstitial>)interstitial {
    [ATLogger logMessage:@"GDTInterstitial::interstitialDidPresentScreen" type:ATLogTypeExternal];
//    [self trackShow];
//    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}]; }
}

- (void)interstitialDidDismissScreen:(id<ATGDTMobInterstitial>)interstitial {
    [ATLogger logMessage:@"GDTInterstitial::interstitialDidDismissScreen" type:ATLogTypeExternal];
    [self handleClose];
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) {
        [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}

- (void)interstitialApplicationWillEnterBackground:(id<ATGDTMobInterstitial>)interstitial {
    [ATLogger logMessage:@"GDTInterstitial::interstitialApplicationWillEnterBackground" type:ATLogTypeExternal];
}

- (void)interstitialWillExposure:(id<ATGDTMobInterstitial>)interstitial {//will be called multiple times
    [ATLogger logMessage:@"GDTInterstitial::interstitialWillExposure" type:ATLogTypeExternal];
}

- (void)interstitialClicked:(id<ATGDTMobInterstitial>)interstitial {
    [ATLogger logMessage:@"GDTInterstitial::interstitialClicked" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
        [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}

- (void)interstitialAdWillPresentFullScreenModal:(id<ATGDTMobInterstitial>)interstitial {
    [ATLogger logMessage:@"GDTInterstitial::interstitialAdWillPresentFullScreenModal" type:ATLogTypeExternal];
}

- (void)interstitialAdDidPresentFullScreenModal:(id<ATGDTMobInterstitial>)interstitial {
    [ATLogger logMessage:@"GDTInterstitial::interstitialAdDidPresentFullScreenModal" type:ATLogTypeExternal];
}
- (void)interstitialAdWillDismissFullScreenModal:(id<ATGDTMobInterstitial>)interstitial {
    [ATLogger logMessage:@"GDTInterstitial::interstitialAdWillDismissFullScreenModal" type:ATLogTypeExternal];
}

- (void)interstitialAdDidDismissFullScreenModal:(id<ATGDTMobInterstitial>)interstitial {
    [ATLogger logMessage:@"GDTInterstitial::interstitialAdDidDismissFullScreenModal" type:ATLogTypeExternal];
}

#pragma mark - interstitial 2.0
- (void)unifiedInterstitialSuccessToLoadAd:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTInterstitial::unifiedInterstitialSuccessToLoadAd:" type:ATLogTypeExternal];
    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:unifiedInterstitial, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @""}];
}

- (void)unifiedInterstitialFailToLoadAd:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial error:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"GDTInterstitial::unifiedInterstitialFailToLoadAd:error:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (void)unifiedInterstitialWillPresentScreen:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTInterstitial::unifiedInterstitialWillPresentScreen:" type:ATLogTypeExternal];
}

- (void)unifiedInterstitialDidPresentScreen:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTInterstitial::unifiedInterstitialDidPresentScreen:" type:ATLogTypeExternal];
    [self trackShow];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}]; }
}

- (void)unifiedInterstitialDidDismissScreen:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTInterstitial::unifiedInterstitialDidDismissScreen:" type:ATLogTypeExternal];
    [self handleClose];
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) {
        [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}

- (void)unifiedInterstitialWillLeaveApplication:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTInterstitial::unifiedInterstitialWillLeaveApplication:" type:ATLogTypeExternal];
}

- (void)unifiedInterstitialWillExposure:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTInterstitial::unifiedInterstitialWillExposure:" type:ATLogTypeExternal];
}

- (void)unifiedInterstitialClicked:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTInterstitial::unifiedInterstitialClicked:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
        [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}

- (void)unifiedInterstitialAdWillPresentFullScreenModal:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTInterstitial::unifiedInterstitialAdWillPresentFullScreenModal:" type:ATLogTypeExternal];
}

- (void)unifiedInterstitialAdDidPresentFullScreenModal:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTInterstitial::unifiedInterstitialAdDidPresentFullScreenModal:" type:ATLogTypeExternal];
}

- (void)unifiedInterstitialAdWillDismissFullScreenModal:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTInterstitial::unifiedInterstitialAdWillDismissFullScreenModal:" type:ATLogTypeExternal];
}

- (void)unifiedInterstitialAdDidDismissFullScreenModal:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTInterstitial::unifiedInterstitialAdDidDismissFullScreenModal:" type:ATLogTypeExternal];
}
//视频详情页状态
- (void)unifiedInterstitialAd:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial playerStatusChanged:(ATGDTMediaPlayerStatus)status {
    [ATLogger logMessage:@"GDTInterstitial::unifiedInterstitialAd:playerStatusChanged" type:ATLogTypeExternal];
    switch (status) {
        case GDTMediaPlayerStatusStarted:
            [self trackVideoStart];
            if ([self.delegate respondsToSelector:@selector(interstitialDidStartPlayingVideoForPlacementID:extra:)]) { [self.delegate interstitialDidStartPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}]; }
            break;
        case GDTMediaPlayerStatusStoped:
            [self trackVideoEnd];
            if ([self.delegate respondsToSelector:@selector(interstitialDidEndPlayingVideoForPlacementID:extra:)]) {
                [self.delegate interstitialDidEndPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
            }
            break;
        default:
            break;
    }
}

- (void)unifiedInterstitialAdViewWillPresentVideoVC:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTInterstitial::unifiedInterstitialAdViewWillPresentVideoVC:" type:ATLogTypeExternal];

}

- (void)unifiedInterstitialAdViewDidPresentVideoVC:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTInterstitial::unifiedInterstitialAdViewDidPresentVideoVC:" type:ATLogTypeExternal];

}

- (void)unifiedInterstitialAdViewWillDismissVideoVC:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTInterstitial::unifiedInterstitialAdViewWillDismissVideoVC:" type:ATLogTypeExternal];

}

- (void)unifiedInterstitialAdViewDidDismissVideoVC:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTInterstitial::unifiedInterstitialAdViewDidDismissVideoVC:" type:ATLogTypeExternal];

}

@end
