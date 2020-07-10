//
//  ATKSRewardedVideoCustomEvent.m
//  AnyThinkSDK
//
//  Created by Topon on 2019/9/10.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATKSRewardedVideoCustomEvent.h"
#import "Utilities.h"
#import "ATRewardedVideoManager.h"

@interface ATKSRewardedVideoCustomEvent()
@property(nonatomic, readonly) BOOL rewarded;
@property(nonatomic, readonly) BOOL loaded;
@end
@implementation ATKSRewardedVideoCustomEvent
- (void)rewardedVideoAdDidLoad:(id<ATKSRewardedVideoAd>)rewardedVideoAd{
    [ATLogger logMessage:@"KSRewardedVideo::KS_rewardVideoAdDidLoad:" type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

- (void)rewardedVideoAd:(id<ATKSRewardedVideoAd>)rewardedVideoAd didFailWithError:(NSError *_Nullable)error{
    [ATLogger logMessage:@"KSRewardedVideo::rewardedVideoAd:didFailWithError:" type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (void)rewardedVideoAdVideoDidLoad:(id<ATKSRewardedVideoAd>)rewardedVideoAd{
    [ATLogger logMessage:@"KSRewardedVideo::rewardedVideoAdVideoDidLoad:" type:ATLogTypeExternal];
    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithDictionary:@{kRewardedVideoAssetsUnitIDKey:self.unitID, kAdAssetsCustomObjectKey:rewardedVideoAd, kRewardedVideoAssetsCustomEventKey:self}];

    [self handleAssets:assets];
}

- (void)rewardedVideoAdWillVisible:(id<ATKSRewardedVideoAd>)rewardedVideoAd{
    [ATLogger logMessage:@"KSRewardedVideo::KS_rewardVideoAdWillVisible:" type:ATLogTypeExternal];
}

- (void)rewardedVideoAdDidVisible:(id<ATKSRewardedVideoAd>)rewardedVideoAd{
    
}

- (void)rewardedVideoAdWillClose:(id<ATKSRewardedVideoAd>)rewardedVideoAd{
    
}

- (void)rewardedVideoAdDidClose:(id<ATKSRewardedVideoAd>)rewardedVideoAd{
    [ATLogger logMessage:@"KSRewardedVideo::KS_rewardVideoAdDidClose:" type:ATLogTypeExternal];
    [self handleClose];
    [self saveVideoCloseEventRewarded:_rewarded];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
        [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:[self delegateExtra]];
    }
}

- (void)rewardedVideoAdDidClick:(id<ATKSRewardedVideoAd>)rewardedVideoAd{
    [ATLogger logMessage:@"KSRewardedVideo::KS_rewardVideoAdDidClicked:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)rewardedVideoAdDidPlayFinish:(id<ATKSRewardedVideoAd>)rewardedVideoAd didFailWithError:(NSError *_Nullable)error{
    [ATLogger logMessage:@"KSRewardedVideo::KS_rewardVideoAdDidPlayFinish:didFailWithError:" type:ATLogTypeExternal];
    if (error == nil) {
        [self trackVideoEnd];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) {
            [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
        }
    } else {
        [self saveVideoPlayEventWithError:error];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForPlacementID:error:extra:)]) { [self.delegate rewardedVideoDidFailToPlayForPlacementID:self.rewardedVideo.placementModel.placementID error:error extra:[self delegateExtra]]; }
    }
}

- (void)rewardedVideoAdDidClickSkip:(id<ATKSRewardedVideoAd>)rewardedVideoAd{
    _rewarded = NO;
    [self saveVideoCloseEventRewarded:_rewarded];
}

- (void)rewardedVideoAdStartPlay:(id<ATKSRewardedVideoAd>)rewardedVideoAd{
    [ATLogger logMessage:@"KSRewardedVideo::KS_rewardVideoAdStartL]Play:" type:ATLogTypeExternal];
    [self trackShow];
    [self trackVideoStart];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)rewardedVideoAd:(id<ATKSRewardedVideoAd>)rewardedVideoAd hasReward:(BOOL)hasReward{
    if (hasReward) {
        self.rewardGranted = YES;
        _rewarded = YES;
        if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){
            [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
        }
    }
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"position_id"];
    return extra;
}
@end
