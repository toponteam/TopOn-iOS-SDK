//
//  ATMintegralInterstitialCustomEvent.m
//  AnyThinkMintegralInterstitialAdapter
//
//  Created by Martin Lau on 25/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMintegralInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
@implementation ATMintegralInterstitialCustomEvent
-(ATNativeADSourceType) adSourceType {
    return [self.interstitial.unitGroup.content[@"is_video"] boolValue] ? ATNativeADSourceTypeVideo : ATNativeADSourceTypeImage;
}
#pragma mark - interstitial delegate
- (void) onInterstitialLoadSuccess:(id<ATMTGInterstitialAdManager>)adManager {
    [ATLogger logMessage:@"MintegralInterstitial::onInterstitialLoadSuccess:" type:ATLogTypeExternal];
    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:adManager, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @""}];
}

- (void) onInterstitialLoadFail:(nonnull NSError *)error adManager:(id<ATMTGInterstitialAdManager>)adManager {
    [ATLogger logMessage:[NSString stringWithFormat:@"MintegralInterstitial::onInterstitialLoadFail:%@ adManager:", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (void) onInterstitialShowSuccess:(id<ATMTGInterstitialAdManager>)adManager {
    [ATLogger logMessage:@"MintegralInterstitial::onInterstitialShowSuccess:" type:ATLogTypeExternal];
    [self trackShow];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
}

- (void) onInterstitialShowFail:(nonnull NSError *)error adManager:(id<ATMTGInterstitialAdManager>)adManager {
    [ATLogger logMessage:[NSString stringWithFormat:@"MintegralInterstitial::onInterstitialShowFail:%@ adManager:", error] type:ATLogTypeExternal];
    if ([self.delegate respondsToSelector:@selector(interstitialFailedToShowForPlacementID:error:extra:)]) {
        [self.delegate interstitialFailedToShowForPlacementID:self.interstitial.placementModel.placementID error:error extra:[self delegateExtra]];
    }
}

- (void) onInterstitialClosed:(id<ATMTGInterstitialAdManager>)adManager {
    [ATLogger logMessage:@"MintegralInterstitial::onInterstitialClosed:" type:ATLogTypeExternal];
    [self handleClose];
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) {
        [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void) onInterstitialAdClick:(id<ATMTGInterstitialAdManager>)adManager  {
    [ATLogger logMessage:@"MintegralInterstitial::onInterstitialAdClick:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
        [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

#pragma mark - interstitial video delegate
- (void) onInterstitialAdLoadSuccess:(id<ATMTGInterstitialVideoAdManager>)adManager {//Video not ready
    [ATLogger logMessage:@"MintegralInterstitial::onInterstitialAdLoadSuccess:" type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

- (void) onInterstitialVideoLoadSuccess:(id<ATMTGInterstitialVideoAdManager>)adManager {
    [ATLogger logMessage:@"MintegralInterstitial::onInterstitialVideoLoadSuccess:" type:ATLogTypeExternal];
    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:adManager, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @""}];
}

- (void) onInterstitialVideoLoadFail:(nonnull NSError *)error adManager:(id<ATMTGInterstitialVideoAdManager>)adManager {
    [ATLogger logMessage:[NSString stringWithFormat:@"MintegralInterstitial::onInterstitialVideoLoadFail:%@ adManager:", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (void) onInterstitialVideoShowSuccess:(id<ATMTGInterstitialVideoAdManager>)adManager {
    [ATLogger logMessage:@"MintegralInterstitial::onInterstitialVideoShowSuccess:" type:ATLogTypeExternal];
    [self trackShow];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
}

- (void) onInterstitialVideoShowFail:(nonnull NSError *)error adManager:(id<ATMTGInterstitialVideoAdManager>)adManager {
    [ATLogger logMessage:[NSString stringWithFormat:@"MintegralInterstitial::onInterstitialVideoShowFail:%@ adManager:", error] type:ATLogTypeExternal];
    if ([self.delegate respondsToSelector:@selector(interstitialDidFailToPlayVideoForPlacementID:error:extra:)]) {
        [self.delegate interstitialDidFailToPlayVideoForPlacementID:self.interstitial.placementModel.placementID error:error extra:[self delegateExtra]];
    }
}

- (void) onInterstitialVideoAdClick:(id<ATMTGInterstitialVideoAdManager>)adManager {
    [ATLogger logMessage:@"MintegralInterstitial::onInterstitialVideoAdClick:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
        [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)onInterstitialVideoAdDismissedWithConverted:(BOOL)converted adManager:(id<ATMTGInterstitialVideoAdManager>)adManager {
    [ATLogger logMessage:@"MintegralInterstitial::onInterstitialVideoAdDismissedWithConverted:adManager:" type:ATLogTypeExternal];
    [self handleClose];
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) {
        [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"unitid"];
    return extra;
}
@end
