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
    [self handleAssets:@{kRewardedVideoAssetsUnitIDKey:self.unitID, kAdAssetsCustomObjectKey:interstitialAd}];
}

- (void) adInterstitial:(id<ATFlurryAdInterstitial>) interstitialAd adError:(ATFlurryAdError) adError errorDescription:(NSError*) errorDescription {
    [ATLogger logError:[NSString stringWithFormat:@"Flurry failed to load rewarded video, error code:%u, error:%@", adError, errorDescription] type:ATLogTypeExternal];
    if (adError == AT_FLURRY_AD_ERROR_DID_FAIL_TO_FETCH_AD) {
        [self handleLoadingFailure:errorDescription];
    } else if (adError == AT_FLURRY_AD_ERROR_DID_FAIL_TO_RENDER) {
        [self saveVideoPlayEventWithError:errorDescription];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForPlacementID:error:extra:)]) { [self.delegate rewardedVideoDidFailToPlayForPlacementID:self.rewardedVideo.placementModel.placementID error:errorDescription extra:[self delegateExtra]]; }
    }
}

- (void) adInterstitialDidRender:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"Flurry: adInterstitialDidRender" type:ATLogTypeExternal];
    [self trackShow];
    [self trackVideoStart];

    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
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
    [self handleClose];
    [self saveVideoCloseEventRewarded:_rewarded];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
        [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:[self delegateExtra]];
    }
}

- (void) adInterstitialDidReceiveClick:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"Flurry: adInterstitialDidReceiveClick" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) { [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]]; }
}

- (void) adInterstitialVideoDidFinish:(id<ATFlurryAdInterstitial>)interstitialAd {
    [ATLogger logMessage:@"Flurry: adInterstitialVideoDidFinish" type:ATLogTypeExternal];
    _rewarded = YES;
    self.rewardGranted = YES;
    [self trackVideoEnd];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
    if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){
        [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"ad_space"];
    return extra;
}
@end
