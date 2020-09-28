//
//  ATAppnextInterstitialCustomEvent.m
//  AnyThinkAppnextInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/16.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAppnextInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"

@implementation ATAppnextInterstitialCustomEvent
- (void) adLoaded:(id<ATAppnextAd>)ad {
    [ATLogger logMessage:@"AppnextInterstitial::adLoaded:" type:ATLogTypeExternal];
//    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kAdAssetsCustomObjectKey:ad}];
    [self trackInterstitialAdLoaded:ad adExtra:nil];
}

- (void) adOpened:(id<ATAppnextAd>)ad {
    [ATLogger logMessage:@"AppnextInterstitial::adOpened:" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
}

- (void) adClosed:(id<ATAppnextAd>)ad {
    [ATLogger logMessage:@"AppnextInterstitial::adClosed:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
}

- (void) adClicked:(id<ATAppnextAd>)ad {
    [ATLogger logMessage:@"AppnextInterstitial::adClicked:" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
}

- (void) adUserWillLeaveApplication:(id<ATAppnextAd>)ad {
    [ATLogger logMessage:@"AppnextInterstitial::adUserWillLeaveApplication:" type:ATLogTypeExternal];
}

- (void) adError:(id<ATAppnextAd>)ad error:(NSString *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"AppnextInterstitial::adError:error:%@", error] type:ATLogTypeExternal];
    NSError *errorObj = [NSError errorWithDomain:@"com.anythink.AppNextInterstitialLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load interstitial ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"%@", error]}];
    [self trackInterstitialAdLoadFailed:errorObj];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"placement_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"placement_id"];
//    return extra;
//}
@end
