//
//  ATYeahmobiRewardedVideoCustomEvent.m
//  AnyThinkYeahmobiRewardedVideoAdapter
//
//  Created by Martin Lau on 2018/10/17.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATYeahmobiRewardedVideoCustomEvent.h"
#import "Utilities.h"
#import "ATRewardedVideoManager.h"
@interface ATYeahmobiRewardedVideoCustomEvent()
@property(nonatomic, readonly) BOOL rewarded;
@end
@implementation ATYeahmobiRewardedVideoCustomEvent
- (void)CTRewardVideoLoadSuccess {
    [ATLogger logMessage:@"YeahmobiRewardedVideo::CTRewardVideoLoadSuccess" type:ATLogTypeExternal];
    [self handleAssets:@{kRewardedVideoAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kRewardedVideoAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:[self.unitID length] > 0 ? self.unitID : @""}];
}

- (void)CTRewardVideoDidStartPlaying {
    [ATLogger logMessage:@"YeahmobiRewardedVideo::CTRewardVideoDidStartPlaying" type:ATLogTypeExternal];
    [self trackShow];
    [self trackVideoStart];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
}

- (void)CTRewardVideoDidFinishPlaying {
    [ATLogger logMessage:@"YeahmobiRewardedVideo::CTRewardVideoDidFinishPlaying" type:ATLogTypeExternal];
    [self trackVideoEnd];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
}

- (void)CTRewardVideoDidClickRewardAd {
    [ATLogger logMessage:@"YeahmobiRewardedVideo::CTRewardVideoDidClickRewardAd" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
}

- (void)CTRewardVideoWillLeaveApplication {
    [ATLogger logMessage:@"YeahmobiRewardedVideo::CTRewardVideoWillLeaveApplication" type:ATLogTypeExternal];
}

- (void)CTRewardVideoJumpfailed {
    [ATLogger logMessage:@"YeahmobiRewardedVideo::CTRewardVideoJumpfailed" type:ATLogTypeExternal];
}

- (void)CTRewardVideoLoadingFailed:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"YeahmobiRewardedVideo::CTRewardVideoLoadingFailed:%@", error] type:ATLogTypeExternal];
}

- (void)CTRewardVideoClosed {
    [ATLogger logMessage:@"YeahmobiRewardedVideo::CTRewardVideoClosed" type:ATLogTypeExternal];
    [self handleClose];
    [self saveVideoCloseEventRewarded:_rewarded];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
        [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
}

- (void)CTRewardVideoAdRewardedName:(NSString *)rewardName rewardAmount:(NSString *)rewardAmount customParams:(NSString*) customParams {
    [ATLogger logMessage:[NSString stringWithFormat:@"YeahmobiRewardedVideo::CTRewardVideoAdRewardedName:%@ rewardAmount:%@ customParams:%@", rewardName, rewardAmount, customParams] type:ATLogTypeExternal];
    _rewarded = YES;
    self.rewardGranted = YES;
    if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){
        [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
}
@end
