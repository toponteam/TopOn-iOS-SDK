//
//  ATAppnextRewardedVideoCustomEvent.m
//  AnyThinkAppnextRewardedVideoAdapter
//
//  Created by Martin Lau on 2018/10/17.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAppnextRewardedVideoCustomEvent.h"
#import "Utilities.h"
#import "ATRewardedVideoManager.h"

@interface ATAppnextRewardedVideoCustomEvent()
@property(nonatomic, readonly) BOOL rewarded;
@end
@implementation ATAppnextRewardedVideoCustomEvent
- (void) adLoaded:(id<ATAppnextAd>)ad {
    [ATLogger logMessage:@"AppnextRewardedVideo::adLoaded:" type:ATLogTypeExternal];
    [self handleAssets:@{kRewardedVideoAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kRewardedVideoAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:ad}];
}

- (void) adOpened:(id<ATAppnextAd>)ad {
    [ATLogger logMessage:@"AppnextRewardedVideo::adOpened:" type:ATLogTypeExternal];
    [self trackShow];
    [self trackVideoStart];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void) adClosed:(id<ATAppnextAd>)ad {
    [ATLogger logMessage:@"AppnextRewardedVideo::adClosed:" type:ATLogTypeExternal];
    [self handleClose];
    [self saveVideoCloseEventRewarded:_rewarded];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
        [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:[self delegateExtra]];
    }
}

- (void) adClicked:(id<ATAppnextAd>)ad {
    [ATLogger logMessage:@"AppnextRewardedVideo::adClicked:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void) adUserWillLeaveApplication:(id<ATAppnextAd>)ad {
    [ATLogger logMessage:@"AppnextRewardedVideo::adUserWillLeaveApplication:" type:ATLogTypeExternal];
}

- (void) adError:(id<ATAppnextAd>)ad error:(NSString *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"AppnextRewardedVideo::adError:error:%@", error] type:ATLogTypeExternal];
    NSError *errorObj = [NSError errorWithDomain:@"com.anythink.AppNextRewardedVideoLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load rewarded video ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"%@", error]}];
    [self handleLoadingFailure:errorObj];
}

- (void) videoEnded:(id<ATAppnextAd>)ad {
    [ATLogger logMessage:@"AppnextRewardedVideo::videoEnded:" type:ATLogTypeExternal];
    _rewarded = YES;
    self.rewardGranted = YES;
    [self trackVideoEnd];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
    
    if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){
        [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"placement_id"];
    return extra;
}
@end
