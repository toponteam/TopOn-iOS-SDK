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
    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kAdAssetsCustomObjectKey:interstitial}];
}

- (void)interstitialDidFailToLoadAd:(id<ATMPInterstitialAdController>)interstitial {
    [ATLogger logMessage:@"MopubInterstitial::interstitialDidFailToLoadAd:" type:ATLogTypeExternal];
}

- (void)interstitialDidFailToLoadAd:(id<ATMPInterstitialAdController>)interstitial withError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"MopubInterstitial::interstitialDidFailToLoadAd:error:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (void)interstitialWillAppear:(id<ATMPInterstitialAdController>)interstitial {
    [ATLogger logMessage:@"MopubInterstitial::interstitialWillAppear:" type:ATLogTypeExternal];
}

- (void)interstitialDidAppear:(id<ATMPInterstitialAdController>)interstitial {
    [ATLogger logMessage:@"MopubInterstitial::interstitialDidAppear:" type:ATLogTypeExternal];
    [self trackShow];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
}

- (void)interstitialWillDisappear:(id<ATMPInterstitialAdController>)interstitial {
    [ATLogger logMessage:@"MopubInterstitial::interstitialWillDisappear:" type:ATLogTypeExternal];
}

- (void)interstitialDidDisappear:(id<ATMPInterstitialAdController>)interstitial {
    [ATLogger logMessage:@"MopubInterstitial::interstitialDidDisappear:" type:ATLogTypeExternal];
    [self handleClose];
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) {
        [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)interstitialDidExpire:(id<ATMPInterstitialAdController>)interstitial {
    [ATLogger logMessage:@"MopubInterstitial::interstitialDidExpire:" type:ATLogTypeExternal];
}

- (void)interstitialDidReceiveTapEvent:(id<ATMPInterstitialAdController>)interstitial {
    [ATLogger logMessage:@"MopubInterstitial::interstitialDidReceiveTapEvent:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
        [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"unitid"];
    return extra;
}
@end
