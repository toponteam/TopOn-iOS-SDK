//
//  ATMaioRewardedVideoCustomEvent.m
//  AnyThinkMaioRewardedVideoAdapter
//
//  Created by Martin Lau on 2019/4/16.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATMaioRewardedVideoCustomEvent.h"
#import "ATMaioRewardedVideoAdapter.h"
#import "Utilities.h"
#import "ATRewardedVideoManager.h"


@implementation ATMaioRewardedVideoCustomEvent
- (void)maioDidInitialize {
    [ATLogger logMessage:@"MaioRewardedVideo::maioDidInitialize" type:ATLogTypeExternal];
}

- (void)maioDidChangeCanShow:(NSString *)zoneId newValue:(BOOL)newValue {
    [ATLogger logMessage:[NSString stringWithFormat:@"MaioRewardedVideo::maioDidChangeCanShow:%@ newValue:%@", zoneId, newValue ? @"yes" : @"no"] type:ATLogTypeExternal];
    if ([zoneId isEqualToString:self.unitID] && newValue) {
        [self trackRewardedVideoAdLoaded:self.unitID != nil ? self.unitID : @"" adExtra:nil];
    }
}

- (void)maioWillStartAd:(NSString *)zoneId {
    [ATLogger logMessage:[NSString stringWithFormat:@"MaioRewardedVideo::maioWillStartAd:%@", zoneId] type:ATLogTypeExternal];
    if ([zoneId isEqualToString:self.unitID]) {
        [self trackRewardedVideoAdShow];
        [self trackRewardedVideoAdVideoStart];
    }
}
- (void)maioDidFinishAd:(NSString *)zoneId playtime:(NSInteger)playtime skipped:(BOOL)skipped rewardParam:(NSString *)rewardParam {
    [ATLogger logMessage:[NSString stringWithFormat:@"MaioRewardedVideo::maioDidFinishAd:%@ playtime:%ld skipped:%@ rewardParam:%@", zoneId, playtime, skipped ? @"yes" : @"no", rewardParam] type:ATLogTypeExternal];
    if ([zoneId isEqualToString:self.unitID]) {
        self.rewardGranted = !skipped;
        if (!skipped) {
            [self trackRewardedVideoAdRewarded];
        }
        [self trackRewardedVideoAdVideoEnd];
    }
}

- (void)maioDidClickAd:(NSString *)zoneId {
    [ATLogger logMessage:[NSString stringWithFormat:@"MaioRewardedVideo::maioDidClickAd:%@", zoneId] type:ATLogTypeExternal];
    if ([zoneId isEqualToString:self.unitID]) {
        [self trackRewardedVideoAdClick];
    }
}

- (void)maioDidCloseAd:(NSString *)zoneId {
    [ATLogger logMessage:[NSString stringWithFormat:@"MaioRewardedVideo::maioDidCloseAd:%@", zoneId] type:ATLogTypeExternal];
    if ([zoneId isEqualToString:self.unitID]) {
        [NSClassFromString(@"Maio") removeDelegateObject:self];
        [self trackRewardedVideoAdCloseRewarded:self.rewardGranted];
    }
}

- (void)maioDidFail:(NSString *)zoneId reason:(NSInteger)reason {
    [ATLogger logMessage:[NSString stringWithFormat:@"MaioRewardedVideo::maioDidFail:%@ reason:%ld", zoneId, reason] type:ATLogTypeExternal];
    if ([zoneId isEqualToString:self.unitID]) {
        [self trackRewardedVideoAdLoadFailed:[NSError errorWithDomain:@"com.anythink.MaioRewardedVideoLoading" code:reason userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load rewarded video for Maio", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Maio rewarded video load has failed with reason:%ld", reason]}]];
        [NSClassFromString(@"Maio") removeDelegateObject:self];
    }
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"zone_id"];
}


//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"zone_id"];
//    return extra;
//}
@end
