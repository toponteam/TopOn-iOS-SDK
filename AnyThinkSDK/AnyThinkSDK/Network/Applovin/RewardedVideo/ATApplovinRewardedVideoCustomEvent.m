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
    [self trackRewardedVideoAdLoaded:self adExtra:nil];
}

- (void)adService:(id<ATALAdService>)adService didFailToLoadAdWithError:(int)code {
    [ATLogger logError:[NSString stringWithFormat:@"Applovin failed to load rewarded video, error code:%d", code] type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoadFailed:[NSError errorWithDomain:@"com.anythink.ApplovinRewardedVideo" code:code userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:@"Applovin has failed to load rewarded video."}]];
}

#pragma mark - showing delegates
- (void)videoPlaybackBeganInAd:(id<ATALAd>)ad {
    [ATLogger logMessage:@"videoPlaybackBeganInAd:" type:ATLogTypeExternal];
    if (self.ad != nil && self.rewardedVideo != nil) {
        [self trackRewardedVideoAdShow];
        [self trackRewardedVideoAdVideoStart];
    }
}

- (void)videoPlaybackEndedInAd:(id<ATALAd>)ad atPlaybackPercent:(NSNumber *)percentPlayed fullyWatched:(BOOL)wasFullyWatched {
    _rewarded = wasFullyWatched;
    if (self.ad != nil && self.rewardedVideo != nil) {
        self.rewardGranted = YES;
//        [self handleClose];
    }
    [self trackRewardedVideoAdVideoEnd];
    if(self.rewardGranted){
        [self trackRewardedVideoAdRewarded];
    }
}

- (void)ad:(id<ATALAd>)ad wasDisplayedIn:(UIView *)view {
    [ATLogger logMessage:@"Applovin: ad wasDisplayedInView" type:ATLogTypeExternal];
}

- (void)ad:(id<ATALAd>)ad wasHiddenIn:(UIView *)view {
    [ATLogger logMessage:@"Applovin: ad wasHiddenIn" type:ATLogTypeExternal];
    if (self.ad != nil && self.rewardedVideo != nil) {
        [self trackRewardedVideoAdCloseRewarded:_rewarded];
    }
    self.incentivizedInterstitialAd = nil;
    
}

- (void)ad:(id<ATALAd>)ad wasClickedIn:(UIView *)view {
    [ATLogger logMessage:@"Applovin: ad wasClickedIn" type:ATLogTypeExternal];
    if (self.ad != nil && self.rewardedVideo != nil) {
        [self trackRewardedVideoAdClick];
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
        [self trackRewardedVideoAdPlayEventWithError:error];
    }
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"zone_id"] != nil ? self.serverInfo[@"zone_id"] : @"";
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"zone_id"] != nil ? self.rewardedVideo.unitGroup.content[@"zone_id"] : @"";
//    return extra;
//}
@end
