//
//  ATFacebookRewardedVideoCustomEvent.m
//  AnyThinkFacebookRewardedVideoAdapter
//
//  Created by Martin Lau on 10/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATFacebookRewardedVideoCustomEvent.h"
#import "Utilities.h"
#import <objc/runtime.h>
#import "ATRewardedVideoManager.h"

@interface ATFacebookRewardedVideoCustomEvent()
@end

@implementation ATFacebookRewardedVideoCustomEvent
- (void)rewardedVideoAdDidClick:(id<ATFBRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"FacebookRewardedVideo::rewardedVideoAdDidClick:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdClick];
}

- (void)rewardedVideoAdDidLoad:(id<ATFBRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"FacebookRewardedVideo::rewardedVideoAdDidLoad:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoaded:rewardedVideoAd adExtra:nil];
}

- (void)rewardedVideoAdDidClose:(id<ATFBRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"FacebookRewardedVideo::rewardedVideoAdDidClose:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdCloseRewarded:self.rewardGranted];
}

- (void)rewardedVideoAdWillClose:(id<ATFBRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"FacebookRewardedVideo::rewardedVideoAdWillClose:" type:ATLogTypeExternal];
}

- (void)rewardedVideoAd:(id<ATFBRewardedVideoAd>)rewardedVideoAd didFailWithError:(NSError *)error {
    [ATLogger logError:[NSString stringWithFormat:@"FacebookRewardedVideo::rewardedVideoAd:didFailWithError: %@", error] type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoadFailed:error];
}

- (void)rewardedVideoAdVideoComplete:(id<ATFBRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:[NSString stringWithFormat:@"FacebookRewardedVideo::rewardedVideoAdVideoComplete:"] type:ATLogTypeExternal];
    [self trackRewardedVideoAdVideoEnd];
    
    [self trackRewardedVideoAdRewarded];
}

- (void)rewardedVideoAdWillLogImpression:(id<ATFBRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:[NSString stringWithFormat:@"FacebookRewardedVideo::rewardedVideoAdWillLogImpression:"] type:ATLogTypeExternal];
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

- (void)rewardedVideoAdServerRewardDidSucceed:(id<ATFBRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:[NSString stringWithFormat:@"FacebookRewardedVideo::rewardedVideoAdServerRewardDidSucceed:"] type:ATLogTypeExternal];
}

- (void)rewardedVideoAdServerRewardDidFail:(id<ATFBRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logError:[NSString stringWithFormat:@"FacebookRewardedVideo::rewardedVideoAdServerRewardDidFail:"] type:ATLogTypeExternal];
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
