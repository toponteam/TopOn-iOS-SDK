//
//  ATFacebookInterstitialCustomEvent.m
//  AnyThinkFacebookInterstitialAdapter
//
//  Created by Martin Lau on 29/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATFacebookInterstitialCustomEvent.h"
#import "ATInterstitialManager.h"
#import "Utilities.h"

@implementation ATFacebookInterstitialCustomEvent
- (void)interstitialAdDidClick:(id<ATFBInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"FacebookInterstitial::interstitialAdDidClick:" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
}

- (void)interstitialAdDidClose:(id<ATFBInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"FacebookInterstitial::interstitialAdDidClose:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
}

- (void)interstitialAdWillClose:(id<ATFBInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"FacebookInterstitial::interstitialAdWillClose:" type:ATLogTypeExternal];
}

- (void)interstitialAdDidLoad:(id<ATFBInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"FacebookInterstitial::interstitialAdDidLoad:" type:ATLogTypeExternal];
//    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:interstitialAd, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @""}];
    [self trackInterstitialAdLoaded:interstitialAd adExtra:nil];
}

- (void)interstitialAd:(id<ATFBInterstitialAd>)interstitialAd didFailWithError:(NSError *)error {
    [ATLogger logError:[NSString stringWithFormat:@"FacebookInterstitial::interstitialAd:didFailWithError:%@", error] type:ATLogTypeExternal];
    [self trackInterstitialAdLoadFailed:error];
}

- (void)interstitialAdWillLogImpression:(id<ATFBInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"FacebookInterstitial::interstitialAdWillLogImpression:" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
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
