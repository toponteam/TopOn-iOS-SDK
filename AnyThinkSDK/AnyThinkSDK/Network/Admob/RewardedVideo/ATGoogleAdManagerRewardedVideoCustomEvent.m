//
//  ATGoogleAdManagerRewardedVideoCustomEvent.m
//  AnyThinkAdmobRewardedVideoAdapter
//
//  Created by stephen on 7/27/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATGoogleAdManagerRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "ATLogger.h"
#import <objc/runtime.h>

@interface ATGoogleAdManagerRewardedVideoCustomEvent()
@property(nonatomic) BOOL rewarded;
@property(nonatomic) BOOL videoEnd;
@end
@implementation ATGoogleAdManagerRewardedVideoCustomEvent
- (void)rewardedAd:(nonnull id<ATDFPRewardedAd>)rewardedAd userDidEarnReward:(id)reward {
    [ATLogger logMessage:@"GoogleAdManagerRewardedVideo::rewardedAd:userDidEarnReward:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdRewarded];
}

- (void)rewardedAd:(nonnull id<ATDFPRewardedAd>)rewardedAd didFailToPresentWithError:(nonnull NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"GoogleAdManagerRewardedVideo::rewardedAd:didFailToPresentWithError:%@", error] type:ATLogTypeExternal];
    [self trackRewardedVideoAdPlayEventWithError:error];
}

- (void)rewardedAdDidPresent:(nonnull id<ATDFPRewardedAd>)rewardedAd {
    [ATLogger logMessage:@"GoogleAdManagerRewardedVideo::rewardedAdDidPresent:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
   
}

- (void)rewardedAdDidDismiss:(nonnull id<ATDFPRewardedAd>)rewardedAd {
    [ATLogger logMessage:@"GoogleAdManagerRewardedVideo::rewardedAdDidDismiss:" type:ATLogTypeExternal];
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
