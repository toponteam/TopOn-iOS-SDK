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
    [ATLogger logMessage:@"KSRewardedVideo::rewardedVideoAdDidLoad:" type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

- (void)rewardedVideoAd:(id<ATKSRewardedVideoAd>)rewardedVideoAd didFailWithError:(NSError *_Nullable)error{
    [ATLogger logMessage:[NSString stringWithFormat:@"KSRewardedVideo::rewardedVideoAd:didFailWithError:%@",error] type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoadFailed:error];
}

- (void)rewardedVideoAdVideoDidLoad:(id<ATKSRewardedVideoAd>)rewardedVideoAd{
    [ATLogger logMessage:@"KSRewardedVideo::rewardedVideoAdVideoDidLoad:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoaded:rewardedVideoAd adExtra:nil];
}

- (void)rewardedVideoAdWillVisible:(id<ATKSRewardedVideoAd>)rewardedVideoAd{
    [ATLogger logMessage:@"KSRewardedVideo::rewardedVideoAdWillVisible:" type:ATLogTypeExternal];
}

- (void)rewardedVideoAdDidVisible:(id<ATKSRewardedVideoAd>)rewardedVideoAd{
    [ATLogger logMessage:@"KSRewardedVideo::rewardedVideoAdDidVisible:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdShow];
}

- (void)rewardedVideoAdWillClose:(id<ATKSRewardedVideoAd>)rewardedVideoAd{
    
}

- (void)rewardedVideoAdDidClose:(id<ATKSRewardedVideoAd>)rewardedVideoAd{
    [ATLogger logMessage:@"KSRewardedVideo::rewardedVideoAdDidClose:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdCloseRewarded:_rewarded];
}

- (void)rewardedVideoAdDidClick:(id<ATKSRewardedVideoAd>)rewardedVideoAd{
    [ATLogger logMessage:@"KSRewardedVideo::rewardedVideoAdDidClick:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdClick];
}

- (void)rewardedVideoAdDidPlayFinish:(id<ATKSRewardedVideoAd>)rewardedVideoAd didFailWithError:(NSError *_Nullable)error{
    [ATLogger logMessage:[NSString stringWithFormat:@"KSRewardedVideo::rewardedVideoAdDidPlayFinish:didFailWithError:%@",error] type:ATLogTypeExternal];
    if (error == nil) {
        [self trackRewardedVideoAdVideoEnd];
    } else {
        [self trackRewardedVideoAdPlayEventWithError:error];
    }
}

- (void)rewardedVideoAdDidClickSkip:(id<ATKSRewardedVideoAd>)rewardedVideoAd{
    _rewarded = NO;
}

- (void)rewardedVideoAdStartPlay:(id<ATKSRewardedVideoAd>)rewardedVideoAd{
    [ATLogger logMessage:@"KSRewardedVideo::rewardedVideoAdStartPlay:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdVideoStart];
}

- (void)rewardedVideoAd:(id<ATKSRewardedVideoAd>)rewardedVideoAd hasReward:(BOOL)hasReward{
    if (hasReward) {
        _rewarded = YES;
        [self trackRewardedVideoAdRewarded];
    }
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"position_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"position_id"];
//    return extra;
//}
@end
