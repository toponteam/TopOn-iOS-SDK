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
- (void)oneWaySDKRewardedAdReady {
    [ATLogger logMessage:@"OnewayRewardedVideo::oneWaySDKRewardedAdReady" type:ATLogTypeExternal];
    NSArray<id<ATAd>>* ads = [[ATRewardedVideoManager sharedManager] adsWithPlacementID:((ATPlacementModel*)self.customInfo[kAdapterCustomInfoPlacementModelKey]).placementID];
    __block id<ATAd> ad = nil;
    [ads enumerateObjectsUsingBlock:^(id<ATAd>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.unitID isEqualToString:self.unitID]) {
            ad = obj;
            *stop = YES;
        }
    }];
    if (ad != nil) [self handleAssets:@{kRewardedVideoAssetsUnitIDKey:self.unitID, kAdAssetsCustomObjectKey:(ATRewardedVideo*)ad.customObject, kRewardedVideoAssetsCustomEventKey:self}];
    else [self handleAssets:@{kRewardedVideoAssetsUnitIDKey:self.unitID, kAdAssetsCustomObjectKey:self, kRewardedVideoAssetsCustomEventKey:self}];
}

- (void)oneWaySDKRewardedAdDidShow:(NSString *)tag {
    [ATLogger logMessage:[NSString stringWithFormat:@"OnewayRewardedVideo::oneWaySDKRewardedAdDidShow:%@", tag] type:ATLogTypeExternal];
    [self trackShow];
    [self trackVideoStart];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
}

- (void)oneWaySDKRewardedAdDidClose:(NSString *)tag withState:(NSNumber *)state {
    [ATLogger logMessage:[NSString stringWithFormat:@"OnewayRewardedVideo::oneWaySDKRewardedAdDidClose:%@ withMessage:%@", tag, state] type:ATLogTypeExternal];
    self.rewardGranted = [state integerValue] == 2;
    [self handleClose];
    [self saveVideoCloseEventRewarded:[state integerValue] == 2];
    if ([state integerValue] == 2) {
        [self trackVideoEnd];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) {
            [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
        }
        
        if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){
            [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
        [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
}

- (void)oneWaySDKRewardedAdDidClick:(NSString *)tag {
    [ATLogger logMessage:[NSString stringWithFormat:@"OnewayRewardedVideo::oneWaySDKRewardedAdDidClick:%@", tag] type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
}

- (void)oneWaySDKDidError:(NSInteger)error withMessage:(NSString *)message {
    [ATLogger logMessage:[NSString stringWithFormat:@"OnewayRewardedVideo::oneWaySDKDidError:%ld withMessage:%@", error, message] type:ATLogTypeExternal];
    [self handleLoadingFailure:[NSError errorWithDomain:@"com.anythink.OneWayRewardedVideo" code:error userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load rewarded video", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"%@", message]}]];
}
@end
