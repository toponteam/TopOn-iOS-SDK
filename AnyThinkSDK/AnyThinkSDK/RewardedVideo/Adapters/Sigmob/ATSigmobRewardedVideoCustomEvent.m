//
//  ATSigmobRewardedVideoCustomEvent.m
//  AnyThinkSigmobRewardedVideoAdapter
//
//  Created by Martin Lau on 2019/9/9.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATSigmobRewardedVideoCustomEvent.h"
#import "Utilities.h"
#import "ATRewardedVideoManager.h"
#import "ATSigmobRewardedVideoAdapter.h"
@implementation ATSigmobRewardedVideoCustomEvent
-(instancetype) initWithUnitID:(NSString *)unitID customInfo:(NSDictionary *)customInfo {
    self = [super initWithUnitID:unitID customInfo:customInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadedNotification:) name:kATSigmobRVLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFailedToLoadNotification:) name:kATSigmobRVFailedToLoadNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStartPlayingNotification:) name:kATSigmobRVPlayStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEndPlayingNotification:) name:kATSigmobRVPlayEndNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePlayErrorNotification:) name:kATSigmobRVFailedToPlayNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCloseNotification:) name:kATSigmobRVCloseNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClickNotification:) name:kATSigmobRVClickNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataLoadedNotification:) name:kATSigmobRVDataLoadedNotification object:nil];
    }
    return self;
}

-(void) handleDataLoadedNotification:(NSNotification*)notification {
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

-(void) handleLoadedNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobRVNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID]) {
        [self handleAssets:@{kRewardedVideoAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kRewardedVideoAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:self}];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobRVLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobRVFailedToLoadNotification object:nil];
    }
}

-(void) handleFailedToLoadNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobRVNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID]) {
        [self handleLoadingFailure:notification.userInfo[kATSigmobRVNotificationUserInfoErrorKey]];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobRVLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobRVFailedToLoadNotification object:nil];
    }
}

-(void) handlePlayErrorNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobRVNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        NSError *error = notification.userInfo[kATSigmobRVNotificationUserInfoErrorKey];
        [self saveVideoPlayEventWithError:error];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForPlacementID:error:extra:)]) { [self.delegate rewardedVideoDidFailToPlayForPlacementID:self.rewardedVideo.placementModel.placementID error:error extra:[self delegateExtra]]; }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobRVPlayStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobRVPlayEndNotification object:nil];
    }
}

-(void) handleStartPlayingNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobRVNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        [self trackShow];
        [self trackVideoStart];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
            [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobRVPlayStartNotification object:nil];
    }
}

-(void) handleEndPlayingNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobRVNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        [self trackVideoEnd];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) {
            [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobRVPlayEndNotification object:nil];
    }
}

-(void) handleClickNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobRVNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        [self trackClick];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) {
            [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
        }
    }
}

-(void) handleCloseNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobRVNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        self.rewardGranted = [notification.userInfo[kATSigmobRVNotificationUserInfoRewardedFlag] boolValue];
        [self handleClose];
        [self saveVideoCloseEventRewarded:self.rewardGranted];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
            [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:[self delegateExtra]];
        }
        if (self.rewardGranted) {
            if ([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]) {
                [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
            }
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobRVClickNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobRVCloseNotification object:nil];
    }
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"placement_id"];
    return extra;
}
@end
