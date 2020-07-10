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

NSString *CacheErrorDesc_ATCHBRewarded(NSUInteger code) {
    return @{
        @0:@"CHBCacheErrorCodeInternal",
        @1:@"CHBCacheErrorCodeInternetUnavailable",
        @5:@"CHBCacheErrorCodeNetworkFailure",
        @6:@"CHBCacheErrorCodeNoAdFound",
        @7:@"CHBCacheErrorCodeSessionNotStarted",
        @16:@"CHBCacheErrorCodeAssetDownloadFailure",
        @35:@"CHBCacheErrorCodePublisherDisabled"
    }[@(code)];
}

NSString *ShowErrorDesc_ATCHBRewarded(NSUInteger code) {
    return @{
        @0:@"CHBShowErrorCodeInternal",
        @7:@"CHBShowErrorCodeSessionNotStarted",
        @8:@"CHBShowErrorCodeAdAlreadyVisible",
        @25:@"CHBShowErrorCodeInternetUnavailable",
        @33:@"CHBShowErrorCodePresentationFailure",
        @34:@"CHBShowErrorCodeNoCachedAd"
    }[@(code)];
}

NSString *ClickErrorDesc_ATCHBRewarded(NSUInteger code) {
    return @{
        @0:@"CHBClickErrorCodeUriInvalid",
        @1:@"CHBClickErrorCodeUriUnrecognized",
        @2:@"CHBClickErrorCodeConfirmationGateFailure",
        @3:@"CHBClickErrorCodeInternal"
    }[@(code)];
}
@implementation ATChartboostRewardedVideoCustomEvent
- (void)didCacheAd:(id)event error:(id<ATCHBError>)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"ChartboostRewardedVideo::didCacheAd:error:%@", error != nil ? CacheErrorDesc_ATCHBRewarded(error.code) : @""] type:ATLogTypeExternal];
    if (error == nil) {
        [self handleAssets:@{kRewardedVideoAssetsUnitIDKey:self.unitID, kAdAssetsCustomObjectKey:_rewardedVideoAd, kRewardedVideoAssetsCustomEventKey:self}];
    } else {
        [self handleLoadingFailure:[NSError errorWithDomain:@"com.anythink.ChartboostRVLoading" code:error.code userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load rewarded video", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Chartboost has failed to cache rv with code:%@", CacheErrorDesc_ATCHBRewarded(error.code)]}]];
    }
}

- (void)willShowAd:(id)event { [ATLogger logMessage:@"ChartboostRewardedVideo::willShowAd:" type:ATLogTypeExternal]; }

- (void)didShowAd:(id)event error:(id<ATCHBError>)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"ChartboostRewardedVideo::didShowAd:error:%@", error != nil ? ShowErrorDesc_ATCHBRewarded(error.code) : @""] type:ATLogTypeExternal];
    [self trackShow];
    [self trackVideoStart];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) { [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]]; }
}

- (BOOL)shouldConfirmClick:(id)event confirmationHandler:(void(^)(BOOL))confirmationHandler {
    [ATLogger logMessage:@"ChartboostRewardedVideo::shouldConfirmClick:confirmationHandler:" type:ATLogTypeExternal];
    return NO;
}

- (void)didClickAd:(id)event error:(id<ATCHBError>)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"ChartboostRewardedVideo::didClickAd:error:%@", error != nil ? ClickErrorDesc_ATCHBRewarded(error.code) : @""] type:ATLogTypeExternal];
    if (error == nil) {
        [self trackClick];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) { [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]]; }
    }
}

- (void)didFinishHandlingClick:(id)event error:(id<ATCHBError>)error { [ATLogger logMessage:[NSString stringWithFormat:@"ChartboostRewardedVideo::didFinishHandlingClick:error:%@", error != nil ? ClickErrorDesc_ATCHBRewarded(error.code) : @""] type:ATLogTypeExternal]; }

- (void)didDismissAd:(id)event {
    [ATLogger logMessage:@"ChartboostRewardedVideo::didDismissAd:" type:ATLogTypeExternal];
    [self handleClose];
    [self saveVideoCloseEventRewarded:self.rewardGranted];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) { [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:[self delegateExtra]]; }
}

- (void)didEarnReward:(id)event {
    [ATLogger logMessage:@"ChartboostRewardedVideo::didEarnReward:" type:ATLogTypeExternal];
    self.rewardGranted = YES;
    if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]) { [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]]; }
    
    [self trackVideoEnd];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) { [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]]; }
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"location"];
    return extra;
}
@end
