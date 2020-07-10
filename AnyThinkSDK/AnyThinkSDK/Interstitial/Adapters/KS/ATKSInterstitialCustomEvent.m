//
//  ATKSInterstitialCustomEvent.m
//  AnyThinkSDK
//
//  Created by Topon on 2019/9/10.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATKSInterstitialCustomEvent.h"
#import "ATKSInterstitialAdapter.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
@implementation ATKSInterstitialCustomEvent
- (void)fullscreenVideoAdDidLoad:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd{
    [ATLogger logMessage:@"KSInterstitial::fullscreenVideoAdDidLoad:" type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

- (void)fullscreenVideoAd:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error{
    [ATLogger logError:[NSString stringWithFormat:@"KSInterstitial::fullscreenVideoAd:didFailWithError:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (void)fullscreenVideoAdVideoDidLoad:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd{
    [ATLogger logMessage:@"KSInterstitial::fullscreenVideoAdVideoDidLoad:" type:ATLogTypeExternal];
    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithDictionary:@{kInterstitialAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:fullscreenVideoAd, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @""}];
    [self handleAssets:assets];
}

- (void)fullscreenVideoAdWillVisible:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd{
    [ATLogger logMessage:@"KSInterstitial::fullscreenVideoAdWillVisible:" type:ATLogTypeExternal];
    [self trackShow];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
}

- (void)fullscreenVideoAdDidVisible:(id<ATKSFullscreenVideoAd>)fullscreenVideoA{
    
}

- (void)fullscreenVideoAdWillClose:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd{
    [ATLogger logMessage:@"KSInterstitial::fullscreenVideoAdWillClose:" type:ATLogTypeExternal];
}

- (void)fullscreenVideoAdDidClose:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd{
    [ATLogger logMessage:@"KSInterstitial::fullscreenVideoAdDidClose:" type:ATLogTypeExternal];
    [self handleClose];
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) {
        [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)fullscreenVideoAdDidClick:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd{
    [ATLogger logMessage:@"KSInterstitial::fullscreenVideoAdDidClick:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
        [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)fullscreenVideoAdDidPlayFinish:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error{
    [ATLogger logError:[NSString stringWithFormat:@"KSInterstitial::fullscreenVideoAdDidPlayFinish:didFailWithError:%@", error] type:ATLogTypeExternal];
    [self trackVideoEnd];
    if (error != nil) {
        if ([self.delegate respondsToSelector:@selector(interstitialDidFailToPlayVideoForPlacementID:error:extra:)]) {
            [self.delegate interstitialDidFailToPlayVideoForPlacementID:self.interstitial.placementModel.placementID error:error extra:[self delegateExtra]];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(interstitialDidEndPlayingVideoForPlacementID:extra:)]) {
            [self.delegate interstitialDidEndPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
        }
    }
}

- (void)fullscreenVideoAdDidClickSkip:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd{
    [ATLogger logMessage:@"KSInterstitial::fullscreenVideoAdDidClickSkip:" type:ATLogTypeExternal];
}

- (void)fullscreenVideoAdStartPlay:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd{
    [ATLogger logMessage:[NSString stringWithFormat:@"KSInterstitial: fullscreenVideoAdStartPlay"]  type:ATLogTypeExternal];
    [self trackVideoStart];
    if ([self.delegate respondsToSelector:@selector(interstitialDidStartPlayingVideoForPlacementID:extra:)]) {
        [self.delegate interstitialDidStartPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"position_id"];
    return extra;
}

@end
