//
//  ATIronSourceRewardedVideoCustomEvent.m
//  AnyThinkIronSourceRewardedVideoAdapter
//
//  Created by Martin Lau on 09/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATIronSourceRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "Utilities.h"

@interface ATIronSourceRewardedVideoCustomEvent()
@end
@implementation ATIronSourceRewardedVideoCustomEvent
-(instancetype) initWithUnitID:(NSString *)unitID customInfo:(NSDictionary *)customInfo {
    self = [super initWithUnitID:unitID customInfo:customInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoaded:) name:kATIronSourceRVNotificationLoaded object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShow:) name:kATIronSourceRVNotificationShow object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadFailed:) name:kATIronSourceRVNotificationLoadFailed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClose:) name:kATIronSourceRVNotificationClose object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClick:) name:kATIronSourceRVNotificationClick object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReward:) name:kATIronSourceRVNotificationReward object:nil];
    }
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) handleLoaded:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceRVNotificationUserInfoInstanceIDKey] isEqualToString:self.unitID]) {
        [self handleAssets:@{kRewardedVideoAssetsCustomEventKey:self, kRewardedVideoAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kAdAssetsCustomObjectKey:self.unitID != nil ? self.unitID : @""}];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATIronSourceRVNotificationLoaded object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATIronSourceRVNotificationLoadFailed object:nil];
    }
}

-(void) handleLoadFailed:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceRVNotificationUserInfoInstanceIDKey] isEqualToString:self.unitID]) {
        NSError *error = notification.userInfo[kATIronSourceRVNotificationUserInfoErrorKey];
        [self handleLoadingFailure:error];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATIronSourceRVNotificationLoaded object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATIronSourceRVNotificationLoadFailed object:nil];
    }
}

-(void) handleShowFailed:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceRVNotificationUserInfoInstanceIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        NSError *error = notification.userInfo[kATIronSourceRVNotificationUserInfoErrorKey];
        [self saveVideoPlayEventWithError:error];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForPlacementID:error:extra:)]) { [self.delegate rewardedVideoDidFailToPlayForPlacementID:self.rewardedVideo.placementModel.placementID error:error extra:[self delegateExtra]]; }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATIronSourceRVNotificationShow object:nil];
    }
}

-(void) handleShow:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceRVNotificationUserInfoInstanceIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        [self trackShow];
        [self trackVideoStart];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
            [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATIronSourceRVNotificationShow object:nil];
    }
}

-(void) handleClick:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceRVNotificationUserInfoInstanceIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        [self trackClick];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) {
            [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
        }
    }
}

-(void) handleClose:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceRVNotificationUserInfoInstanceIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        [self handleClose];
        [self trackVideoEnd];
        [self saveVideoCloseEventRewarded:self.rewardGranted];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) {
            [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
        }
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
            [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:[self delegateExtra]];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATIronSourceRVNotificationClose object:nil];
    }
}

-(void) handleReward:(NSNotification*)notification {
    self.rewardGranted = YES;
    if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){
        [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATIronSourceRVNotificationReward object:nil];
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"instance_id"];
    return extra;
}
@end
