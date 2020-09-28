//
//  ATFlurryRewardedVideoCustomEvent.m
//  AnyThinkFlurryRewardedVideoAdapter
//
//  Created by Martin Lau on 09/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATFlurryRewardedVideoCustomEvent.h"
#import "ATLogger.h"
#import "ATRewardedVideoManager.h"
#import <objc/runtime.h>

@interface ATFlurryRewardedVideoCustomEvent()
@property(nonatomic) BOOL rewarded;
@end
@implementation ATFlurryRewardedVideoCustomEvent
- (void) adInterstitialDidFetchAd:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"Flurry: adInterstitialDidFetchAd" type:ATLogTypeExternal];
    objc_setAssociatedObject(interstitialAd, (__bridge_retained void*)kFlurryRVAssetsCustomEventKey, self, OBJC_ASSOCIATION_RETAIN);
    [self trackRewardedVideoAdLoaded:interstitialAd adExtra:nil];
}

- (void) adInterstitial:(id<ATFlurryAdInterstitial>) interstitialAd adError:(ATFlurryAdError) adError errorDescription:(NSError*) errorDescription {
    [ATLogger logError:[NSString stringWithFormat:@"Flurry failed to load rewarded video, error code:%u, error:%@", adError, errorDescription] type:ATLogTypeExternal];
    if (adError == AT_FLURRY_AD_ERROR_DID_FAIL_TO_FETCH_AD) {
        [self trackRewardedVideoAdLoadFailed:errorDescription];
    } else if (adError == AT_FLURRY_AD_ERROR_DID_FAIL_TO_RENDER) {
        [self trackRewardedVideoAdPlayEventWithError:errorDescription];
    }
}

- (void) adInterstitialDidRender:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"Flurry: adInterstitialDidRender" type:ATLogTypeExternal];
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

- (void) adInterstitialWillPresent:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"Flurry: adInterstitialWillPresent" type:ATLogTypeExternal];
}

- (void) adInterstitialWillLeaveApplication:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"Flurry: adInterstitialWillLeaveApplication" type:ATLogTypeExternal];
}

- (void) adInterstitialWillDismiss:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"Flurry: adInterstitialWillDismiss" type:ATLogTypeExternal];
}

- (void) adInterstitialDidDismiss:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"Flurry: adInterstitialDidDismiss" type:ATLogTypeExternal];
    [self trackRewardedVideoAdCloseRewarded:_rewarded];
}

- (void) adInterstitialDidReceiveClick:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"Flurry: adInterstitialDidReceiveClick" type:ATLogTypeExternal];
    [self trackRewardedVideoAdClick];
}

- (void) adInterstitialVideoDidFinish:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"Flurry: adInterstitialVideoDidFinish" type:ATLogTypeExternal];
    _rewarded = YES;
    [self trackRewardedVideoAdVideoEnd];
    [self trackRewardedVideoAdRewarded];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"ad_space"];
}


//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"ad_space"];
//    return extra;
//}
@end
