//
//  ATMyTargetRewardedVideoCustomEvent.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/12/25.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATMyTargetRewardedVideoCustomEvent.h"
#import "ATLogger.h"

@interface ATMyTargetRewardedVideoCustomEvent()

@end

@implementation ATMyTargetRewardedVideoCustomEvent

// MARK:- MTRGRewardedAdDelegate

- (void)onLoadWithRewardedAd:(id<ATMTRGRewardedAd>)rewardedAd {
    [ATLogger logMessage:@"ATMyTargetRewardedVideo::onLoadWithRewardedAd:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoaded:rewardedAd adExtra:@{kAdAssetsPriceKey: _price ? _price : @"", kAdAssetsBidIDKey: _bidID ? _bidID : @""}];
}

- (void)onNoAdWithReason:(NSString *)reason rewardedAd:(id<ATMTRGRewardedAd>)rewardedAd {
    [ATLogger logMessage:[NSString stringWithFormat:@"ATMyTargetRewardedVideo::onNoAdWithReason:%@",reason] type:ATLogTypeExternal];
    NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:1 userInfo:@{NSLocalizedFailureReasonErrorKey: reason}];
    [self trackRewardedVideoAdLoadFailed:error];
}

- (void)onReward:(id<ATMTRGReward>)reward rewardedAd:(id<ATMTRGRewardedAd>)rewardedAd {
    [ATLogger logMessage:@"ATMyTargetRewardedVideo::onReward:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdRewarded];
}

- (void)onClickWithRewardedAd:(id<ATMTRGRewardedAd>)rewardedAd {
    [ATLogger logMessage:@"ATMyTargetRewardedVideo::onClickWithRewardedAd:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdClick];
}

- (void)onCloseWithRewardedAd:(id<ATMTRGRewardedAd>)rewardedAd {
    [ATLogger logMessage:@"ATMyTargetRewardedVideo::onCloseWithRewardedAd:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdCloseRewarded:self.rewardGranted];
}

- (void)onDisplayWithRewardedAd:(id<ATMTRGRewardedAd>)rewardedAd {
    [ATLogger logMessage:@"ATMyTargetRewardedVideo::onDisplayWithRewardedAd:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

- (void)onLeaveApplicationWithRewardedAd:(id<ATMTRGRewardedAd>)rewardedAd {
    [ATLogger logMessage:@"ATMyTargetRewardedVideo::onLeaveApplicationWithRewardedAd:" type:ATLogTypeExternal];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"];
}

@end
