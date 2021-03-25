//
//  ATMobrainInterstitialCustomEvent.m
//  AnyThinkMobrainAdapter
//
//  Created by Topon on 2/1/21.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import "ATMobrainInterstitialCustomEvent.h"
#import "Utilities.h"

@implementation ATMobrainInterstitialCustomEvent

#pragma mark - ABUInterstitialAdDelegate
- (void)interstitialAdDidLoad:(id<ATABUInterstitialAd>_Nonnull)interstitialAd {
    [ATLogger logMessage:@"ATMobrainInterstitial:interstitialAdDidLoad" type:ATLogTypeExternal];
    [self trackInterstitialAdLoaded:interstitialAd adExtra:nil];
}

- (void)interstitialAd:(id<ATABUInterstitialAd>_Nonnull)interstitialAd didFailWithError:(NSError *_Nullable)error {
    [ATLogger logMessage:@"ATMobrainInterstitial:interstitialAd:didFailWithError" type:ATLogTypeExternal];
    [self trackInterstitialAdLoadFailed:error];
}

- (void)interstitialAdViewRenderFail:(id<ATABUInterstitialAd>_Nonnull)interstitialAd error:(NSError *__nullable)error {
    [ATLogger logMessage:@"ATMobrainInterstitial:interstitialAdViewRenderFail:error" type:ATLogTypeExternal];
    [self trackInterstitialAdShowFailed:error];
}

- (void)interstitialAdDidVisible:(id<ATABUInterstitialAd>_Nonnull)interstitialAd {
    [ATLogger logMessage:@"ATMobrainInterstitial:interstitialAdDidVisible" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
}

- (void)interstitialAdDidClick:(id<ATABUInterstitialAd>_Nonnull)interstitialAd {
    [ATLogger logMessage:@"ATMobrainInterstitial:interstitialAdDidClick" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
}

- (void)interstitialAdDidClose:(id<ATABUInterstitialAd>_Nonnull)interstitialAd {
    [ATLogger logMessage:@"ATMobrainInterstitial:interstitialAdDidClose" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
}

- (void)interstitialAdWillPresentFullScreenModal:(id<ATABUInterstitialAd>_Nonnull)interstitialAd {
    [ATLogger logMessage:@"ATMobrainInterstitial:interstitialAdWillPresentFullScreenModal" type:ATLogTypeExternal];
}

#pragma mark - ABUFullscreenVideoAdDelegate
- (void)fullscreenVideoAdDidLoad:(id<ATABUFullscreenVideoAd>_Nonnull)fullscreenVideoAd {
    [ATLogger logMessage:@"ATMobrainInterstitial:fullscreenVideoAdDidLoad" type:ATLogTypeExternal];
    [self trackInterstitialAdLoaded:fullscreenVideoAd adExtra:nil];
}

- (void)fullscreenVideoAd:(id<ATABUFullscreenVideoAd>_Nonnull)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    [ATLogger logMessage:@"ATMobrainInterstitial:fullscreenVideoAd:didFailWithError" type:ATLogTypeExternal];
    [self trackInterstitialAdLoadFailed:error];
}

- (void)fullscreenVideoAdDidDownLoadVideo:(id<ATABUFullscreenVideoAd>_Nonnull)fullscreenVideoAd {
    [ATLogger logMessage:@"ATMobrainInterstitial:fullscreenVideoAdDidDownLoadVideo" type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

- (void)fullscreenVideoAdDidVisible:(id<ATABUFullscreenVideoAd>_Nonnull)fullscreenVideoAd {
    [ATLogger logMessage:@"ATMobrainInterstitial:fullscreenVideoAdDidVisible" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
}

- (void)fullscreenVideoAdDidClick:(id<ATABUFullscreenVideoAd>_Nonnull)fullscreenVideoAd {
    [ATLogger logMessage:@"ATMobrainInterstitial:fullscreenVideoAdDidClick" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
}

- (void)fullscreenVideoAdDidSkip:(id<ATABUFullscreenVideoAd>_Nonnull)rewardedVideoAd {
    [ATLogger logMessage:@"ATMobrainInterstitial:fullscreenVideoAdDidSkip" type:ATLogTypeExternal];
}

- (void)fullscreenVideoAdDidClose:(id<ATABUFullscreenVideoAd>_Nonnull)fullscreenVideoAd {
    [ATLogger logMessage:@"ATMobrainInterstitial:fullscreenVideoAdDidClose" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
}

- (void)fullscreenVideoAdWillPresentFullScreenModal:(id<ATABUFullscreenVideoAd>_Nonnull)fullscreenVideoAd {
    [ATLogger logMessage:@"ATMobrainInterstitial:fullscreenVideoAdWillPresentFullScreenModal" type:ATLogTypeExternal];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"];
}

- (NSDictionary *)networkCustomInfo {
    
    id<ATABUInterstitialAd> interstitial = self.interstitial.customObject;
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    [extra AT_setDictValue:@([interstitial getAdNetworkPlaformId]) key:@"network_id"];
    [extra AT_setDictValue:[interstitial getAdNetworkRitId] key:@"network_unit_id"];
    [extra AT_setDictValue:[interstitial getPreEcpm] key:@"network_ecpm"];

    return extra;
}
@end
