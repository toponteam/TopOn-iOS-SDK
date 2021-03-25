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
    [self trackRewardedVideoAdRewarded];
}

- (void)nadRewardVideoAdDidReceiveAd:(id<ATNADRewardedVideo>)nadRewardedVideoAd {
    [ATLogger logMessage:@"NendRewardedVideo::nadRewardVideoAdDidReceiveAd:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoaded:nadRewardedVideoAd adExtra:nil];
}

- (void)nadRewardVideoAd:(id<ATNADRewardedVideo>)nadRewardedVideoAd didFailToLoadWithError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"NendRewardedVideo::nadRewardVideoAd:didFailToLoadWithError:%@", error] type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoadFailed:error];
}

- (void)nadRewardVideoAdDidFailedToPlay:(id<ATNADRewardedVideo>)nadRewardedVideoAd {
    [ATLogger logMessage:@"NendRewardedVideo::nadRewardVideoAdDidFailedToPlay:" type:ATLogTypeExternal];
    NSError *error = [NSError errorWithDomain:@"com.anythink.NendRewardedVideo" code:100001 userInfo:@{NSLocalizedDescriptionKey:@"ATSDK has failed to show rewarded video.", NSLocalizedFailureReasonErrorKey:@"Nend has failed to show rewarded video."}];
    [self trackRewardedVideoAdPlayEventWithError:error];
}

- (void)nadRewardVideoAdDidOpen:(id<ATNADRewardedVideo>)nadRewardedVideoAd {
    [ATLogger logMessage:@"NendRewardedVideo::nadRewardVideoAdDidOpen:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdShow];
}

- (void)nadRewardVideoAdDidClose:(id<ATNADRewardedVideo>)nadRewardedVideoAd {
    [ATLogger logMessage:@"NendRewardedVideo::nadRewardVideoAdDidClose:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdCloseRewarded:self.rewardGranted];
}

- (void)nadRewardVideoAdDidStartPlaying:(id<ATNADRewardedVideo>)nadRewardedVideoAd {
    [ATLogger logMessage:@"NendRewardedVideo::nadRewardVideoAdDidStartPlaying:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdVideoStart];
}

- (void)nadRewardVideoAdDidStopPlaying:(id<ATNADRewardedVideo>)nadRewardedVideoAd {
    [ATLogger logMessage:@"NendRewardedVideo::nadRewardVideoAdDidStopPlaying:" type:ATLogTypeExternal];
}

- (void)nadRewardVideoAdDidCompletePlaying:(id<ATNADRewardedVideo>)nadRewardedVideoAd {
    [ATLogger logMessage:@"NendRewardedVideo::nadRewardVideoAdDidCompletePlaying:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdVideoEnd];
}

- (void)nadRewardVideoAdDidClickAd:(id<ATNADRewardedVideo>)nadRewardedVideoAd {
    [ATLogger logMessage:@"NendRewardedVideo::nadRewardVideoAdDidClickAd:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdClick];
}

- (void)nadRewardVideoAdDidClickInformation:(id<ATNADRewardedVideo>)nadRewardedVideoAd {
    [ATLogger logMessage:@"NendRewardedVideo::nadRewardVideoAdDidClickInformation:" type:ATLogTypeExternal];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"spot_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"spot_id"];
//    return extra;
//}
@end
