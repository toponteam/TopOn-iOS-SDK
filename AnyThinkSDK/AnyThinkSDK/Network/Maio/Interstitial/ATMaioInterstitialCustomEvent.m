//
//  ATMaioInterstitialCustomEvent.m
//  AnyThinkMaioInterstitialAdapter
//
//  Created by Martin Lau on 2019/4/16.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATMaioInterstitialCustomEvent.h"
#import "ATMaioInterstitialAdapter.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"

@implementation ATMaioInterstitialCustomEvent
- (void)maioDidInitialize {
    [ATLogger logMessage:@"MaioInterstitial::maioDidInitialize" type:ATLogTypeExternal];
}

- (void)maioDidChangeCanShow:(NSString *)zoneId newValue:(BOOL)newValue {
    [ATLogger logMessage:[NSString stringWithFormat:@"MaioInterstitial::maioDidChangeCanShow:%@ newValue:%@", zoneId, newValue ? @"yes" : @"no"] type:ATLogTypeExternal];
    if ([zoneId isEqualToString:self.unitID] && newValue) {
        [self trackInterstitialAdLoaded:self.unitID adExtra:nil];
    }
}

- (void)maioWillStartAd:(NSString *)zoneId {
    [ATLogger logMessage:[NSString stringWithFormat:@"MaioInterstitial::maioWillStartAd:%@", zoneId] type:ATLogTypeExternal];
    if ([zoneId isEqualToString:self.unitID]) {
        [self trackInterstitialAdShow];
    }
}
- (void)maioDidFinishAd:(NSString *)zoneId playtime:(NSInteger)playtime skipped:(BOOL)skipped rewardParam:(NSString *)rewardParam {
    [ATLogger logMessage:[NSString stringWithFormat:@"MaioInterstitial::maioDidFinishAd:%@ playtime:%ld slkipped:%@ rewardParam:%@", zoneId, playtime, skipped ? @"yes" : @"no", rewardParam] type:ATLogTypeExternal];
}

- (void)maioDidClickAd:(NSString *)zoneId {
    [ATLogger logMessage:[NSString stringWithFormat:@"MaioInterstitial::maioDidClickAd:%@", zoneId] type:ATLogTypeExternal];
    if ([zoneId isEqualToString:self.unitID]) {
        [self trackInterstitialAdClick];
    }
}

- (void)maioDidCloseAd:(NSString *)zoneId {
    [ATLogger logMessage:[NSString stringWithFormat:@"MaioInterstitial::maioDidCloseAd:%@", zoneId] type:ATLogTypeExternal];
    if ([zoneId isEqualToString:self.unitID]) {
        [NSClassFromString(@"Maio") removeDelegateObject:self];
        [self trackInterstitialAdClose];
    }
}

- (void)maioDidFail:(NSString *)zoneId reason:(NSInteger)reason {
    [ATLogger logMessage:[NSString stringWithFormat:@"MaioInterstitial::maioDidFail:%@ reason:%ld", zoneId, reason] type:ATLogTypeExternal];
    if ([zoneId isEqualToString:self.unitID]) {
        [self trackInterstitialAdLoadFailed:[NSError errorWithDomain:@"com.anythink.MaioInterstitialLoading" code:reason userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load interstitial ad for Maio", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Maio interstitial ad load has failed with reason:%ld", reason]}]];
        [NSClassFromString(@"Maio") removeDelegateObject:self];
    }
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"zone_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"zone_id"];
//    return extra;
//}
@end
