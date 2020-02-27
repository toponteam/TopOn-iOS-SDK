//
//  ATFacebookRewardedVideoCustomEvent.m
//  AnyThinkFacebookRewardedVideoAdapter
//
//  Created by Martin Lau on 10/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATFacebookRewardedVideoCustomEvent.h"
#import "Utilities.h"
#import <objc/runtime.h>
#import "ATRewardedVideoManager.h"
@interface ATFacebookRewardedVideoCustomEvent()
@property(nonatomic) BOOL rewarded;

@end
@implementation ATFacebookRewardedVideoCustomEvent

- (void)rewardedVideoAdDidClick:(id<ATFBRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"FacebookRewardedVideo::rewardedVideoAdDidClick:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
}

- (void)rewardedVideoAdDidLoad:(id<ATFBRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"FacebookRewardedVideo::rewardedVideoAdDidLoad:" type:ATLogTypeExternal];
    objc_setAssociatedObject(rewardedVideoAd, (__bridge_retained void*)kFacebookRVCustomEventKey, self, OBJC_ASSOCIATION_RETAIN);
    [self handleAssets:@{kRewardedVideoAssetsUnitIDKey:self.unitID, kAdAssetsCustomObjectKey:rewardedVideoAd}];
}

- (void)rewardedVideoAdDidClose:(id<ATFBRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"FacebookRewardedVideo::rewardedVideoAdDidClose:" type:ATLogTypeExternal];
    [self handleClose];
    [self saveVideoCloseEventRewarded:_rewarded];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
        [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
}

- (void)rewardedVideoAdWillClose:(id<ATFBRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"FacebookRewardedVideo::rewardedVideoAdWillClose:" type:ATLogTypeExternal];
}

- (void)rewardedVideoAd:(id<ATFBRewardedVideoAd>)rewardedVideoAd didFailWithError:(NSError *)error {
    [ATLogger logError:[NSString stringWithFormat:@"FacebookRewardedVideo::rewardedVideoAd:didFailWithError: %@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (void)rewardedVideoAdVideoComplete:(id<ATFBRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:[NSString stringWithFormat:@"FacebookRewardedVideo::rewardedVideoAdVideoComplete:"] type:ATLogTypeExternal];
    [self trackVideoEnd];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
    if (self.userID == nil) {
        [ATLogger logMessage:[NSString stringWithFormat:@"FacebookRewardedVideo::rewardedVideoAdServerRewardDidSucceed:"] type:ATLogTypeExternal];
        _rewarded = YES;
        self.rewardGranted = YES;
        if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){
            [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
        }
    }
}

- (void)rewardedVideoAdWillLogImpression:(id<ATFBRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:[NSString stringWithFormat:@"FacebookRewardedVideo::rewardedVideoAdWillLogImpression:"] type:ATLogTypeExternal];
    [self trackShow];
    [self trackVideoStart];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
}

- (void)rewardedVideoAdServerRewardDidSucceed:(id<ATFBRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:[NSString stringWithFormat:@"FacebookRewardedVideo::rewardedVideoAdServerRewardDidSucceed:"] type:ATLogTypeExternal];
    _rewarded = YES;
    self.rewardGranted = YES;
    if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){
        [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
}

- (void)rewardedVideoAdServerRewardDidFail:(id<ATFBRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logError:[NSString stringWithFormat:@"FacebookRewardedVideo::rewardedVideoAdServerRewardDidFail:"] type:ATLogTypeExternal];
    _rewarded = NO;
    self.rewardGranted = NO;
}

@end
