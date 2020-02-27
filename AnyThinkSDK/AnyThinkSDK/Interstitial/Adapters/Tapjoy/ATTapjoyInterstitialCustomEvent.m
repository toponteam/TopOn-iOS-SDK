//
//  ATTapjoyInterstitialCustomEvent.m
//  AnyThinkTapjoyInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/9.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATTapjoyInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
@implementation ATTapjoyInterstitialCustomEvent
#pragma mark - placement
- (void)requestDidSucceed:(id<ATTJPlacement>)placement {
    [ATLogger logMessage:[NSString stringWithFormat:@"TapjoyInterstitial: requestDidSucceed"]  type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

- (void)requestDidFail:(id<ATTJPlacement>)placement error:(NSError*)error {
    [ATLogger logError:[NSString stringWithFormat:@"TapjoyInterstitial: requestDidFail, error:%@", error]  type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (void)contentIsReady:(id<ATTJPlacement>)placement {
    [ATLogger logMessage:[NSString stringWithFormat:@"TapjoyInterstitial: contentIsReady"]  type:ATLogTypeExternal];
    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kAdAssetsCustomObjectKey:placement}];
}

- (void)contentDidAppear:(id<ATTJPlacement>)placement {
    [ATLogger logMessage:[NSString stringWithFormat:@"TapjoyInterstitial: contentDidAppear"]  type:ATLogTypeExternal];
    [self trackShow];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}]; }
}

- (void)contentDidDisappear:(id<ATTJPlacement>)placement {
    [ATLogger logMessage:[NSString stringWithFormat:@"TapjoyInterstitial: contentDidDisappear"]  type:ATLogTypeExternal];
    [self handleClose];
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) {
        [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}

- (void)placement:(id<ATTJPlacement>)placement didRequestPurchase:(id<ATTJActionRequest>)request productId:(NSString*)productId {
    //
}

- (void)placement:(id<ATTJPlacement>)placement didRequestReward:(id<ATTJActionRequest>)request itemId:(NSString*)itemId quantity:(int)quantity {
    //
}
#pragma mark - video
- (void)videoDidStart:(id<ATTJPlacement>)placement {
    [ATLogger logMessage:[NSString stringWithFormat:@"TapjoyInterstitial: videoDidStart"]  type:ATLogTypeExternal];
    [self trackVideoStart];
    if ([self.delegate respondsToSelector:@selector(interstitialDidStartPlayingVideoForPlacementID:extra:)]) {
        [self.delegate interstitialDidStartPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}

- (void)videoDidComplete:(id<ATTJPlacement>)placement {
    [ATLogger logMessage:[NSString stringWithFormat:@"TapjoyInterstitial: videoDidComplete"]  type:ATLogTypeExternal];
    [self trackVideoEnd];
    if ([self.delegate respondsToSelector:@selector(interstitialDidEndPlayingVideoForPlacementID:extra:)]) {
        [self.delegate interstitialDidEndPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}

- (void)videoDidFail:(id<ATTJPlacement>)placement error:(NSString*)errorMsg {
    [ATLogger logError:[NSString stringWithFormat:@"TapjoyInterstitial: videoDidFail, msg:%@", errorMsg]  type:ATLogTypeExternal];
    NSError *error = [NSError errorWithDomain:@"Tapjoy interstitial ad video playing failed." code:10000 userInfo:@{NSLocalizedFailureReasonErrorKey:errorMsg, NSLocalizedDescriptionKey:errorMsg}];
    if ([self.delegate respondsToSelector:@selector(interstitialDidFailToPlayVideoForPlacementID:error:extra:)]) {
        [self.delegate interstitialDidFailToPlayVideoForPlacementID:self.interstitial.placementModel.placementID error:error extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}
@end
