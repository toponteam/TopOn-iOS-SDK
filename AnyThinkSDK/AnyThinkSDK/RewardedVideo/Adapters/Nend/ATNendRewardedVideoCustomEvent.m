//
//  ATNendRewardedVideoCustomEvent.m
//  AnyThinkNendRewardedVideoAdapter
//
//  Created by Martin Lau on 2019/4/19.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATNendRewardedVideoCustomEvent.h"
#import "Utilities.h"
#import "ATRewardedVideoManager.h"
@interface ATNendRewardedVideoCustomEvent()
@end
@implementation ATNendRewardedVideoCustomEvent
- (void)nadRewardVideoAd:(id<ATNADRewardedVideo>)nadRewardedVideoAd didReward:(id<ATNADReward>)reward {
    [ATLogger logMessage:@"NendRewardedVideo::nadRewardVideoAdDidClickInformation:didReward:" type:ATLogTypeExternal];
    self.rewardGranted = YES;
    if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){
        [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)nadRewardVideoAdDidReceiveAd:(id<ATNADRewardedVideo>)nadRewardedVideoAd {
    [ATLogger logMessage:@"NendRewardedVideo::nadRewardVideoAdDidReceiveAd:" type:ATLogTypeExternal];
    [self handleAssets:@{kRewardedVideoAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kRewardedVideoAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:nadRewardedVideoAd}];
}

- (void)nadRewardVideoAd:(id<ATNADRewardedVideo>)nadRewardedVideoAd didFailToLoadWithError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"NendRewardedVideo::nadRewardVideoAd:didFailToLoadWithError:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (void)nadRewardVideoAdDidFailedToPlay:(id<ATNADRewardedVideo>)nadRewardedVideoAd {
    [ATLogger logMessage:@"NendRewardedVideo::nadRewardVideoAdDidFailedToPlay:" type:ATLogTypeExternal];
    NSError *error = [NSError errorWithDomain:@"com.anythink.NendRewardedVideo" code:100001 userInfo:@{NSLocalizedDescriptionKey:@"ATSDK has failed to show rewarded video.", NSLocalizedFailureReasonErrorKey:@"Nend has failed to show rewarded video."}];
    [self saveVideoPlayEventWithError:error];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForPlacementID:error:extra:)]) { [self.delegate rewardedVideoDidFailToPlayForPlacementID:self.rewardedVideo.placementModel.placementID error:error extra:[self delegateExtra]]; }
}

- (void)nadRewardVideoAdDidOpen:(id<ATNADRewardedVideo>)nadRewardedVideoAd {
    [ATLogger logMessage:@"NendRewardedVideo::nadRewardVideoAdDidOpen:" type:ATLogTypeExternal];
    [self trackShow];
}

- (void)nadRewardVideoAdDidClose:(id<ATNADRewardedVideo>)nadRewardedVideoAd {
    [ATLogger logMessage:@"NendRewardedVideo::nadRewardVideoAdDidClose:" type:ATLogTypeExternal];
    [self handleClose];
    [self saveVideoCloseEventRewarded:self.rewardGranted];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
        [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:[self delegateExtra]];
    }
}

- (void)nadRewardVideoAdDidStartPlaying:(id<ATNADRewardedVideo>)nadRewardedVideoAd {
    [ATLogger logMessage:@"NendRewardedVideo::nadRewardVideoAdDidStartPlaying:" type:ATLogTypeExternal];
    [self trackVideoStart];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)nadRewardVideoAdDidStopPlaying:(id<ATNADRewardedVideo>)nadRewardedVideoAd {
    [ATLogger logMessage:@"NendRewardedVideo::nadRewardVideoAdDidStopPlaying:" type:ATLogTypeExternal];
}

- (void)nadRewardVideoAdDidCompletePlaying:(id<ATNADRewardedVideo>)nadRewardedVideoAd {
    [ATLogger logMessage:@"NendRewardedVideo::nadRewardVideoAdDidCompletePlaying:" type:ATLogTypeExternal];
    [self trackVideoEnd];
    
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)nadRewardVideoAdDidClickAd:(id<ATNADRewardedVideo>)nadRewardedVideoAd {
    [ATLogger logMessage:@"NendRewardedVideo::nadRewardVideoAdDidClickAd:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)nadRewardVideoAdDidClickInformation:(id<ATNADRewardedVideo>)nadRewardedVideoAd {
    [ATLogger logMessage:@"NendRewardedVideo::nadRewardVideoAdDidClickInformation:" type:ATLogTypeExternal];
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"spot_id"];
    return extra;
}
@end
