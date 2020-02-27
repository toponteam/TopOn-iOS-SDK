//
//  ATAdmobInterstitialCustomEvent.m
//  AnyThinkAdmobInterstitialAdapter
//
//  Created by Martin Lau on 25/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdmobInterstitialCustomEvent.h"
#import "ATInterstitialManager.h"
#import "Utilities.h"

@implementation ATAdmobInterstitialCustomEvent
- (void)interstitialDidReceiveAd:(id<ATGADInterstitial>)ad {
    [ATLogger logMessage:@"AdmobInterstitial::interstitialDidReceiveAd:" type:ATLogTypeExternal];
    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:ad, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @""}];
}

- (void)interstitial:(id<ATGADInterstitial>)ad didFailToReceiveAdWithError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"AdmobInterstitial::interstitial:didFailToReceiveAdWithError:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (void)interstitialWillPresentScreen:(id<ATGADInterstitial>)ad {
    [ATLogger logMessage:@"AdmobInterstitial::interstitialWillPresentScreen:" type:ATLogTypeExternal];
    [self trackShow];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}]; }
}

- (void)interstitialDidFailToPresentScreen:(id<ATGADInterstitial>)ad {
    [ATLogger logMessage:@"AdmobInterstitial::interstitialDidFailToPresentScreen:" type:ATLogTypeExternal];
    if ([self.delegate respondsToSelector:@selector(interstitialFailedToShowForPlacementID:error:extra:)]) {
        [self.delegate interstitialFailedToShowForPlacementID:self.interstitial.placementModel.placementID error:[NSError errorWithDomain:@"Third party ad showing domain" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"Interstitial failed to show", NSLocalizedFailureReasonErrorKey:@"Admob has failed to show its interstitial ad"}] extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}

- (void)interstitialWillDismissScreen:(id<ATGADInterstitial>)ad {
    [ATLogger logMessage:@"AdmobInterstitial::interstitialWillDismissScreen:" type:ATLogTypeExternal];
}

- (void)interstitialDidDismissScreen:(id<ATGADInterstitial>)ad {
    [ATLogger logMessage:@"AdmobInterstitial::interstitialDidDismissScreen:" type:ATLogTypeExternal];
    [self handleClose];
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) {
        [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}

- (void)interstitialWillLeaveApplication:(id<ATGADInterstitial>)ad {
    [ATLogger logMessage:@"AdmobInterstitial::interstitialWillLeaveApplication:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
        [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}
@end
