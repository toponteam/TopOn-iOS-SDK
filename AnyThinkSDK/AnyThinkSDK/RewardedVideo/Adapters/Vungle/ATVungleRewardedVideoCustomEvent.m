//
//  ATVungleRewardedVideoCustomEvent.m
//  AnyThinkVungleRewardedVideoAdapter
//
//  Created by Martin Lau on 11/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATVungleRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "ATLogger.h"

@implementation ATVungleRewardedVideoCustomEvent
-(void) handlerPlayError:(NSError*)error {
    [ATLogger logError:[NSString stringWithFormat:@"VungleRewardedVideo::handlerPlayError:%@", error] type:ATLogTypeExternal];
    [self saveVideoPlayEventWithError:error];
    [[ATRewardedVideoManager sharedManager] removeCustomEventForKey:self.rewardedVideo.placementModel.placementID];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForPlacementID:error:extra:)]) { [self.delegate rewardedVideoDidFailToPlayForPlacementID:self.rewardedVideo.placementModel.placementID error:error extra:[self delegateExtra]]; }
}

-(instancetype) initWithUnitID:(NSString *)unitID customInfo:(NSDictionary *)customInfo {
    self = [super initWithUnitID:unitID customInfo:customInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadNotification:) name:kVungleRewardedVideoLoadNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShowNotification:) name:kVungleRewardedVideoShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCloseNotification:) name:kVungleRewardedVideoCloseNotification object:nil];
    }
    return self;
}

-(void) handleLoadNotification:(NSNotification*)notification {
    if ([notification.userInfo[kVungleRewardedVideoNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID]) {
        [ATLogger logMessage:@"VungleRewardedVideo::load" type:ATLogTypeExternal];
        [self handleAssets:@{kRewardedVideoAssetsCustomEventKey:self, kRewardedVideoAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kAdAssetsCustomObjectKey:self.unitID}];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kVungleRewardedVideoLoadNotification object:nil];
    }
}

-(void) handleShowNotification:(NSNotification*)notification {
    if ([notification.userInfo[kVungleRewardedVideoNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        [ATLogger logMessage:@"VungleRewardedVideo::show" type:ATLogTypeExternal];
        [self trackShow];
        [self trackVideoStart];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
            [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kVungleRewardedVideoShowNotification object:nil];
    }
}

-(void) handleCloseNotification:(NSNotification*)notification {
    if ([notification.userInfo[kVungleRewardedVideoNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        [ATLogger logMessage:@"VungleRewardedVideo::close" type:ATLogTypeExternal];
        if ([notification.userInfo[kVungleRewardedVideoNotificationUserInfoClickFlagKey] boolValue]) {
            [self trackClick];
            if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) {
                [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
            }
        }
        if ([notification.userInfo[kVungleRewardedVideoNotificationUserInfoVideoCompletedFlagKey] boolValue]) {
            [self trackVideoEnd];
            if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) {
                [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
            }
            self.rewardGranted = YES;
            if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){
                [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
            }
        }
        [self handleClose];
        [self saveVideoCloseEventRewarded:self.rewardGranted];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
            [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:[self delegateExtra]];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kVungleRewardedVideoCloseNotification object:nil];
    }
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"placement_id"];
    return extra;
}
@end
