//
//  ATFlurryInterstitialCustomEvent.m
//  AnyThinkFlurryInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/8.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATFlurryInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"


@implementation ATFlurryInterstitialCustomEvent
- (void) adInterstitialDidFetchAd:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"FlurryInterstitial::adInterstitialDidFetchAd:" type:ATLogTypeExternal];
//    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kAdAssetsCustomObjectKey:interstitialAd}];
    [self trackInterstitialAdLoaded:interstitialAd adExtra:nil];
}

- (void) adInterstitialDidRender:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"FlurryInterstitial::adInterstitialDidRender:" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
}

- (void) adInterstitialWillPresent:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"FlurryInterstitial::adInterstitialWillPresent:" type:ATLogTypeExternal];
}

- (void) adInterstitialWillLeaveApplication:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"FlurryInterstitial::adInterstitialWillLeaveApplication:" type:ATLogTypeExternal];
}

- (void) adInterstitialWillDismiss:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"FlurryInterstitial::adInterstitialWillDismiss:" type:ATLogTypeExternal];
}

- (void) adInterstitialDidDismiss:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"FlurryInterstitial::adInterstitialDidDismiss:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
}

- (void) adInterstitialDidReceiveClick:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"FlurryInterstitial::adInterstitialDidReceiveClick:" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
}

- (void) adInterstitialVideoDidFinish:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"FlurryInterstitial::adInterstitialVideoDidFinish:" type:ATLogTypeExternal];
    [self trackInterstitialAdVideoEnd];
}

- (void) adInterstitial:(id<ATFlurryAdInterstitial>) interstitialAd adError:(NSInteger) adError errorDescription:(NSError*) errorDescription {
    [ATLogger logMessage:[NSString stringWithFormat:@"FlurryInterstitial::adInterstitial:adError:%ld errorDescription:%@", adError, errorDescription] type:ATLogTypeExternal];
    if (adError == AT_FLURRY_AD_ERROR_DID_FAIL_TO_FETCH_AD) {
        [self trackInterstitialAdLoadFailed:errorDescription];
    } else if (adError == AT_FLURRY_AD_ERROR_DID_FAIL_TO_RENDER) {
        [self trackInterstitialAdShowFailed:errorDescription];
    }
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"ad_space"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"ad_space"];
//    return extra;
//}
@end
