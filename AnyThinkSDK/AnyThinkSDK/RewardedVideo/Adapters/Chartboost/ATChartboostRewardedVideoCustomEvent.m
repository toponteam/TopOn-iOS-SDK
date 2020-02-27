//
//  ATChartboostRewardedVideoCustomEvent.m
//  AnyThinkChartboostRewardedVideoAdapter
//
//  Created by Martin Lau on 10/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATChartboostRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "Utilities.h"
@interface ATChartboostRewardedVideoCustomEvent()
@end

@implementation ATChartboostRewardedVideoCustomEvent
-(instancetype) initWithUnitID:(NSString *)unitID customInfo:(NSDictionary *)customInfo {
    self = [super initWithUnitID:unitID customInfo:customInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadedNotification:) name:kChartboostRewardedVideoLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadingFailureNotification:) name:kChartboostRewardedVideoLoadingFailedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleImpressionNotification:) name:kChartboostRewardedVideoImpressionNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClickNotification:) name:kChartboostRewardedVideoClickNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleVideoEndNotification:) name:kChartboostRewardedVideoVideoEndNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCloseNotification:) name:kChartboostRewardedVideoCloseNotification object:nil];
    }
    return self;
}

-(void) handleLoadedNotification:(NSNotification*)notification {
    if ([self.unitID isEqualToString:notification.userInfo[kChartboostRewardedVideoNotificationUserInfoLocationKey]]) {
        [self handleAssets:@{kRewardedVideoAssetsUnitIDKey:self.unitID, kAdAssetsCustomObjectKey:self.unitID, kRewardedVideoAssetsCustomEventKey:self}];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kChartboostRewardedVideoLoadedNotification object:nil];
    }
}

-(void) handleLoadingFailureNotification:(NSNotification*)notification {
    if ([self.unitID isEqualToString:notification.userInfo[kChartboostRewardedVideoNotificationUserInfoLocationKey]]) {
        [self handleLoadingFailure:notification.userInfo[kChartboostRewardedVideoNotificationUserInfoErrorKey]];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kChartboostRewardedVideoLoadedNotification object:nil];
    }
}

-(void) handleImpressionNotification:(NSNotification*)notification {
    if ([self.unitID isEqualToString:notification.userInfo[kChartboostRewardedVideoNotificationUserInfoLocationKey]]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kChartboostRewardedVideoImpressionNotification object:nil];
        [self trackShow];
        [self trackVideoStart];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
            [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
        }
    }
}

-(void) handleClickNotification:(NSNotification*)notification {
    if ([self.unitID isEqualToString:notification.userInfo[kChartboostRewardedVideoNotificationUserInfoLocationKey]]) {
        [self trackClick];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) {
            [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
        }
    }
}

-(void) handleCloseNotification:(NSNotification*)notification {
    if ([self.unitID isEqualToString:notification.userInfo[kChartboostRewardedVideoNotificationUserInfoLocationKey]]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self handleClose];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
            [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
        }
    }
}

-(void) handleVideoEndNotification:(NSNotification*)notification {
    if ([self.unitID isEqualToString:notification.userInfo[kChartboostRewardedVideoNotificationUserInfoLocationKey]]) {
        self.rewardGranted = [notification.userInfo[kChartboostRewardedVideoNotificationUserInfoRewardedFlagKey] boolValue];
        [self trackVideoEnd];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) {
            [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
        }
        if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){
            [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
        }
    }
}
@end
