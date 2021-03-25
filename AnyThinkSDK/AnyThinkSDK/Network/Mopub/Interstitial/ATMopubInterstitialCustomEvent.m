//
//  ATMopubInterstitialCustomEvent.m
//  AnyThinkMopubInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/9.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMopubInterstitialCustomEvent.h"
#import "ATMopubInterstitialAdapter.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"

@implementation ATMopubInterstitialCustomEvent
- (void)interstitialDidLoadAd:(id<ATMPInterstitialAdController>)interstitial {
    [ATLogger logMessage:@"MopubInterstitial::interstitialDidLoadAd:" type:ATLogTypeExternal];
//    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kAdAssetsCustomObjectKey:interstitial}];
    [self trackInterstitialAdLoaded:interstitial adExtra:nil];
}

- (void)interstitialDidFailToLoadAd:(id<ATMPInterstitialAdController>)interstitial {
    [ATLogger logMessage:@"MopubInterstitial::interstitialDidFailToLoadAd:" type:ATLogTypeExternal];
}

- (void)interstitialDidFailToLoadAd:(id<ATMPInterstitialAdController>)interstitial withError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"MopubInterstitial::interstitialDidFailToLoadAd:error:%@", error] type:ATLogTypeExternal];
    [self trackInterstitialAdLoadFailed:error];
}

- (void)interstitialWillAppear:(id<ATMPInterstitialAdController>)interstitial {
    [ATLogger logMessage:@"MopubInterstitial::interstitialWillAppear:" type:ATLogTypeExternal];
}

- (void)interstitialDidAppear:(id<ATMPInterstitialAdController>)interstitial {
    [ATLogger logMessage:@"MopubInterstitial::interstitialDidAppear:" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
}

- (void)interstitialWillDisappear:(id<ATMPInterstitialAdController>)interstitial {
    [ATLogger logMessage:@"MopubInterstitial::interstitialWillDisappear:" type:ATLogTypeExternal];
}

- (void)interstitialDidDisappear:(id<ATMPInterstitialAdController>)interstitial {
    [ATLogger logMessage:@"MopubInterstitial::interstitialDidDisappear:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
}

- (void)interstitialDidExpire:(id<ATMPInterstitialAdController>)interstitial {
    [ATLogger logMessage:@"MopubInterstitial::interstitialDidExpire:" type:ATLogTypeExternal];
}

- (void)interstitialDidReceiveTapEvent:(id<ATMPInterstitialAdController>)interstitial {
    [ATLogger logMessage:@"MopubInterstitial::interstitialDidReceiveTapEvent:" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"unitid"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"unitid"];
//    return extra;
//}
@end
