//
//  ATUnityAdsRewardedVideoCustomEvent.m
//  AnyThinkUnityAdsRewardedVideoAdapter
//
//  Created by Martin Lau on 11/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATUnityAdsRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "Utilities.h"

@interface ATUnityAdsRewardedVideoCustomEvent()
@property(nonatomic, readonly) BOOL requestFinished;
@end
@implementation ATUnityAdsRewardedVideoCustomEvent
- (void)unityServicesDidError:(NSInteger)error withMessage:(NSString *)message {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsRewardedVideo::unityServicesDidError:%ld withMessage:%@", error, message] type:ATLogTypeExternal];
    [self handleLoadingFailure:[NSError errorWithDomain:@"com.anythink.UnityAdsRewardedVideoLoad" code:error userInfo:@{NSLocalizedDescriptionKey:@"anythinkSDK has failed to load rewarded video.", NSLocalizedFailureReasonErrorKey:[message length] > 0 ? message : @"UnityAds SDK has failed to load rewarded video." }]];
    _requestFinished = YES;
}

-(void)placementContentReady:(NSString *)placementId placementContent:(id<UMONShowAdPlacementContent>)decision {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsRewardedVideo::placementContentReady:%@ placementContent:", placementId] type:ATLogTypeExternal];
    if ([placementId isEqualToString:self.unitID] && !_requestFinished) {
        [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsRewardedVideo::Ad ready for placementID:%@", placementId] type:ATLogTypeExternal];
        [self handleAssets:@{kAdAssetsCustomObjectKey:decision, kRewardedVideoAssetsUnitIDKey:self.unitID, kRewardedVideoAssetsCustomEventKey:self}];
        _requestFinished = YES;
    }
}

-(void)placementContentStateDidChange:(NSString *)placementId placementContent:(id<UMONShowAdPlacementContent>)placementContent previousState:(NSInteger)previousState newState:(NSInteger)newState {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsRewardedVideo::placementContentStateDidChange:%@ placementContent:previousState:%ld newState:%ld", placementId, previousState, newState] type:ATLogTypeExternal];
    
}

- (void)unityAdsDidStart:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsRewardedVideo::unityAdsDidStart:%@", placementId] type:ATLogTypeExternal];
    if ([placementId isEqualToString:self.unitID]) {
        [self trackShow];
        [self trackVideoStart];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
            [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
        }
    }
}

- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(NSInteger)state {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsRewardedVideo::unityAdsDidFinish:withFinishState:%ld", state] type:ATLogTypeExternal];
    if ([placementId isEqualToString:self.unitID]) {
        self.rewardGranted = YES;
        [self handleClose];
        [self trackVideoEnd];
        [self saveVideoCloseEventRewarded:state == kATUnityAdsFinishStateCompleted];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) {
            [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
        }
        if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){
            [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
        }
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
            [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
        }
    }
}



@end
