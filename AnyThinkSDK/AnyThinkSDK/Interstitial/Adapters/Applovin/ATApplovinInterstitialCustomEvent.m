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
//    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:ad, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @""}];
    [self trackInterstitialAdLoaded:ad adExtra:nil];
}

- (void)adService:(id<ATALAdService>)adService didFailToLoadAdWithError:(int)code {
    [ATLogger logMessage:[NSString stringWithFormat:@"ApplovinInterstitial::adService:didFailToLoadAdWithError:%d", code] type:ATLogTypeExternal];
    [self trackInterstitialAdLoadFailed:[NSError errorWithDomain:@"com.anythink.ApplovinInterstitial" code:code userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:@"Applovin has failed to load interstitial."}]];
}

- (void)ad:(id<ATALAd>)ad wasDisplayedIn:(UIView *)view {
    [ATLogger logMessage:@"ApplovinInterstitial::ad:wasDisplayedIn:" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
}

- (void)ad:(id<ATALAd>)ad wasHiddenIn:(UIView *)view {
    [ATLogger logMessage:@"ApplovinInterstitial::ad:wasHiddenIn:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
    //detatch al interstitial
    objc_setAssociatedObject(self, "al_interstitial_ad", nil, OBJC_ASSOCIATION_RETAIN);
}

- (void)ad:(id<ATALAd>)ad wasClickedIn:(UIView *)view {
    [ATLogger logMessage:@"ApplovinInterstitial::ad:wasClickedIn:" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
}

- (void)videoPlaybackBeganInAd:(id<ATALAd>)ad {
    [ATLogger logMessage:@"ApplovinInterstitial::videoPlaybackBeganInAd:" type:ATLogTypeExternal];
    [self trackInterstitialAdVideoStart];
}

- (void)videoPlaybackEndedInAd:(id<ATALAd>)ad atPlaybackPercent:(NSNumber *)percentPlayed fullyWatched:(BOOL)wasFullyWatched {
    [ATLogger logMessage:@"ApplovinInterstitial::videoPlaybackEndedInAd:atPlaybackPercent:fullyWatched" type:ATLogTypeExternal];
    [self trackInterstitialAdVideoEnd];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"zone_id"] != nil ? self.serverInfo[@"zone_id"] : @"";
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"zone_id"] != nil ? self.interstitial.unitGroup.content[@"zone_id"] : @"";
//    return extra;
//}
@end
