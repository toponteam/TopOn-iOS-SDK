//
//  ATMintegralRewardedVideoCustomEvent.m
//  AnyThinkMintegralRewardedVideoAdapter
//
//  Created by Martin Lau on 05/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMintegralRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "Utilities.h"
@implementation ATMintegralRewardedVideoCustomEvent
#pragma mark - loading delegate
- (void)onAdLoadSuccess:(nullable NSString *)placementId unitId:(nullable NSString *)unitId {
    [ATLogger logMessage:[NSString stringWithFormat:@"MintegralRewardedVideo::onAdLoadSuccess:%@ unitId:%@", placementId, unitId] type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

- (void)onVideoAdLoadSuccess:(nullable NSString *)placementId unitId:(nullable NSString *)unitId {
    [ATLogger logMessage:[NSString stringWithFormat:@"MintegralRewardedVideo::onVideoAdLoadSuccess:%@ unitId:%@", placementId, unitId] type:ATLogTypeExternal];
    [self handleAssets:@{kRewardedVideoAssetsUnitIDKey:unitId, kAdAssetsCustomObjectKey:_rewardedVideoMgr, kRewardedVideoAssetsCustomEventKey:self}];
}

- (void)onVideoAdLoadFailed:(nullable NSString *)placementId unitId:(nullable NSString *)unitId error:(nonnull NSError *)error {
    [ATLogger logError:[NSString stringWithFormat:@"MintegralRewardedVideo:onVideoAdLoadFailed:%@ unitId:%@ error:%@", placementId, unitId, error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

#pragma mark - showing delegate
- (void)onVideoAdShowSuccess:(nullable NSString *)placementId unitId:(nullable NSString *)unitId {
    [ATLogger logMessage:[NSString stringWithFormat:@"MintegralRewardedVideo::onVideoAdShowSuccess:%@ unitId:%@", placementId, unitId] type:ATLogTypeExternal];
    [self trackShow];
    [self trackVideoStart];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) { [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]]; }
}

- (void)onVideoAdShowFailed:(nullable NSString *)placementId unitId:(nullable NSString *)unitId withError:(nonnull NSError *)error {
    [ATLogger logError:[NSString stringWithFormat:@"MintegralRewardedVideo:onVideoAdShowFailed:%@ unitId:%@ error:%@", placementId, unitId, error] type:ATLogTypeExternal];
    [self saveVideoPlayEventWithError:error];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForPlacementID:error:extra:)]) { [self.delegate rewardedVideoDidFailToPlayForPlacementID:self.rewardedVideo.placementModel.placementID error:error extra:[self delegateExtra]]; }
}

- (void) onVideoPlayCompleted:(nullable NSString *)placementId unitId:(nullable NSString *)unitId {
    [ATLogger logMessage:[NSString stringWithFormat:@"MintegralRewardedVideo::onVideoPlayCompleted:%@ unitId:%@", placementId, unitId] type:ATLogTypeExternal];
    [self trackVideoEnd];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) { [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]]; }
}

- (void) onVideoEndCardShowSuccess:(nullable NSString *)placementId unitId:(nullable NSString *)unitId { [ATLogger logMessage:[NSString stringWithFormat:@"MintegralRewardedVideo::onVideoEndCardShowSuccess:%@ unitId:%@", placementId, unitId] type:ATLogTypeExternal]; }

- (void)onVideoAdClicked:(nullable NSString *)placementId unitId:(nullable NSString *)unitId {
    [ATLogger logMessage:[NSString stringWithFormat:@"MintegralRewardedVideo::onVideoAdClicked:%@ unitId:%@", placementId, unitId] type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) { [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]]; }
}

- (void)onVideoAdDismissed:(nullable NSString *)placementId unitId:(nullable NSString *)unitId withConverted:(BOOL)converted withRewardInfo:(id<ATRVMTGRewardAdInfo>)rewardInfo {
    [ATLogger logMessage:[NSString stringWithFormat:@"MintegralRewardedVideo::onVideoAdDismissed:%@ unitId:%@ withConverted:%@ withRewardInfo", placementId, unitId, converted ? @"YES" : @"NO"] type:ATLogTypeExternal];
    self.rewardGranted = converted;
    if (converted) { if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]) { [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]]; } }
}

- (void)onVideoAdDidClosed:(nullable NSString *)placementId unitId:(nullable NSString *)unitId {
    [ATLogger logMessage:[NSString stringWithFormat:@"MintegralRewardedVideo::onVideoAdDidClosed:%@ unitId:%@", placementId, unitId] type:ATLogTypeExternal];
    [self handleClose];
    [self saveVideoCloseEventRewarded:self.rewardGranted];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) { [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:[self delegateExtra]]; }
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"unitid"];
    return extra;
}
@end
