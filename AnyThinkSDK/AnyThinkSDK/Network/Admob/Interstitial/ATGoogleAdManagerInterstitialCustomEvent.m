//
//  ATGoogleAdManagerInterstitialCustomEvent.m
//  AnyThinkAdmobInterstitialAdapter
//
//  Created by stephen on 7/27/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATGoogleAdManagerInterstitialCustomEvent.h"
#import "ATInterstitialManager.h"
#import "Utilities.h"

@implementation ATGoogleAdManagerInterstitialCustomEvent
- (void)interstitialDidReceiveAd:(id<ATDFPInterstitial>)ad {
    [ATLogger logMessage:@"GoogleAdManagerInterstitial::interstitialDidReceiveAd:" type:ATLogTypeExternal];
    [self trackInterstitialAdLoaded:ad adExtra:nil];
}

- (void)interstitial:(id<ATDFPInterstitial>)ad didFailToReceiveAdWithError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"GoogleAdManagerInterstitial::interstitial:didFailToReceiveAdWithError:%@", error] type:ATLogTypeExternal];
    [self trackInterstitialAdLoadFailed:error];
}

- (void)interstitialWillPresentScreen:(id<ATDFPInterstitial>)ad {
    [ATLogger logMessage:@"GoogleAdManagerInterstitial::interstitialWillPresentScreen:" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
}

- (void)interstitialDidFailToPresentScreen:(id<ATDFPInterstitial>)ad {
    [ATLogger logMessage:@"GoogleAdManagerInterstitial::interstitialDidFailToPresentScreen:" type:ATLogTypeExternal];
    [self trackInterstitialAdShowFailed:[NSError errorWithDomain:@"Third party ad showing domain" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"Interstitial failed to show", NSLocalizedFailureReasonErrorKey:@"GoogleAdManager has failed to show its interstitial ad"}]];
}

- (void)interstitialWillDismissScreen:(id<ATDFPInterstitial>)ad {
    [ATLogger logMessage:@"GoogleAdManagerInterstitial::interstitialWillDismissScreen:" type:ATLogTypeExternal];
}

- (void)interstitialDidDismissScreen:(id<ATDFPInterstitial>)ad {
    [ATLogger logMessage:@"GoogleAdManagerInterstitial::interstitialDidDismissScreen:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
}

- (void)interstitialWillLeaveApplication:(id<ATDFPInterstitial>)ad {
    [ATLogger logMessage:@"GoogleAdManagerInterstitial::interstitialWillLeaveApplication:" type:ATLogTypeExternal];
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
