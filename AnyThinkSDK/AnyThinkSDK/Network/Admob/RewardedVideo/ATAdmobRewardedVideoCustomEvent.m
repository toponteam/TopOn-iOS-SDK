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
    [self trackRewardedVideoAdRewarded];
}

- (void)rewardedAd:(nonnull id<ATGADRewardedAd>)rewardedAd didFailToPresentWithError:(nonnull NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"AdmobRewardedVideo::rewardedAd:didFailToPresentWithError:%@", error] type:ATLogTypeExternal];
    [self trackRewardedVideoAdPlayEventWithError:error];
}

- (void)rewardedAdDidPresent:(nonnull id<ATGADRewardedAd>)rewardedAd {
    [ATLogger logMessage:@"AdmobRewardedVideo::rewardedAdDidPresent:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
   
}

- (void)rewardedAdDidDismiss:(nonnull id<ATGADRewardedAd>)rewardedAd {
    [ATLogger logMessage:@"AdmobRewardedVideo::rewardedAdDidDismiss:" type:ATLogTypeExternal];
    if (self.rewardGranted) {
        [self trackRewardedVideoAdVideoEnd];
    }
    [self trackRewardedVideoAdCloseRewarded:self.rewardGranted];
    
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"unit_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"unit_id"];
//    return extra;
//}
@end
