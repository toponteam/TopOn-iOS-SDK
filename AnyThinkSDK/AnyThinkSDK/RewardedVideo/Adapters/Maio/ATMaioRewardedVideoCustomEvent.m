//
//  ATMaioRewardedVideoCustomEvent.m
//  AnyThinkMaioRewardedVideoAdapter
//
//  Created by Martin Lau on 2019/4/16.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATMaioRewardedVideoCustomEvent.h"
#import "ATMaioRewardedVideoAdapter.h"
#import "Utilities.h"
#import "ATRewardedVideoManager.h"
@implementation ATMaioRewardedVideoCustomEvent
- (void)maioDidInitialize {
    [ATLogger logMessage:@"MaioRewardedVideo::maioDidInitialize" type:ATLogTypeExternal];
}

- (void)maioDidChangeCanShow:(NSString *)zoneId newValue:(BOOL)newValue {
    [ATLogger logMessage:[NSString stringWithFormat:@"MaioRewardedVideo::maioDidChangeCanShow:%@ newValue:%@", zoneId, newValue ? @"yes" : @"no"] type:ATLogTypeExternal];
    if ([zoneId isEqualToString:self.unitID] && newValue) { [self handleAssets:@{kRewardedVideoAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kRewardedVideoAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:self.unitID != nil ? self.unitID : @""}]; }
}

- (void)maioWillStartAd:(NSString *)zoneId {
    [ATLogger logMessage:[NSString stringWithFormat:@"MaioRewardedVideo::maioWillStartAd:%@", zoneId] type:ATLogTypeExternal];
    if ([zoneId isEqualToString:self.unitID]) {
        [self trackShow];
        [self trackVideoStart];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
            [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
        }
    }
}
- (void)maioDidFinishAd:(NSString *)zoneId playtime:(NSInteger)playtime skipped:(BOOL)skipped rewardParam:(NSString *)rewardParam {
    [ATLogger logMessage:[NSString stringWithFormat:@"MaioRewardedVideo::maioDidFinishAd:%@ playtime:%ld skipped:%@ rewardParam:%@", zoneId, playtime, skipped ? @"yes" : @"no", rewardParam] type:ATLogTypeExternal];
    if ([zoneId isEqualToString:self.unitID]) {
        self.rewardGranted = !skipped;
        if (!skipped) {
            [self trackVideoEnd];
            if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){
                [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID)}];
            }
        }
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) {
            [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
        }
    }
}

- (void)maioDidClickAd:(NSString *)zoneId {
    [ATLogger logMessage:[NSString stringWithFormat:@"MaioRewardedVideo::maioDidClickAd:%@", zoneId] type:ATLogTypeExternal];
    if ([zoneId isEqualToString:self.unitID]) {
        [self trackClick];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) {
            [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
        }
    }
}

- (void)maioDidCloseAd:(NSString *)zoneId {
    [ATLogger logMessage:[NSString stringWithFormat:@"MaioRewardedVideo::maioDidCloseAd:%@", zoneId] type:ATLogTypeExternal];
    if ([zoneId isEqualToString:self.unitID]) {
        [NSClassFromString(@"Maio") removeDelegateObject:self];
        [self handleClose];
        [self saveVideoCloseEventRewarded:self.rewardGranted];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
            [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
        }
    }
}

- (void)maioDidFail:(NSString *)zoneId reason:(NSInteger)reason {
    [ATLogger logMessage:[NSString stringWithFormat:@"MaioRewardedVideo::maioDidFail:%@ reason:%ld", zoneId, reason] type:ATLogTypeExternal];
    if ([zoneId isEqualToString:self.unitID]) {
        [self handleLoadingFailure:[NSError errorWithDomain:@"com.anythink.MaioRewardedVideoLoading" code:reason userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load rewarded video for Maio", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Maio rewarded video load has failed with reason:%ld", reason]}]];
        [NSClassFromString(@"Maio") removeDelegateObject:self];
    }
}
@end
