//
//  ATGDTInterstitialCustomEvent.m
//  AnyThinkGDTInterstitialAdapter
//
//  Created by Martin Lau on 21/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATGDTInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"

@interface ATGDTInterstitialCustomEvent()
@property(nonatomic, readonly) BOOL fullScreenVideoStarted;
@end
@implementation ATGDTInterstitialCustomEvent

#pragma mark - interstitial 2.0
- (void)unifiedInterstitialSuccessToLoadAd:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTUnifiedInterstitial::unifiedInterstitialSuccessToLoadAd:" type:ATLogTypeExternal];
//    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:unifiedInterstitial, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @""}];
    [self trackInterstitialAdLoaded:unifiedInterstitial adExtra:nil];
}

- (void)unifiedInterstitialFailToLoadAd:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial error:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"GDTUnifiedInterstitial::unifiedInterstitialFailToLoadAd:error:%@", error] type:ATLogTypeExternal];
    [self trackInterstitialAdLoadFailed:error];
}

- (void)unifiedInterstitialWillPresentScreen:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTUnifiedInterstitial::unifiedInterstitialWillPresentScreen:" type:ATLogTypeExternal];
}

- (void)unifiedInterstitialDidPresentScreen:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTUnifiedInterstitial::unifiedInterstitialDidPresentScreen:" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
}

- (void)unifiedInterstitialDidDismissScreen:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTUnifiedInterstitial::unifiedInterstitialDidDismissScreen:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
}

- (void)unifiedInterstitialWillLeaveApplication:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTUnifiedInterstitial::unifiedInterstitialWillLeaveApplication:" type:ATLogTypeExternal];
}

- (void)unifiedInterstitialWillExposure:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTUnifiedInterstitial::unifiedInterstitialWillExposure:" type:ATLogTypeExternal];
}

- (void)unifiedInterstitialClicked:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTUnifiedInterstitial::unifiedInterstitialClicked:" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
}

- (void)unifiedInterstitialAdWillPresentFullScreenModal:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTUnifiedInterstitial::unifiedInterstitialAdWillPresentFullScreenModal:" type:ATLogTypeExternal];
}

- (void)unifiedInterstitialAdDidPresentFullScreenModal:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTUnifiedInterstitial::unifiedInterstitialAdDidPresentFullScreenModal:" type:ATLogTypeExternal];
}

- (void)unifiedInterstitialAdWillDismissFullScreenModal:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTUnifiedInterstitial::unifiedInterstitialAdWillDismissFullScreenModal:" type:ATLogTypeExternal];
}

- (void)unifiedInterstitialAdDidDismissFullScreenModal:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTUnifiedInterstitial::unifiedInterstitialAdDidDismissFullScreenModal:" type:ATLogTypeExternal];
}

- (void)unifiedInterstitialAd:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial playerStatusChanged:(ATGDTMediaPlayerStatus)status {
    [ATLogger logMessage:[NSString stringWithFormat:@"GDTUnifiedInterstitial::unifiedInterstitialAd:playerStatusChanged:%@", @{@(GDTMediaPlayerStatusInitial):@"GDTMediaPlayerStatusInitial", @(GDTMediaPlayerStatusLoading):@"GDTMediaPlayerStatusLoading", @(GDTMediaPlayerStatusStarted):@"GDTMediaPlayerStatusStarted", @(GDTMediaPlayerStatusPaused):@"GDTMediaPlayerStatusPaused", @(GDTMediaPlayerStatusStoped):@"GDTMediaPlayerStatusStoped", @(GDTMediaPlayerStatusError):@"GDTMediaPlayerStatusError", }[@(status)]] type:ATLogTypeExternal];
    switch (status) {
        case GDTMediaPlayerStatusStarted:
            if (!_fullScreenVideoStarted) {
                _fullScreenVideoStarted = YES;
                [self trackInterstitialAdVideoStart];
            }
            break;
        case GDTMediaPlayerStatusStoped:
            [self trackInterstitialAdVideoEnd];
            break;
        default:
            break;
    }
}

- (void)unifiedInterstitialAdViewWillPresentVideoVC:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTUnifiedInterstitial::unifiedInterstitialAdViewWillPresentVideoVC:" type:ATLogTypeExternal];
}

- (void)unifiedInterstitialAdViewDidPresentVideoVC:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTUnifiedInterstitial::unifiedInterstitialAdViewDidPresentVideoVC:" type:ATLogTypeExternal];
}

- (void)unifiedInterstitialAdViewWillDismissVideoVC:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTUnifiedInterstitial::unifiedInterstitialAdViewWillDismissVideoVC:" type:ATLogTypeExternal];
}

- (void)unifiedInterstitialAdViewDidDismissVideoVC:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial {
    [ATLogger logMessage:@"GDTUnifiedInterstitial::unifiedInterstitialAdViewDidDismissVideoVC:" type:ATLogTypeExternal];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"unit_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"unit_id"];
//    return extra;
//}
@end
