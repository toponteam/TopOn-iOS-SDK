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
        [self trackRewardedVideoAdLoaded:_rewardedVideoAd adExtra:nil];
    } else {
        [self trackRewardedVideoAdLoadFailed:[NSError errorWithDomain:@"com.anythink.ChartboostRVLoading" code:error.code userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load rewarded video", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Chartboost has failed to cache rv with code:%@", CacheErrorDesc_ATCHBRewarded(error.code)]}]];
    }
}

- (void)willShowAd:(id)event { [ATLogger logMessage:@"ChartboostRewardedVideo::willShowAd:" type:ATLogTypeExternal]; }

- (void)didShowAd:(id)event error:(id<ATCHBError>)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"ChartboostRewardedVideo::didShowAd:error:%@", error != nil ? ShowErrorDesc_ATCHBRewarded(error.code) : @""] type:ATLogTypeExternal];
    if (error == nil) {
        [self trackRewardedVideoAdShow];
        [self trackRewardedVideoAdVideoStart];
    }else {
        [self trackRewardedVideoAdPlayEventWithError:[NSError errorWithDomain:@"com.anythink.ChartboostRewardedVideoShow" code:error.code userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to show RewardedVideo", NSLocalizedFailureReasonErrorKey:@"Chartboost SDK has failed to show RewardedVideo"}]];
    }
}

- (BOOL)shouldConfirmClick:(id)event confirmationHandler:(void(^)(BOOL))confirmationHandler {
    [ATLogger logMessage:@"ChartboostRewardedVideo::shouldConfirmClick:confirmationHandler:" type:ATLogTypeExternal];
    return NO;
}

- (void)didClickAd:(id)event error:(id<ATCHBError>)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"ChartboostRewardedVideo::didClickAd:error:%@", error != nil ? ClickErrorDesc_ATCHBRewarded(error.code) : @""] type:ATLogTypeExternal];
    if (error == nil) {
        [self trackRewardedVideoAdClick];
    }
}

- (void)didFinishHandlingClick:(id)event error:(id<ATCHBError>)error { [ATLogger logMessage:[NSString stringWithFormat:@"ChartboostRewardedVideo::didFinishHandlingClick:error:%@", error != nil ? ClickErrorDesc_ATCHBRewarded(error.code) : @""] type:ATLogTypeExternal]; }

- (void)didDismissAd:(id)event {
    [ATLogger logMessage:@"ChartboostRewardedVideo::didDismissAd:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdCloseRewarded:self.rewardGranted];
}

- (void)didEarnReward:(id)event {
    [ATLogger logMessage:@"ChartboostRewardedVideo::didEarnReward:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdRewarded];
    
    [self trackRewardedVideoAdVideoEnd];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"location"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"location"];
//    return extra;
//}
@end
