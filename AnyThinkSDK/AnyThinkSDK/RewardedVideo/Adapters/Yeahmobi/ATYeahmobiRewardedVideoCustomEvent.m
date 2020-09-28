//
//  ATYeahmobiRewardedVideoCustomEvent.m
//  AnyThinkYeahmobiRewardedVideoAdapter
//
//  Created by Martin Lau on 2018/10/17.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATYeahmobiRewardedVideoCustomEvent.h"
#import "Utilities.h"
#import "ATRewardedVideoManager.h"

@interface ATYeahmobiRewardedVideoCustomEvent()
@property(nonatomic, readonly) BOOL rewarded;
@end
@implementation ATYeahmobiRewardedVideoCustomEvent
- (void)CTRewardVideoLoadSuccess {
    [ATLogger logMessage:@"YeahmobiRewardedVideo::CTRewardVideoLoadSuccess" type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoaded:[self.unitID length] > 0 ? self.unitID : @"" adExtra:nil];
}

- (void)CTRewardVideoDidStartPlaying {
    [ATLogger logMessage:@"YeahmobiRewardedVideo::CTRewardVideoDidStartPlaying" type:ATLogTypeExternal];
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

- (void)CTRewardVideoDidFinishPlaying {
    [ATLogger logMessage:@"YeahmobiRewardedVideo::CTRewardVideoDidFinishPlaying" type:ATLogTypeExternal];
    [self trackRewardedVideoAdVideoEnd];
}

- (void)CTRewardVideoDidClickRewardAd {
    [ATLogger logMessage:@"YeahmobiRewardedVideo::CTRewardVideoDidClickRewardAd" type:ATLogTypeExternal];
    [self trackRewardedVideoAdClick];
}

- (void)CTRewardVideoWillLeaveApplication {
    [ATLogger logMessage:@"YeahmobiRewardedVideo::CTRewardVideoWillLeaveApplication" type:ATLogTypeExternal];
}

- (void)CTRewardVideoJumpfailed {
    [ATLogger logMessage:@"YeahmobiRewardedVideo::CTRewardVideoJumpfailed" type:ATLogTypeExternal];
}

- (void)CTRewardVideoLoadingFailed:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"YeahmobiRewardedVideo::CTRewardVideoLoadingFailed:%@", error] type:ATLogTypeExternal];
}

- (void)CTRewardVideoClosed {
    [ATLogger logMessage:@"YeahmobiRewardedVideo::CTRewardVideoClosed" type:ATLogTypeExternal];
    [self trackRewardedVideoAdCloseRewarded:_rewarded];
}

- (void)CTRewardVideoAdRewardedName:(NSString *)rewardName rewardAmount:(NSString *)rewardAmount customParams:(NSString*) customParams {
    [ATLogger logMessage:[NSString stringWithFormat:@"YeahmobiRewardedVideo::CTRewardVideoAdRewardedName:%@ rewardAmount:%@ customParams:%@", rewardName, rewardAmount, customParams] type:ATLogTypeExternal];
    _rewarded = YES;
    [self trackRewardedVideoAdRewarded];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"slot_id"];
//    return extra;
//}
@end
