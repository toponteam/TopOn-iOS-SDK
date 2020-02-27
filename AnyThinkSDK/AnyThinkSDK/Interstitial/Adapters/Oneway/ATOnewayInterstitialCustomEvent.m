//
//  ATOnewayInterstitialCustomEvent.m
//  AnyThinkOnewayInterstitialAdapter
//
//  Created by Martin Lau on 30/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATOnewayInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
#import "ATAdAdapter.h"
@implementation ATOnewayInterstitialCustomEvent
-(ATNativeADSourceType) adSourceType {
    return ATNativeADSourceTypeVideo;
}

- (void)oneWaySDKInterstitialAdReady {
    [ATLogger logMessage:@"OnewayInterstitial::oneWaySDKInterstitialAdReady" type:ATLogTypeExternal];
    NSArray<id<ATAd>>* ads = [[ATInterstitialManager sharedManager] adsWithPlacementID:((ATPlacementModel*)self.customInfo[kAdapterCustomInfoPlacementModelKey]).placementID];
    __block id<ATAd> ad = nil;
    [ads enumerateObjectsUsingBlock:^(id<ATAd>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.unitID isEqualToString:self.unitID]) {
            ad = obj;
            *stop = YES;
        }
    }];
    
    if (ad != nil) [self handleAssets:@{kInterstitialAssetsCustomEventKey:((ATInterstitial*)ad).customEvent, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @""}];
    else [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @""}];
}
- (void)oneWaySDKInterstitialAdDidShow:(NSString *)tag {
    [ATLogger logMessage:[NSString stringWithFormat:@"OnewayInterstitial::oneWaySDKInterstitialAdDidShow:%@", tag] type:ATLogTypeExternal];
    [self trackShow];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}]; }
}
- (void)oneWaySDKInterstitialAdDidClose:(NSString *)tag withState:(NSNumber *)state {
    [ATLogger logMessage:[NSString stringWithFormat:@"OnewayInterstitial::oneWaySDKInterstitialAdDidClose:%@:withState:%@", tag, state] type:ATLogTypeExternal];
    [self handleClose];
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) {
        [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}
- (void)oneWaySDKInterstitialAdDidClick:(NSString *)tag {
    [ATLogger logMessage:[NSString stringWithFormat:@"OnewayInterstitial::oneWaySDKInterstitialAdDidClick:%@", tag] type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
        [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}
- (void)oneWaySDKDidError:(NSInteger)error withMessage:(NSString *)message {
    [ATLogger logMessage:[NSString stringWithFormat:@"OnewayInterstitial::oneWaySDKDidError:%ld:withMessage:%@", error, message] type:ATLogTypeExternal];
    [self handleLoadingFailure:[NSError errorWithDomain:@"com.anythink.OnewayInterstitial" code:error userInfo:@{NSLocalizedDescriptionKey:@"ATSDK has failed to load interstitial.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"%@", message]}]];
}
@end
