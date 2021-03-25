//
//  ATMopubRewardedVideoCustomEvent.m
//  AnyThinkMopubRewardedVideoAdapter
//
//  Created by Martin Lau on 10/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMopubRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "Utilities.h"

@interface ATMopubRewardedVideoCustomEvent()
@property(nonatomic) BOOL rewarded;
@end
@implementation ATMopubRewardedVideoCustomEvent
- (void)rewardedVideoAdDidLoadForAdUnitID:(NSString *)adUnitID {
    [ATLogger logMessage:@"Mopub: rewardedVideoAdDidLoadForAdUnitID" type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoaded:adUnitID adExtra:nil];
}

- (void)rewardedVideoAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    [ATLogger logError:[NSString stringWithFormat:@"Mopub: rewardedVideoAdDidFailToLoadForAdUnitID:%@, error:%@", adUnitID, error] type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoadFailed:error];
}

- (void)rewardedVideoAdDidExpireForAdUnitID:(NSString *)adUnitID {
    [ATLogger logMessage:@"Mopub: rewardedVideoAdDidExpireForAdUnitID" type:ATLogTypeExternal];
}

- (void)rewardedVideoAdDidFailToPlayForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    [ATLogger logError:[NSString stringWithFormat:@"Mopub: rewardedVideoAdDidFailToPlayForAdUnitID:%@ error:%@", adUnitID, error] type:ATLogTypeExternal];
    [self trackRewardedVideoAdPlayEventWithError:error];
}

- (void)rewardedVideoAdWillAppearForAdUnitID:(NSString *)adUnitID {
    [ATLogger logMessage:@"Mopub: rewardedVideoAdWillAppearForAdUnitID" type:ATLogTypeExternal];
}

- (void)rewardedVideoAdDidAppearForAdUnitID:(NSString *)adUnitID {
    [ATLogger logMessage:@"Mopub: rewardedVideoAdDidAppearForAdUnitID" type:ATLogTypeExternal];
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

- (void)rewardedVideoAdWillDisappearForAdUnitID:(NSString *)adUnitID {
    [ATLogger logMessage:@"Mopub: rewardedVideoAdWillDisappearForAdUnitID" type:ATLogTypeExternal];
}

- (void)rewardedVideoAdDidDisappearForAdUnitID:(NSString *)adUnitID {
    [ATLogger logMessage:@"Mopub: rewardedVideoAdDidDisappearForAdUnitID" type:ATLogTypeExternal];
    [self trackRewardedVideoAdCloseRewarded:_rewarded];
    [[ATRewardedVideoManager sharedManager] removeCustomEventForKey:self.rewardedVideo.placementModel.placementID];
}

- (void)rewardedVideoAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID {
    [ATLogger logMessage:@"Mopub: rewardedVideoAdDidReceiveTapEventForAdUnitID" type:ATLogTypeExternal];
    [self trackRewardedVideoAdClick];
}

- (void)rewardedVideoAdWillLeaveApplicationForAdUnitID:(NSString *)adUnitID {
    [ATLogger logMessage:@"Mopub: rewardedVideoAdWillLeaveApplicationForAdUnitID" type:ATLogTypeExternal];
}

- (void)rewardedVideoAdShouldRewardForAdUnitID:(NSString *)adUnitID reward:(id<ATRewardedVideoReward>)reward {
    [ATLogger logMessage:@"Mopub: rewardedVideoAdShouldRewardForAdUnitID:reward:" type:ATLogTypeExternal];
    _rewarded = YES;
    [self trackRewardedVideoAdRewarded];
    [self trackRewardedVideoAdVideoEnd];
    
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"unitid"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"unitid"];
//    return extra;
//}
@end
