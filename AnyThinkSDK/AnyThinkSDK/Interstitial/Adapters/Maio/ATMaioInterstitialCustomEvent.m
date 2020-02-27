//
//  ATMaioInterstitialCustomEvent.m
//  AnyThinkMaioInterstitialAdapter
//
//  Created by Martin Lau on 2019/4/16.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATMaioInterstitialCustomEvent.h"
#import "ATMaioInterstitialAdapter.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
@implementation ATMaioInterstitialCustomEvent
- (void)maioDidInitialize {
    [ATLogger logMessage:@"MaioInterstitial::maioDidInitialize" type:ATLogTypeExternal];
}

- (void)maioDidChangeCanShow:(NSString *)zoneId newValue:(BOOL)newValue {
    [ATLogger logMessage:[NSString stringWithFormat:@"MaioInterstitial::maioDidChangeCanShow:%@ newValue:%@", zoneId, newValue ? @"yes" : @"no"] type:ATLogTypeExternal];
    if ([zoneId isEqualToString:self.unitID] && newValue) { [self handleAssets:@{kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kInterstitialAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:self.unitID != nil ? self.unitID : @""}]; }
}

- (void)maioWillStartAd:(NSString *)zoneId {
    [ATLogger logMessage:[NSString stringWithFormat:@"MaioInterstitial::maioWillStartAd:%@", zoneId] type:ATLogTypeExternal];
    if ([zoneId isEqualToString:self.unitID]) {
        [self trackShow];
        if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}]; }
    }
}
- (void)maioDidFinishAd:(NSString *)zoneId playtime:(NSInteger)playtime skipped:(BOOL)skipped rewardParam:(NSString *)rewardParam {
    [ATLogger logMessage:[NSString stringWithFormat:@"MaioInterstitial::maioDidFinishAd:%@ playtime:%ld slkipped:%@ rewardParam:%@", zoneId, playtime, skipped ? @"yes" : @"no", rewardParam] type:ATLogTypeExternal];
}

- (void)maioDidClickAd:(NSString *)zoneId {
    [ATLogger logMessage:[NSString stringWithFormat:@"MaioInterstitial::maioDidClickAd:%@", zoneId] type:ATLogTypeExternal];
    if ([zoneId isEqualToString:self.unitID]) {
        [self trackClick];
        if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
            [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
        }
    }
}

- (void)maioDidCloseAd:(NSString *)zoneId {
    [ATLogger logMessage:[NSString stringWithFormat:@"MaioInterstitial::maioDidCloseAd:%@", zoneId] type:ATLogTypeExternal];
    if ([zoneId isEqualToString:self.unitID]) {
        [NSClassFromString(@"Maio") removeDelegateObject:self];
        [self handleClose];
        if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) {
            [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
        }
    }
}

- (void)maioDidFail:(NSString *)zoneId reason:(NSInteger)reason {
    [ATLogger logMessage:[NSString stringWithFormat:@"MaioInterstitial::maioDidFail:%@ reason:%ld", zoneId, reason] type:ATLogTypeExternal];
    if ([zoneId isEqualToString:self.unitID]) {
        [self handleLoadingFailure:[NSError errorWithDomain:@"com.anythink.MaioInterstitialLoading" code:reason userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load interstitial ad for Maio", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Maio interstitial ad load has failed with reason:%ld", reason]}]];
        [NSClassFromString(@"Maio") removeDelegateObject:self];
    }
}
@end
