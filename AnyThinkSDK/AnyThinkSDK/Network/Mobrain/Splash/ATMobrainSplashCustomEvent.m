//
//  ATMobrainSplashCustomEvent.m
//  AnyThinkMobrainAdapter
//
//  Created by Topon on 2/1/21.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import "ATMobrainSplashCustomEvent.h"
#import "ATMobrainSplashApis.h"
#import "ATLogger.h"
#import "Utilities.h"

@implementation ATMobrainSplashCustomEvent

/**
 This method is called when splash ad material loaded successfully.
 */
- (void)splashAdDidLoad:(id<ATABUSplashAd> _Nonnull)splashAd {
    [ATLogger logMessage:@"ATMobrainSplashCustomEvent::splashAdDidLoad" type:ATLogTypeExternal];
    [self trackSplashAdLoaded:splashAd adExtra:nil];
}

/**
 This method is called when splash ad material failed to load.
 @param error : the reason of error
 */
- (void)splashAd:(id<ATABUSplashAd> _Nonnull)splashAd didFailWithError:(NSError * _Nullable)error {
    [ATLogger logError:@"ATMobrainSplashCustomEvent::didFailWithError" type:ATLogTypeExternal];
    [self trackSplashAdLoadFailed:error];
}

/**
 This method is called when splash ad slot will be showing.
 */
- (void)splashAdWillVisible:(id<ATABUSplashAd> _Nonnull)splashAd {
    [ATLogger logMessage:@"ATMobrainSplashCustomEvent::splashAdDidVisible" type:ATLogTypeExternal];
    [self trackSplashAdShow];
}

/**
 This method is called when splash ad is clicked.
 */
- (void)splashAdDidClick:(id<ATABUSplashAd> _Nonnull)splashAd {
    [ATLogger logMessage:@"ATMobrainSplashCustomEvent::splashAdDidClick" type:ATLogTypeExternal];
    [self trackSplashAdClick];
}

/**
 This method is called when splash ad is closed.
 */
- (void)splashAdDidClose:(id<ATABUSplashAd> _Nonnull)splashAd {
    [ATLogger logMessage:@"ATMobrainSplashCustomEvent::splashAdDidClose" type:ATLogTypeExternal];
    [self trackSplashAdClosed];
    [splashAd destoryAd];
}

/**
 * This method is called when FullScreen modal has been presented.Include appstore jump.
 *  弹出全屏广告页
 */
- (void)splashAdWillPresentFullScreenModal:(id<ATABUSplashAd> _Nonnull)splashAd {
    [ATLogger logMessage:@"ATMobrainSplashCustomEvent::splashAdWillPresentFullScreenModal" type:ATLogTypeExternal];
}

/**
 This method is called when spalashAd countdown equals to zero
 */
- (void)splashAdCountdownToZero:(id<ATABUSplashAd> _Nonnull)splashAd {
    [ATLogger logMessage:@"ATMobrainSplashCustomEvent::splashAdCountdownToZero" type:ATLogTypeExternal];
}

/**
 * Sent when a player finished. for express Ads when splashAd.hasExpressAdGot = YES
 * @param error : error of player
 */
- (void)splashAdExpressViewDidPlayFinish:(id<ATABUSplashAd> _Nonnull)splashAd error:(NSError *_Nullable)error {
    [ATLogger logMessage:@"ATMobrainSplashCustomEvent::splashAdExpressViewDidPlayFinish" type:ATLogTypeExternal];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"];
}

- (NSDictionary *)networkCustomInfo {
    
    id<ATABUSplashAd> splash = self.ad.customObject;
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    [extra AT_setDictValue:@([splash getAdNetworkPlaformId]) key:@"network_id"];
    [extra AT_setDictValue:[splash getAdNetworkRitId] key:@"network_unit_id"];
    [extra AT_setDictValue:[splash getPreEcpm] key:@"network_ecpm"];

    return extra;
}
@end
