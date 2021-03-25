//
//  ATBaiduRewardedVideoCustomEvent.m
//  AnyThinkBaiduRewardedVideoAdapter
//
//  Created by Martin Lau on 2018/11/30.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATBaiduRewardedVideoCustomEvent.h"
#import "Utilities.h"
#import "ATRewardedVideoManager.h"


@interface ATBaiduRewardedVideoCustomEvent()
@property(nonatomic, readonly) BOOL rewarded;
@end
@implementation ATBaiduRewardedVideoCustomEvent
- (void)rewardedAdLoadSuccess:(id<ATBaiduMobAdRewardVideo>)video {
    [ATLogger logMessage:@"BaiduRewardedVideo: rewardedAdLoadSuccess:" type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

- (void)rewardedVideoAdLoaded:(id<ATBaiduMobAdRewardVideo>)video {
    [ATLogger logMessage:@"BaiduRewardedVideo::rewardedVideoAdLoaded:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoaded:video adExtra:nil];
}

- (void)rewardedVideoAdLoadFailed:(id<ATBaiduMobAdRewardVideo>)video withError:(NSInteger)reason {
    [ATLogger logMessage:[NSString stringWithFormat:@"BaiduRewardedVideo::rewardedVideoAdLoadFailed:withError:%ld", (long)reason] type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoadFailed:[NSError errorWithDomain:@"com.anythink.BaiduRewardedVideo" code:reason userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:@"BaiduSDK has failed to load rewarded video."}]];
}
- (void)rewardedVideoAdDidStarted:(id<ATBaiduMobAdRewardVideo>)video {
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}
- (void)rewardedVideoAdShowFailed:(id<ATBaiduMobAdRewardVideo>)video withError:(NSInteger)reason {
    [ATLogger logError:[NSString stringWithFormat:@"BaiduRewardedVideo: rewardedVideoAdShowFailed:withError: %ld", (long)reason] type:ATLogTypeExternal];
    NSError *error = [NSError errorWithDomain:@"com.anythink.BaiduRewardedVideo" code:reason userInfo:@{NSLocalizedDescriptionKey:@"ATSDK has failed to show rewarded video.", NSLocalizedFailureReasonErrorKey:@"BaiduSDK has failed to show rewarded video."}];
    [self trackRewardedVideoAdPlayEventWithError:error];
}
- (void)rewardedVideoAdDidPlayFinish:(id<ATBaiduMobAdRewardVideo>)video {
    [ATLogger logMessage:@"BaiduRewardedVideo::rewardedVideoAdDidPlayFinish:" type:ATLogTypeExternal];
    _rewarded = YES;
    [self trackRewardedVideoAdVideoEnd];
    [self trackRewardedVideoAdRewarded];
}
- (void)rewardedVideoAdDidClose:(id<ATBaiduMobAdRewardVideo>)video withPlayingProgress:(CGFloat)progress {
    [ATLogger logMessage:[NSString stringWithFormat:@"BaiduRewardedVideo::rewardedVideoAdDidClose:withPlayingProgress:%lf", progress] type:ATLogTypeExternal];
    [self trackRewardedVideoAdCloseRewarded:_rewarded];
}
- (void)rewardedVideoAdDidClick:(id<ATBaiduMobAdRewardVideo>)video withPlayingProgress:(CGFloat)progress {
    [ATLogger logMessage:[NSString stringWithFormat:@"BaiduRewardedVideo::rewardedVideoAdDidClick:withPlayingProgress:%lf", progress] type:ATLogTypeExternal];
    [self trackRewardedVideoAdClick];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"ad_place_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"ad_place_id"];
//    return extra;
//}
@end
