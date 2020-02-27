//
//  ATFlurryInterstitialCustomEvent.m
//  AnyThinkFlurryInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/8.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATFlurryInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
@implementation ATFlurryInterstitialCustomEvent
- (void) adInterstitialDidFetchAd:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"FlurryInterstitial::adInterstitialDidFetchAd:" type:ATLogTypeExternal];
    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kAdAssetsCustomObjectKey:interstitialAd}];
}

- (void) adInterstitialDidRender:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"FlurryInterstitial::adInterstitialDidRender:" type:ATLogTypeExternal];
    [self trackShow];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}]; }
}

- (void) adInterstitialWillPresent:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"FlurryInterstitial::adInterstitialWillPresent:" type:ATLogTypeExternal];
}

- (void) adInterstitialWillLeaveApplication:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"FlurryInterstitial::adInterstitialWillLeaveApplication:" type:ATLogTypeExternal];
}

- (void) adInterstitialWillDismiss:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"FlurryInterstitial::adInterstitialWillDismiss:" type:ATLogTypeExternal];
}

- (void) adInterstitialDidDismiss:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"FlurryInterstitial::adInterstitialDidDismiss:" type:ATLogTypeExternal];
    [self handleClose];
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) {
        [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}

- (void) adInterstitialDidReceiveClick:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"FlurryInterstitial::adInterstitialDidReceiveClick:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
        [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}

- (void) adInterstitialVideoDidFinish:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"FlurryInterstitial::adInterstitialVideoDidFinish:" type:ATLogTypeExternal];
    if ([self.delegate respondsToSelector:@selector(interstitialDidEndPlayingVideoForPlacementID:extra:)]) {
        [self.delegate interstitialDidEndPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}

- (void) adInterstitial:(id<ATFlurryAdInterstitial>) interstitialAd adError:(NSInteger) adError errorDescription:(NSError*) errorDescription {
    [ATLogger logMessage:[NSString stringWithFormat:@"FlurryInterstitial::adInterstitial:adError:%ld errorDescription:%@", adError, errorDescription] type:ATLogTypeExternal];
    if (adError == AT_FLURRY_AD_ERROR_DID_FAIL_TO_FETCH_AD) {
        [self handleLoadingFailure:errorDescription];
    } else if (adError == AT_FLURRY_AD_ERROR_DID_FAIL_TO_RENDER) {
        if ([self.delegate respondsToSelector:@selector(interstitialFailedToShowForPlacementID:error:extra:)]) {
            [self.delegate interstitialFailedToShowForPlacementID:self.interstitial.placementModel.placementID error:errorDescription extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
        }
    }
}
@end
