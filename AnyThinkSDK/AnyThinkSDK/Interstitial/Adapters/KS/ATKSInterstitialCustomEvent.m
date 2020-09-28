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
    [self trackInterstitialAdLoadFailed:error];
}

- (void)fullscreenVideoAdVideoDidLoad:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd{
    [ATLogger logMessage:@"KSInterstitial::fullscreenVideoAdVideoDidLoad:" type:ATLogTypeExternal];
//    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithDictionary:@{kInterstitialAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:fullscreenVideoAd, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @""}];
//    [self handleAssets:assets];
    [self trackInterstitialAdLoaded:fullscreenVideoAd adExtra:nil];
}

- (void)fullscreenVideoAdWillVisible:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd{
    [ATLogger logMessage:@"KSInterstitial::fullscreenVideoAdWillVisible:" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
}

- (void)fullscreenVideoAdDidVisible:(id<ATKSFullscreenVideoAd>)fullscreenVideoA{
    
}

- (void)fullscreenVideoAdWillClose:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd{
    [ATLogger logMessage:@"KSInterstitial::fullscreenVideoAdWillClose:" type:ATLogTypeExternal];
}

- (void)fullscreenVideoAdDidClose:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd{
    [ATLogger logMessage:@"KSInterstitial::fullscreenVideoAdDidClose:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
}

- (void)fullscreenVideoAdDidClick:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd{
    [ATLogger logMessage:@"KSInterstitial::fullscreenVideoAdDidClick:" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
}

- (void)fullscreenVideoAdDidPlayFinish:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error{
    [ATLogger logError:[NSString stringWithFormat:@"KSInterstitial::fullscreenVideoAdDidPlayFinish:didFailWithError:%@", error] type:ATLogTypeExternal];
    if (error != nil) {
        [self trackInterstitialAdDidFailToPlayVideo:error];
    } else {
        [self trackInterstitialAdVideoEnd];
    }
}

- (void)fullscreenVideoAdDidClickSkip:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd{
    [ATLogger logMessage:@"KSInterstitial::fullscreenVideoAdDidClickSkip:" type:ATLogTypeExternal];
}

- (void)fullscreenVideoAdStartPlay:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd{
    [ATLogger logMessage:[NSString stringWithFormat:@"KSInterstitial::fullscreenVideoAdStartPlay:"]  type:ATLogTypeExternal];
    [self trackInterstitialAdVideoStart];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"position_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"position_id"];
//    return extra;
//}

@end
