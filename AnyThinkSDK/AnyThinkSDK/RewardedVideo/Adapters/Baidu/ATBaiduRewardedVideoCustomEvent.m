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
    [self handleAssets:@{kRewardedVideoAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kRewardedVideoAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:video}];
}

- (void)rewardedVideoAdLoadFailed:(id<ATBaiduMobAdRewardVideo>)video withError:(NSInteger)reason {
    [ATLogger logMessage:[NSString stringWithFormat:@"BaiduRewardedVideo::rewardedVideoAdLoadFailed:withError:%ld", (long)reason] type:ATLogTypeExternal];
    [self handleLoadingFailure:[NSError errorWithDomain:@"com.anythink.BaiduRewardedVideo" code:reason userInfo:@{NSLocalizedDescriptionKey:@"ATSDK has failed to load rewarded video.", NSLocalizedFailureReasonErrorKey:@"BaiduSDK has failed to load rewarded video."}]];
}
- (void)rewardedVideoAdDidStarted:(id<ATBaiduMobAdRewardVideo>)video {
    [self trackShow];
    [self trackVideoStart];
    
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}
- (void)rewardedVideoAdShowFailed:(id<ATBaiduMobAdRewardVideo>)video withError:(NSInteger)reason {
    [ATLogger logError:[NSString stringWithFormat:@"BaiduRewardedVideo: rewardedVideoAdShowFailed:withError: %ld", (long)reason] type:ATLogTypeExternal];
    NSError *error = [NSError errorWithDomain:@"com.anythink.BaiduRewardedVideo" code:reason userInfo:@{NSLocalizedDescriptionKey:@"ATSDK has failed to show rewarded video.", NSLocalizedFailureReasonErrorKey:@"BaiduSDK has failed to show rewarded video."}];
    [self saveVideoPlayEventWithError:error];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForPlacementID:error:extra:)]) { [self.delegate rewardedVideoDidFailToPlayForPlacementID:self.rewardedVideo.placementModel.placementID error:error extra:[self delegateExtra]]; }
}
- (void)rewardedVideoAdDidPlayFinish:(id<ATBaiduMobAdRewardVideo>)video {
    [ATLogger logMessage:@"BaiduRewardedVideo::rewardedVideoAdDidPlayFinish:" type:ATLogTypeExternal];
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
- (void)rewardedVideoAdDidClose:(id<ATBaiduMobAdRewardVideo>)video withPlayingProgress:(CGFloat)progress {
    [ATLogger logMessage:[NSString stringWithFormat:@"BaiduRewardedVideo::rewardedVideoAdDidClose:withPlayingProgress:%lf", progress] type:ATLogTypeExternal];
    [self handleClose];
    [self saveVideoCloseEventRewarded:_rewarded];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
        [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:[self delegateExtra]];
    }
}
- (void)rewardedVideoAdDidClick:(id<ATBaiduMobAdRewardVideo>)video withPlayingProgress:(CGFloat)progress {
    [ATLogger logMessage:[NSString stringWithFormat:@"BaiduRewardedVideo::rewardedVideoAdDidClick:withPlayingProgress:%lf", progress] type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"ad_place_id"];
    return extra;
}
@end
