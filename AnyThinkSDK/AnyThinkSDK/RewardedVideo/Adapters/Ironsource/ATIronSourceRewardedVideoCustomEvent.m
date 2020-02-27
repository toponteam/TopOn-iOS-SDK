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
    }
}

-(void) handleLoadFailed:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceRVNotificationUserInfoInstanceIDKey] isEqualToString:self.unitID]) {
        NSError *error = notification.userInfo[kATIronSourceRVNotificationUserInfoErrorKey];
        [self handleLoadingFailure:error];
    }
}

-(void) handleShowFailed:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceRVNotificationUserInfoInstanceIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        NSError *error = notification.userInfo[kATIronSourceRVNotificationUserInfoErrorKey];
        [self saveVideoPlayEventWithError:error];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForPlacementID:error:extra:)]) { [self.delegate rewardedVideoDidFailToPlayForPlacementID:self.rewardedVideo.placementModel.placementID error:error extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}]; }
    }
}

-(void) handleShow:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceRVNotificationUserInfoInstanceIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        [self trackShow];
        [self trackVideoStart];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
            [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
        }
    }
}

-(void) handleClick:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceRVNotificationUserInfoInstanceIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        [self trackClick];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) {
            [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
        }
    }
}

-(void) handleClose:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceRVNotificationUserInfoInstanceIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        [self handleClose];
        [self trackVideoEnd];
        [self saveVideoCloseEventRewarded:self.rewardGranted];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) {
            [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
        }
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
            [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
        }
    }
}

-(void) handleReward:(NSNotification*)notification {
    self.rewardGranted = YES;
    if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){
        [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
}
@end
