//
//  ATApplovinInterstitialCustomEvent.m
//  AnyThinkApplovinInterstitialAdapter
//
//  Created by Martin Lau on 25/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATApplovinInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
#import <objc/runtime.h>

@implementation ATApplovinInterstitialCustomEvent
- (void)adService:(id<ATALAdService>)adService didLoadAd:(id<ATALAd>)ad {
    [ATLogger logMessage:@"ApplovinInterstitial::adService:didLoadAd:" type:ATLogTypeExternal];
    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:ad, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @""}];
}

- (void)adService:(id<ATALAdService>)adService didFailToLoadAdWithError:(int)code {
    [ATLogger logMessage:[NSString stringWithFormat:@"ApplovinInterstitial::adService:didFailToLoadAdWithError:%d", code] type:ATLogTypeExternal];
    [self handleLoadingFailure:[NSError errorWithDomain:@"com.anythink.ApplovinInterstitial" code:code userInfo:@{NSLocalizedDescriptionKey:@"ATSDK has failed to load interstitial.", NSLocalizedFailureReasonErrorKey:@"Applovin has failed to load interstitial."}]];
}

- (void)ad:(id<ATALAd>)ad wasDisplayedIn:(UIView *)view {
    [ATLogger logMessage:@"ApplovinInterstitial::ad:wasDisplayedIn:" type:ATLogTypeExternal];
    [self trackShow];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
}

- (void)ad:(id<ATALAd>)ad wasHiddenIn:(UIView *)view {
    [ATLogger logMessage:@"ApplovinInterstitial::ad:wasHiddenIn:" type:ATLogTypeExternal];
    [self handleClose];
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) {
        [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
    //detatch al interstitial
    objc_setAssociatedObject(self, "al_interstitial_ad", nil, OBJC_ASSOCIATION_RETAIN);
}

- (void)ad:(id<ATALAd>)ad wasClickedIn:(UIView *)view {
    [ATLogger logMessage:@"ApplovinInterstitial::ad:wasClickedIn:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
        [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)videoPlaybackBeganInAd:(id<ATALAd>)ad {
    [ATLogger logMessage:@"ApplovinInterstitial::videoPlaybackBeganInAd:" type:ATLogTypeExternal];
    [self trackVideoStart];
    if ([self.delegate respondsToSelector:@selector(interstitialDidStartPlayingVideoForPlacementID:extra:)]) {
        [self.delegate interstitialDidStartPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)videoPlaybackEndedInAd:(id<ATALAd>)ad atPlaybackPercent:(NSNumber *)percentPlayed fullyWatched:(BOOL)wasFullyWatched {
    [ATLogger logMessage:@"ApplovinInterstitial::videoPlaybackEndedInAd:atPlaybackPercent:fullyWatched" type:ATLogTypeExternal];
    if ([self.delegate respondsToSelector:@selector(interstitialDidEndPlayingVideoForPlacementID:extra:)]) {
        [self.delegate interstitialDidEndPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"zone_id"] != nil ? self.interstitial.unitGroup.content[@"zone_id"] : @"";
    return extra;
}
@end
