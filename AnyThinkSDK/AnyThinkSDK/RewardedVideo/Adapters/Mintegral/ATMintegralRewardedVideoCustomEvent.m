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
    [self trackRewardedVideoAdLoaded:_rewardedVideoMgr adExtra:nil];
}

- (void)onVideoAdLoadFailed:(nullable NSString *)placementId unitId:(nullable NSString *)unitId error:(nonnull NSError *)error {
    [ATLogger logError:[NSString stringWithFormat:@"MintegralRewardedVideo:onVideoAdLoadFailed:%@ unitId:%@ error:%@", placementId, unitId, error] type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoadFailed:error];
}

#pragma mark - showing delegate
- (void)onVideoAdShowSuccess:(nullable NSString *)placementId unitId:(nullable NSString *)unitId {
    [ATLogger logMessage:[NSString stringWithFormat:@"MintegralRewardedVideo::onVideoAdShowSuccess:%@ unitId:%@", placementId, unitId] type:ATLogTypeExternal];
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

- (void)onVideoAdShowFailed:(nullable NSString *)placementId unitId:(nullable NSString *)unitId withError:(nonnull NSError *)error {
    [ATLogger logError:[NSString stringWithFormat:@"MintegralRewardedVideo:onVideoAdShowFailed:%@ unitId:%@ error:%@", placementId, unitId, error] type:ATLogTypeExternal];
    [self trackRewardedVideoAdPlayEventWithError:error];
}

- (void) onVideoPlayCompleted:(nullable NSString *)placementId unitId:(nullable NSString *)unitId {
    [ATLogger logMessage:[NSString stringWithFormat:@"MintegralRewardedVideo::onVideoPlayCompleted:%@ unitId:%@", placementId, unitId] type:ATLogTypeExternal];
    [self trackRewardedVideoAdVideoEnd];
}

- (void) onVideoEndCardShowSuccess:(nullable NSString *)placementId unitId:(nullable NSString *)unitId { [ATLogger logMessage:[NSString stringWithFormat:@"MintegralRewardedVideo::onVideoEndCardShowSuccess:%@ unitId:%@", placementId, unitId] type:ATLogTypeExternal]; }

- (void)onVideoAdClicked:(nullable NSString *)placementId unitId:(nullable NSString *)unitId {
    [ATLogger logMessage:[NSString stringWithFormat:@"MintegralRewardedVideo::onVideoAdClicked:%@ unitId:%@", placementId, unitId] type:ATLogTypeExternal];
    [self trackRewardedVideoAdClick];
}

- (void)onVideoAdDismissed:(nullable NSString *)placementId unitId:(nullable NSString *)unitId withConverted:(BOOL)converted withRewardInfo:(id<ATRVMTGRewardAdInfo>)rewardInfo {
    [ATLogger logMessage:[NSString stringWithFormat:@"MintegralRewardedVideo::onVideoAdDismissed:%@ unitId:%@ withConverted:%@ withRewardInfo", placementId, unitId, converted ? @"YES" : @"NO"] type:ATLogTypeExternal];
    self.rewardGranted = converted;
    if (converted) {
        [self trackRewardedVideoAdRewarded];
    }
}

- (void)onVideoAdDidClosed:(nullable NSString *)placementId unitId:(nullable NSString *)unitId {
    [ATLogger logMessage:[NSString stringWithFormat:@"MintegralRewardedVideo::onVideoAdDidClosed:%@ unitId:%@", placementId, unitId] type:ATLogTypeExternal];
    [self trackRewardedVideoAdCloseRewarded:self.rewardGranted];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"unitid"];
}


//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"unitid"];
//    return extra;
//}
@end
