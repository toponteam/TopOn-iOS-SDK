//
//  ATAdmobInterstitialCustomEvent.m
//  AnyThinkAdmobInterstitialAdapter
//
//  Created by Martin Lau on 25/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdmobInterstitialCustomEvent.h"
#import "ATInterstitialManager.h"
#import "Utilities.h"

@implementation ATAdmobInterstitialCustomEvent
- (void)interstitialDidReceiveAd:(id<ATGADInterstitial>)ad {
    [ATLogger logMessage:@"AdmobInterstitial::interstitialDidReceiveAd:" type:ATLogTypeExternal];
//    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:ad, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @""}];
    [self trackInterstitialAdLoaded:ad adExtra:nil];
}

- (void)interstitial:(id<ATGADInterstitial>)ad didFailToReceiveAdWithError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"AdmobInterstitial::interstitial:didFailToReceiveAdWithError:%@", error] type:ATLogTypeExternal];
    [self trackInterstitialAdLoadFailed:error];
}

- (void)interstitialWillPresentScreen:(id<ATGADInterstitial>)ad {
    [ATLogger logMessage:@"AdmobInterstitial::interstitialWillPresentScreen:" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
}

- (void)interstitialDidFailToPresentScreen:(id<ATGADInterstitial>)ad {
    [ATLogger logMessage:@"AdmobInterstitial::interstitialDidFailToPresentScreen:" type:ATLogTypeExternal];
    [self trackInterstitialAdShowFailed:[NSError errorWithDomain:@"Third party ad showing domain" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"Interstitial failed to show", NSLocalizedFailureReasonErrorKey:@"Admob has failed to show its interstitial ad"}]];
}

- (void)interstitialWillDismissScreen:(id<ATGADInterstitial>)ad {
    [ATLogger logMessage:@"AdmobInterstitial::interstitialWillDismissScreen:" type:ATLogTypeExternal];
}

- (void)interstitialDidDismissScreen:(id<ATGADInterstitial>)ad {
    [ATLogger logMessage:@"AdmobInterstitial::interstitialDidDismissScreen:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
}

- (void)interstitialWillLeaveApplication:(id<ATGADInterstitial>)ad {
    [ATLogger logMessage:@"AdmobInterstitial::interstitialWillLeaveApplication:" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
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
