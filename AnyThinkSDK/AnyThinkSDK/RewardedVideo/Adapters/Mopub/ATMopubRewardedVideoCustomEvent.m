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
    [self handleAssets:@{kRewardedVideoAssetsUnitIDKey:self.unitID, kAdAssetsCustomObjectKey:adUnitID}];
}

- (void)rewardedVideoAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    [ATLogger logError:[NSString stringWithFormat:@"Mopub: rewardedVideoAdDidFailToLoadForAdUnitID:%@, error:%@", adUnitID, error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (void)rewardedVideoAdDidExpireForAdUnitID:(NSString *)adUnitID {
    [ATLogger logMessage:@"Mopub: rewardedVideoAdDidExpireForAdUnitID" type:ATLogTypeExternal];
}

- (void)rewardedVideoAdDidFailToPlayForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    [ATLogger logError:[NSString stringWithFormat:@"Mopub: rewardedVideoAdDidFailToPlayForAdUnitID:%@ error:%@", adUnitID, error] type:ATLogTypeExternal];
    [self saveVideoPlayEventWithError:error];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForPlacementID:error:extra:)]) { [self.delegate rewardedVideoDidFailToPlayForPlacementID:self.rewardedVideo.placementModel.placementID error:error extra:[self delegateExtra]]; }
}

- (void)rewardedVideoAdWillAppearForAdUnitID:(NSString *)adUnitID {
    [ATLogger logMessage:@"Mopub: rewardedVideoAdWillAppearForAdUnitID" type:ATLogTypeExternal];
}

- (void)rewardedVideoAdDidAppearForAdUnitID:(NSString *)adUnitID {
    [ATLogger logMessage:@"Mopub: rewardedVideoAdDidAppearForAdUnitID" type:ATLogTypeExternal];
    [self trackShow];
    [self trackVideoStart];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)rewardedVideoAdWillDisappearForAdUnitID:(NSString *)adUnitID {
    [ATLogger logMessage:@"Mopub: rewardedVideoAdWillDisappearForAdUnitID" type:ATLogTypeExternal];
}

- (void)rewardedVideoAdDidDisappearForAdUnitID:(NSString *)adUnitID {
    [ATLogger logMessage:@"Mopub: rewardedVideoAdDidDisappearForAdUnitID" type:ATLogTypeExternal];
    [self handleClose];
    [self saveVideoCloseEventRewarded:_rewarded];
    [[ATRewardedVideoManager sharedManager] removeCustomEventForKey:self.rewardedVideo.placementModel.placementID];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
        [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:[self delegateExtra]];
    }
}

- (void)rewardedVideoAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID {
    [ATLogger logMessage:@"Mopub: rewardedVideoAdDidReceiveTapEventForAdUnitID" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)rewardedVideoAdWillLeaveApplicationForAdUnitID:(NSString *)adUnitID {
    [ATLogger logMessage:@"Mopub: rewardedVideoAdWillLeaveApplicationForAdUnitID" type:ATLogTypeExternal];
}

- (void)rewardedVideoAdShouldRewardForAdUnitID:(NSString *)adUnitID reward:(id<ATRewardedVideoReward>)reward {
    [ATLogger logMessage:@"Mopub: rewardedVideoAdShouldRewardForAdUnitID:reward:" type:ATLogTypeExternal];
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
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"unitid"];
    return extra;
}
@end
