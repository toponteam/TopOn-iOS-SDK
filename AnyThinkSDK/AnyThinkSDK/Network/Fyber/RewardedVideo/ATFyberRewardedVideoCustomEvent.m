//
//  ATFyberRewardedVideoCustomEvent.m
//  AnyThinkFyberRewardedVideoAdapter
//
//  Created by Topon on 2020/4/9.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATFyberRewardedVideoCustomEvent.h"
#import "Utilities.h"
#import "ATRewardedVideoManager.h"

@implementation ATFyberRewardedVideoCustomEvent

#pragma mark - IAUnitDelegate
- (UIViewController * _Nonnull)IAParentViewControllerForUnitController:(id<IAUnitController>)unitController {
    [ATLogger logMessage:@"FyberRewardedVideo::IAParentViewControllerForUnitController:" type:ATLogTypeExternal];
    return self.viewController;
}

//点击
- (void)IAAdDidReceiveClick:(id<IAUnitController>)unitController {
    [ATLogger logMessage:@"FyberRewardedVideo::IAAdDidReceiveClick:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdClick];
}

//展示
- (void)IAAdWillLogImpression:(id<IAUnitController>)unitController {
    [ATLogger logMessage:@"FyberRewardedVideo::IAAdWillLogImpression:" type:ATLogTypeExternal];
}

//奖励回调
- (void)IAAdDidReward:(id<IAUnitController>)unitController {
    [ATLogger logMessage:@"FyberRewardedVideo::IAAdDidReward:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdRewarded];
}

- (void)IAUnitControllerWillPresentFullscreen:(id<IAUnitController>)unitController {
    [ATLogger logMessage:@"FyberRewardedVideo::IAUnitControllerWillPresentFullscreen:" type:ATLogTypeExternal];
}

//成功展示全屏
- (void)IAUnitControllerDidPresentFullscreen:(id<IAUnitController>)unitController {
    [ATLogger logMessage:@"FyberRewardedVideo::IAUnitControllerDidPresentFullscreen:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

- (void)IAUnitControllerWillDismissFullscreen:(id<IAUnitController>)unitController {
    [ATLogger logMessage:@"FyberRewardedVideo::IAUnitControllerWillDismissFullscreen:" type:ATLogTypeExternal];
}

//退出全屏展示
- (void)IAUnitControllerDidDismissFullscreen:(id<IAUnitController>)unitController {
    [ATLogger logMessage:@"FyberRewardedVideo::IAUnitControllerDidDismissFullscreen:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdCloseRewarded:self.rewardGranted];
}

//跳转外链时
- (void)IAUnitControllerWillOpenExternalApp:(id<IAUnitController>)unitController {
    [ATLogger logMessage:@"FyberRewardedVideo::IAUnitControllerWillOpenExternalApp:" type:ATLogTypeExternal];
}

//视频播放完成
- (void)IAVideoCompleted:(id<ATIAVideoContentController>)contentController {
    [ATLogger logMessage:@"FyberRewardedVideo::IAVideoCompleted:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdVideoEnd];
}

//视频播放中断
- (void)IAVideoContentController:(id<ATIAVideoContentController>)contentController videoInterruptedWithError:(NSError * _Nonnull)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"FyberRewardedVideo::IAVideoContentController:videoInterruptedWithError:%@", error] type:ATLogTypeExternal];
    [self trackRewardedVideoAdPlayEventWithError:error];
}

//更新视频时长
- (void)IAVideoContentController:(id<ATIAVideoContentController>)contentController videoDurationUpdated:(NSTimeInterval)videoDuration {
    [ATLogger logMessage:[NSString stringWithFormat:@"FyberRewardedVideo::IAVideoContentController:videoDurationUpdated:%f", videoDuration] type:ATLogTypeExternal];
}

//播放进度更新
- (void)IAVideoContentController:(id<ATIAVideoContentController>)contentController videoProgressUpdatedWithCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
//    [ATLogger logMessage:[NSString stringWithFormat:@"FyberRewardedVideo::IAVideoContentController:videoProgressUpdatedWithCurrentTime:%f totalTime:%f", currentTime, totalTime] type:ATLogTypeExternal];
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
