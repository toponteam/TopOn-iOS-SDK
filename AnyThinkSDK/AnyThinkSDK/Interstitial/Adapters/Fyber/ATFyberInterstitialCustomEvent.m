//
//  ATFyberInterstitialCustomEvent.m
//  AnyThinkFyberInterstitialAdapter
//
//  Created by Topon on 2020/4/9.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATFyberInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"

@implementation ATFyberInterstitialCustomEvent

#pragma mark - IAUnitDelegate
- (UIViewController * _Nonnull)IAParentViewControllerForUnitController:(id<IAUnitController>)unitController {
    [ATLogger logMessage:@"FyberInterstitial::IAParentViewControllerForUnitController:" type:ATLogTypeExternal];
    return self.viewController;
}

//点击
- (void)IAAdDidReceiveClick:(id<IAUnitController>)unitController {
    [ATLogger logMessage:@"FyberInterstitial::IAAdDidReceiveClick:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
        [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

//展示
- (void)IAAdWillLogImpression:(id<IAUnitController>)unitController {
    [ATLogger logMessage:@"FyberInterstitial::IAAdWillLogImpression:" type:ATLogTypeExternal];
}

//奖励回调
- (void)IAAdDidReward:(id<IAUnitController>)unitController {
    [ATLogger logMessage:@"FyberInterstitial::IAAdDidReward:" type:ATLogTypeExternal];
}

- (void)IAUnitControllerWillPresentFullscreen:(id<IAUnitController>)unitController {
    [ATLogger logMessage:@"FyberInterstitial::IAUnitControllerWillPresentFullscreen:" type:ATLogTypeExternal];
}

//成功展示全屏
- (void)IAUnitControllerDidPresentFullscreen:(id<IAUnitController>)unitController {
    [ATLogger logMessage:@"FyberInterstitial::IAUnitControllerDidPresentFullscreen:" type:ATLogTypeExternal];
    [self trackShow];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
    [self trackVideoStart];
    if ([self.delegate respondsToSelector:@selector(interstitialDidStartPlayingVideoForPlacementID:extra:)]) {
        [self.delegate interstitialDidStartPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)IAUnitControllerWillDismissFullscreen:(id<IAUnitController>)unitController {
    [ATLogger logMessage:@"FyberInterstitial::IAUnitControllerWillDismissFullscreen:" type:ATLogTypeExternal];
}

//退出全屏展示
- (void)IAUnitControllerDidDismissFullscreen:(id<IAUnitController>)unitController {
    [ATLogger logMessage:@"FyberInterstitial::IAUnitControllerDidDismissFullscreen:" type:ATLogTypeExternal];
    [self handleClose];
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) {
        [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

//跳转外链时
- (void)IAUnitControllerWillOpenExternalApp:(id<IAUnitController>)unitController {
    [ATLogger logMessage:@"FyberInterstitial::IAUnitControllerWillOpenExternalApp:" type:ATLogTypeExternal];
}

//视频播放完成
- (void)IAVideoCompleted:(id<ATIAVideoContentController>)contentController {
    [ATLogger logMessage:@"FyberInterstitial::IAVideoCompleted:" type:ATLogTypeExternal];
    [self trackVideoEnd];
    if ([self.delegate respondsToSelector:@selector(interstitialDidEndPlayingVideoForPlacementID:extra:)]) {
        [self.delegate interstitialDidEndPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

//视频播放中断
- (void)IAVideoContentController:(id<ATIAVideoContentController>)contentController videoInterruptedWithError:(NSError * _Nonnull)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"FyberInterstitial::IAVideoContentController:videoInterruptedWithError:%@", error] type:ATLogTypeExternal];
    if ([self.delegate respondsToSelector:@selector(interstitialDidFailToPlayVideoForPlacementID:error:extra:)]) {
        [self.delegate interstitialDidFailToPlayVideoForPlacementID:self.interstitial.placementModel.placementID error:error extra:[self delegateExtra]];
    }
}

//更新视频时长
- (void)IAVideoContentController:(id<ATIAVideoContentController>)contentController videoDurationUpdated:(NSTimeInterval)videoDuration {
    [ATLogger logMessage:[NSString stringWithFormat:@"FyberInterstitial::IAVideoContentController:videoDurationUpdated:%f", videoDuration] type:ATLogTypeExternal];
}

//播放进度更新
- (void)IAVideoContentController:(id<ATIAVideoContentController>)contentController videoProgressUpdatedWithCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
//    [ATLogger logMessage:[NSString stringWithFormat:@"FyberInterstitial::IAVideoContentController:videoProgressUpdatedWithCurrentTime:%f totalTime:%f", currentTime, totalTime] type:ATLogTypeExternal];
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"position_id"];
    return extra;
}


@end
