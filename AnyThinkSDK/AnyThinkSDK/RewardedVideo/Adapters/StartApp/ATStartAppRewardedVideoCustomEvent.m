//
//  ATStartAppRewardedVideoCustomEvent.m
//  AnyThinkStartAppRewardedVideoAdapter
//
//  Created by Martin Lau on 2020/3/18.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATStartAppRewardedVideoCustomEvent.h"
#import "Utilities.h"
#import "ATRewardedVideoManager.h"

@interface ATStartAppRewardedVideoCustomEvent()
@property(nonatomic, readonly) BOOL closed;
@end
@implementation ATStartAppRewardedVideoCustomEvent
- (void) didLoadAd:(id<ATSTAAbstractAd>)ad {
    [ATLogger logMessage:@"StartAppRewardedVideo::didLoadAd:" type:ATLogTypeExternal];
    [self handleAssets:@{kRewardedVideoAssetsUnitIDKey:self.unitID, kAdAssetsCustomObjectKey:ad, kRewardedVideoAssetsCustomEventKey:self}];
}

- (void) failedLoadAd:(id<ATSTAAbstractAd>)ad withError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"StartAppRewardedVideo::failedLoadAd:withError:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error != nil ? error : [NSError errorWithDomain:@"com.anythink.StartAppRewardedVideoLoading" code:100001 userInfo:@{NSLocalizedDescriptionKey:@"StartApp failed to load ad", NSLocalizedFailureReasonErrorKey:@"StartApp failed to load ad"}]];
}

- (void) didShowAd:(id<ATSTAAbstractAd>)ad {
    [ATLogger logMessage:@"StartAppRewardedVideo::didShowAd:" type:ATLogTypeExternal];
    [self trackShow];
    [self trackVideoStart];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void) failedShowAd:(id<ATSTAAbstractAd>)ad withError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"StartAppRewardedVideo::failedShowAd:withError:%@", error] type:ATLogTypeExternal];
    [self saveVideoPlayEventWithError:error];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForPlacementID:error:extra:)]) { [self.delegate rewardedVideoDidFailToPlayForPlacementID:self.rewardedVideo.placementModel.placementID error:error extra:[self delegateExtra]]; }
}

- (void) didCloseAd:(id<ATSTAAbstractAd>)ad {
    [ATLogger logMessage:@"StartAppRewardedVideo::didCloseAd:" type:ATLogTypeExternal];
    if (!_closed) {
        _closed = YES;
        [self handleClose];
        [self saveVideoCloseEventRewarded:self.rewardGranted];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
            [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:[self delegateExtra]];
        }
    }
}

- (void) didClickAd:(id<ATSTAAbstractAd>)ad {
    [ATLogger logMessage:@"StartAppRewardedVideo::didClickAd:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
    //if the click leads to external browser, the close delegate method will not be called
    if (!_closed) {
        _closed = YES;
        [self handleClose];
        [self saveVideoCloseEventRewarded:self.rewardGranted];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
            [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:[self delegateExtra]];
        }
    }
}

- (void) didCloseInAppStore:(id<ATSTAAbstractAd>)ad {
    [ATLogger logMessage:@"StartAppRewardedVideo::didCloseInAppStore:" type:ATLogTypeExternal];
    if (!_closed) {
        _closed = YES;
        [self handleClose];
        [self saveVideoCloseEventRewarded:self.rewardGranted];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
            [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:[self delegateExtra]];
        }
    }
}

- (void) didCompleteVideo:(id<ATSTAAbstractAd>)ad {
    [ATLogger logMessage:@"StartAppRewardedVideo::didCompleteVideo:" type:ATLogTypeExternal];
    self.rewardGranted = YES;
    [self trackVideoEnd];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
    if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){
        [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}
@end
