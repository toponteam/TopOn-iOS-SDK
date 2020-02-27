//
//  ATFacebookInterstitialCustomEvent.m
//  AnyThinkFacebookInterstitialAdapter
//
//  Created by Martin Lau on 29/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATFacebookInterstitialCustomEvent.h"
#import "ATInterstitialManager.h"
#import "Utilities.h"
@implementation ATFacebookInterstitialCustomEvent
- (void)interstitialAdDidClick:(id<ATFBInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"FacebookInterstitial::interstitialAdDidClick:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
        [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}

- (void)interstitialAdDidClose:(id<ATFBInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"FacebookInterstitial::interstitialAdDidClose:" type:ATLogTypeExternal];
    [self handleClose];
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) {
        [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}

- (void)interstitialAdWillClose:(id<ATFBInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"FacebookInterstitial::interstitialAdWillClose:" type:ATLogTypeExternal];
}

- (void)interstitialAdDidLoad:(id<ATFBInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"FacebookInterstitial::interstitialAdDidLoad:" type:ATLogTypeExternal];
    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:interstitialAd, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @""}];
}

- (void)interstitialAd:(id<ATFBInterstitialAd>)interstitialAd didFailWithError:(NSError *)error {
    [ATLogger logError:[NSString stringWithFormat:@"FacebookInterstitial::interstitialAd:didFailWithError:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (void)interstitialAdWillLogImpression:(id<ATFBInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"FacebookInterstitial::interstitialAdWillLogImpression:" type:ATLogTypeExternal];
    [self trackShow];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}]; }
}
@end
