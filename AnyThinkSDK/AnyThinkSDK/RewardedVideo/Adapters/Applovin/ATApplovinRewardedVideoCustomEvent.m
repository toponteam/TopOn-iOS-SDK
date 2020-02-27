//
//  ATApplovinRewardedVideoCustomEvent.m
//  AnyThinkApplovinRewardedVideoAdapter
//
//  Created by Martin Lau on 09/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATApplovinRewardedVideoCustomEvent.h"
#import "Utilities.h"
#import <objc/runtime.h>
#import "ATRewardedVideoManager.h"
@interface ATApplovinRewardedVideoCustomEvent()
@property(nonatomic) BOOL rewarded;
@end
@implementation ATApplovinRewardedVideoCustomEvent
#pragma mark - loading delegates
- (void)adService:(id<ATALAdService>)adService didLoadAd:(id<ATALAd>)ad {
    [ATLogger logMessage:@"adService:didLoadAd:" type:ATLogTypeExternal];
    [self handleAssets:@{kRewardedVideoAssetsUnitIDKey:self.unitID, kAdAssetsCustomObjectKey:self, kRewardedVideoAssetsCustomEventKey:self}];
}

- (void)adService:(id<ATALAdService>)adService didFailToLoadAdWithError:(int)code {
    [ATLogger logError:[NSString stringWithFormat:@"Applovin failed to load rewarded video, error code:%d", code] type:ATLogTypeExternal];
    [self handleLoadingFailure:[NSError errorWithDomain:@"com.anythink.ApplovinRewardedVideo" code:code userInfo:@{NSLocalizedDescriptionKey:@"ATSDK has failed to load rewarded video.", NSLocalizedFailureReasonErrorKey:@"Applovin has failed to load rewarded video."}]];
}

#pragma mark - showing delegates
- (void)videoPlaybackBeganInAd:(id<ATALAd>)ad {
    [ATLogger logMessage:@"videoPlaybackBeganInAd:" type:ATLogTypeExternal];
    if (self.ad != nil && self.rewardedVideo != nil) {
        [self trackShow];
        [self trackVideoStart];
    }
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
}

- (void)videoPlaybackEndedInAd:(id<ATALAd>)ad atPlaybackPercent:(NSNumber *)percentPlayed fullyWatched:(BOOL)wasFullyWatched {
    _rewarded = wasFullyWatched;
    if (self.ad != nil && self.rewardedVideo != nil) {
        self.rewardGranted = YES;
        [self handleClose];
        [self trackVideoEnd];
    }
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
    if(self.rewardGranted){
        if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){
            [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
        }
    }
}

- (void)ad:(id<ATALAd>)ad wasDisplayedIn:(UIView *)view {
    [ATLogger logMessage:@"Applovin: ad wasDisplayedInView" type:ATLogTypeExternal];
}

- (void)ad:(id<ATALAd>)ad wasHiddenIn:(UIView *)view {
    [ATLogger logMessage:@"Applovin: ad wasHiddenIn" type:ATLogTypeExternal];
    if (self.ad != nil && self.rewardedVideo != nil) {
        [self saveVideoCloseEventRewarded:_rewarded];
    }
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
        [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
    self.incentivizedInterstitialAd = nil;
    
}

- (void)ad:(id<ATALAd>)ad wasClickedIn:(UIView *)view {
    [ATLogger logMessage:@"Applovin: ad wasClickedIn" type:ATLogTypeExternal];
    if (self.ad != nil && self.rewardedVideo != nil) {
        [self trackClick];
    }
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
}

- (void)rewardValidationRequestForAd:(id<ATALAd>)ad didSucceedWithResponse:(NSDictionary *)response {
    [ATLogger logMessage:[NSString stringWithFormat:@"Applovin: rewardValidationRequestForAd didSucceedWithResponse:%@", response] type:ATLogTypeExternal];
}

- (void)rewardValidationRequestForAd:(id<ATALAd>)ad didExceedQuotaWithResponse:(NSDictionary *)response {
    [ATLogger logMessage:[NSString stringWithFormat:@"Applovin: rewardValidationRequestForAd didExceedQuotaWithResponse:%@", response] type:ATLogTypeExternal];
}

- (void)rewardValidationRequestForAd:(id<ATALAd>)ad wasRejectedWithResponse:(NSDictionary *)response {
    [ATLogger logMessage:[NSString stringWithFormat:@"Applovin: rewardValidationRequestForAd wasRejectedWithResponse:%@", response] type:ATLogTypeExternal];
}

- (void)rewardValidationRequestForAd:(id<ATALAd>)ad didFailWithError:(NSInteger)responseCode {
    [ATLogger logMessage:[NSString stringWithFormat:@"Applovin: rewardValidationRequestForAd didFailWithError:%ld", responseCode] type:ATLogTypeExternal];
}

- (void)userDeclinedToViewAd:(id<ATALAd>)ad {
    [ATLogger logMessage:@"Applovin: userDeclinedToViewAd" type:ATLogTypeExternal];
    NSError *error = [NSError errorWithDomain:@"AppLovin rewarded video declined by user" code:10000 userInfo:@{NSLocalizedDescriptionKey:@"User declined to view ad", NSLocalizedFailureReasonErrorKey:@"User declined to view ad"}];
    if (self.ad != nil && self.rewardedVideo != nil) {
        [self saveVideoPlayEventWithError:error];
    }

    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForPlacementID:error:extra:)]) { [self.delegate rewardedVideoDidFailToPlayForPlacementID:self.rewardedVideo.placementModel.placementID error:error extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}]; }
}
@end
