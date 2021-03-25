//
//  ATNendInterstitialCustomEvent.m
//  AnyThinkNendInterstitialAdapter
//
//  Created by Martin Lau on 2019/4/18.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATNendInterstitialCustomEvent.h"
#import "ATNendInterstitialAdapter.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"

@implementation ATNendInterstitialCustomEvent
-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(instancetype) initWithInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    self = [super initWithInfo:serverInfo localInfo:localInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadedNotification:) name:kATNendInterstitialLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClickNotification:) name:kATNendInterstitialClickNotification object:nil];
    }
    return self;
}

-(void) handleLoadedNotification:(NSNotification*)notification {
    NSString *spotID = notification.userInfo[kATNendInterstitialNotificationUserInfoSpotIDKey];
    if ([spotID isEqualToString:self.unitID]) {
        NSInteger status = [notification.userInfo[kATNendInterstitialNotificationUserInfoStatusKey] integerValue];
        if (status == 0) {
            [self trackInterstitialAdLoaded:self.unitID != nil ? self.unitID : @"" adExtra:nil];
        } else {
            [self trackInterstitialAdLoadFailed:[NSError errorWithDomain:@"com.anythink.NendInterstitialLoading" code:status userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load interstitial ad", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Nend interstitial has failed to load interstitial ad with error code:%ld", status]}]];
        }
    }
}

-(void) handleClickNotification:(NSNotification*)notification {
    if (self.interstitial != nil) {
        NSString *spotID = notification.userInfo[kATNendInterstitialNotificationUserInfoSpotIDKey];
        if ([spotID isEqualToString:self.unitID]) {
            NSInteger status = [notification.userInfo[kATNendInterstitialNotificationUserInfoClickTypeKey] integerValue];
            if (status == 0) {//Click
                [self trackInterstitialAdClick];
            } else if (status == 1) {//Close
                [self trackInterstitialAdClose];
            }
        }
    }
}

-(void) handleShowSuccess {
    [self trackShow];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
}

-(void) handleShowFailure:(NSInteger)code {
    if ([self.delegate respondsToSelector:@selector(interstitialFailedToShowForPlacementID:error:extra:)]) {
        [self.delegate interstitialFailedToShowForPlacementID:self.interstitial.placementModel.placementID error:[NSError errorWithDomain:@"com.anythink.NendInterstitialShow" code:code userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to show interstitial.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Nend has failed to show interstitial with code:%ld", code]}] extra:[self delegateExtra]];
    }
}

#pragma mark - interstitial video
- (void)nadInterstitialVideoAdDidReceiveAd:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd {
    [ATLogger logMessage:@"NendInterstitialVideo::nadInterstitialVideoAdDidReceiveAd:" type:ATLogTypeExternal];
    [self trackInterstitialAdLoaded:nadInterstitialVideoAd adExtra:nil];
}

- (void)nadInterstitialVideoAd:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd didFailToLoadWithError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"NendInterstitialVideo::nadInterstitialVideoAd:didFailToLoadWithError:%@", error] type:ATLogTypeExternal];
    [self trackInterstitialAdLoadFailed:error];
}

- (void)nadInterstitialVideoAdDidFailedToPlay:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd {
    [ATLogger logMessage:@"NendInterstitialVideo::nadInterstitialVideoAdDidFailedToPlay:" type:ATLogTypeExternal];
    [self trackInterstitialAdDidFailToPlayVideo:[NSError errorWithDomain:@"com.anythink.NendInterstitialVideoPlayingFailure" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to play video for interstitial", NSLocalizedFailureReasonErrorKey:@"NendInterstitialVideo failed to play video"}]];
}

- (void)nadInterstitialVideoAdDidOpen:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd {
    [ATLogger logMessage:@"NendInterstitialVideo::nadInterstitialVideoAdDidOpen:" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
}

- (void)nadInterstitialVideoAdDidClose:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd {
    [ATLogger logMessage:@"NendInterstitialVideo::nadInterstitialVideoAdDidClose:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
}

- (void)nadInterstitialVideoAdDidStartPlaying:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd {
    [ATLogger logMessage:@"NendInterstitialVideo::nadInterstitialVideoAdDidStartPlaying:" type:ATLogTypeExternal];
    [self trackInterstitialAdVideoStart];
}

- (void)nadInterstitialVideoAdDidStopPlaying:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd {
    [ATLogger logMessage:@"NendInterstitialVideo::nadInterstitialVideoAdDidStopPlaying:" type:ATLogTypeExternal];
}

- (void)nadInterstitialVideoAdDidCompletePlaying:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd {
    [ATLogger logMessage:@"NendInterstitialVideo::nadInterstitialVideoAdDidCompletePlaying:" type:ATLogTypeExternal];
    [self trackInterstitialAdVideoEnd];
}

- (void)nadInterstitialVideoAdDidClickAd:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd {
    [ATLogger logMessage:@"NendInterstitialVideo::nadInterstitialVideoAdDidClickAd:" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
}

- (void)nadInterstitialVideoAdDidClickInformation:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd {
    [ATLogger logMessage:@"NendInterstitialVideo::nadInterstitialVideoAdDidClickInformation:" type:ATLogTypeExternal];
}

#pragma mark - interstitial video
-(void) completeFullBoardLoad:(id<ATNADFullBoard>)fullBoard errorCode:(NSInteger)error {
    if (fullBoard != nil) {
        [self trackInterstitialAdLoaded:fullBoard adExtra:nil];
    } else {
        [self trackInterstitialAdLoadFailed:[NSError errorWithDomain:@"com.anythink.NendFullBoardLoading" code:error userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load interstitial", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"NADFullBoard has failed to load ad with error code:%ld", error]}]];
    }
}

- (void)NADFullBoardDidShowAd:(id<ATNADFullBoard>)ad {
    [ATLogger logMessage:@"NendInterstitialFullBoard::NADFullBoardDidShowAd:" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
}

- (void)NADFullBoardDidDismissAd:(id<ATNADFullBoard>)ad {
    [ATLogger logMessage:@"NendInterstitialFullBoard::NADFullBoardDidDismissAd:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
}

- (void)NADFullBoardDidClickAd:(id<ATNADFullBoard>)ad {
    [ATLogger logMessage:@"NendInterstitialFullBoard::NADFullBoardDidClickAd:" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"spot_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"spot_id"];
//    return extra;
//}
@end
