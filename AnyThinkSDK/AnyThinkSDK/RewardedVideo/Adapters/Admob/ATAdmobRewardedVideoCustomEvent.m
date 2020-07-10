//
//  ATAdmobRewardedVideoCustomEvent.m
//  AnyThinkAdmobRewardedVideoAdapter
//
//  Created by Martin Lau on 07/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdmobRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "ATLogger.h"
#import <objc/runtime.h>

@interface ATAdmobRewardedVideoCustomEvent()
@property(nonatomic) BOOL rewarded;
@property(nonatomic) BOOL videoEnd;
@end
@implementation ATAdmobRewardedVideoCustomEvent
- (void)rewardedAd:(nonnull id<ATGADRewardedAd>)rewardedAd userDidEarnReward:(id)reward {
    [ATLogger logMessage:@"AdmobRewardedVideo::rewardedAd:userDidEarnReward:" type:ATLogTypeExternal];
    self.rewardGranted = YES;
    if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){
        [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)rewardedAd:(nonnull id<ATGADRewardedAd>)rewardedAd didFailToPresentWithError:(nonnull NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"AdmobRewardedVideo::rewardedAd:didFailToPresentWithError:%@(code:%@)", error, [ATAdmobRewardedVideoCustomEvent errorMessageWithError:error]] type:ATLogTypeExternal];
    [self saveVideoPlayEventWithError:error];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForPlacementID:error:extra:)]) { [self.delegate rewardedVideoDidFailToPlayForPlacementID:self.rewardedVideo.placementModel.placementID error:error extra:[self delegateExtra]]; }
}

- (void)rewardedAdDidPresent:(nonnull id<ATGADRewardedAd>)rewardedAd {
    [ATLogger logMessage:@"AdmobRewardedVideo::rewardedAdDidPresent:" type:ATLogTypeExternal];
    [self trackShow];
    [self trackVideoStart];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)rewardedAdDidDismiss:(nonnull id<ATGADRewardedAd>)rewardedAd {
    [ATLogger logMessage:@"AdmobRewardedVideo::rewardedAdDidDismiss:" type:ATLogTypeExternal];
    [self handleClose];
    if (self.rewardGranted) {
        [self trackVideoEnd];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) {
            [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
        }
    }
    [self saveVideoCloseEventRewarded:self.rewardGranted];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
        [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:[self delegateExtra]];
    }
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"unit_id"];
    return extra;
}

+(NSString*) errorMessageWithError:(NSError*)error {
    NSDictionary *errorMsgMap = @{@0:@"kGADErrorInvalidRequest",
                                  @1:@"kGADErrorNoFill",
                                  @2:@"kGADErrorNetworkError",
                                  @3:@"kGADErrorServerError",
                                  @5:@"kGADErrorTimeout",
                                  @7:@"kGADErrorMediationDataError",
                                  @8:@"kGADErrorMediationAdapterError",
                                  @10:@"kGADErrorMediationInvalidAdSize",
                                  @11:@"kGADErrorInternalError",
                                  @12:@"kGADErrorInvalidArgument",
                                  @13:@"kGADErrorReceivedInvalidResponse",
                                  @9:@"kGADErrorMediationNoFill",
                                  @19:@"kGADErrorAdAlreadyUsed",
                                  @20:@"kGADErrorApplicationIdentifierMissing"
    };
    return errorMsgMap[@(error.code)] != nil ? errorMsgMap[@(error.code)] : @"Undefined Error";
}
@end
