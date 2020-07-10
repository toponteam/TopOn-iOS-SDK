//
//  ATOnewayRewardedVideoCustomEvent.m
//  AnyThinkOnewayRewardedVideoAdapter
//
//  Created by Martin Lau on 30/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATOnewayRewardedVideoCustomEvent.h"
#import "Utilities.h"
#import <objc/runtime.h>
#import "ATRewardedVideoManager.h"
#import "ATAdAdapter.h"
@implementation ATOnewayRewardedVideoCustomEvent
-(instancetype) initWithUnitID:(NSString *)unitID customInfo:(NSDictionary *)customInfo {
    self = [super initWithUnitID:unitID customInfo:customInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReadyNotification:) name:kATOnewayRVReadyNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleErrorNotification:) name:kATOnewayRVErrorNotification object:nil];
    }
    return self;
}

-(void) handleErrorNotification:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATOnewayRVReadyNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATOnewayRVErrorNotification object:nil];
}

-(void) handleReadyNotification:(NSNotification*)notification {
    [self handleAssets:@{kRewardedVideoAssetsUnitIDKey:self.unitID, kAdAssetsCustomObjectKey:self, kRewardedVideoAssetsCustomEventKey:self}];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATOnewayRVReadyNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATOnewayRVErrorNotification object:nil];
}

-(void) handleShowNotification:(NSNotification*)notification {
    [self trackShow];
    [self trackVideoStart];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATOnewayRVShowNotification object:nil];
}

-(void) handleClickNotification:(NSNotification*)notification {
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) { [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]]; }
}

-(void) handleCloseNotification:(NSNotification*)notification {
    NSNumber *state = notification.userInfo[kATOnewayRVNotificationUserInfoStateKey];
    self.rewardGranted = [state integerValue] == 2;
    [self handleClose];
    [self saveVideoCloseEventRewarded:[state integerValue] == 2];
    if ([state integerValue] == 2) { if ([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){ [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]]; } }
    
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) { [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:[self delegateExtra]]; }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATOnewayRVClickNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATOnewayRVCloseNotification object:nil];
}

-(void) handleFinishNotification:(NSNotification*)notification {
    NSNumber *state = notification.userInfo[kATOnewayRVNotificationUserInfoStateKey];
    if ([state integerValue] == 2) {
        [self trackVideoEnd];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) { [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]]; }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATOnewayRVFinishNotification object:nil];
}

-(void) showWithTag:(NSString*)tag {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShowNotification:) name:kATOnewayRVShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClickNotification:) name:kATOnewayRVClickNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCloseNotification:) name:kATOnewayRVCloseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFinishNotification:) name:kATOnewayRVFinishNotification object:nil];
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = @"";
    return extra;
}
@end
