//
//  ATYeahmobiInterstitialCustomEvent.m
//  AnyThinkYeahmobiInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/16.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATYeahmobiInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"

@implementation ATYeahmobiInterstitialCustomEvent
-(void) handleShow {
    [self trackInterstitialAdShow];
}

- (void)CTAdViewDidRecieveInterstitialAd {
    [ATLogger logMessage:@"YeahmobiInterstitial::CTAdViewDidRecieveInterstitialAd" type:ATLogTypeExternal];
//    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kAdAssetsCustomObjectKey:[self.unitID length] > 0 ? self.unitID : @""}];
    [self trackInterstitialAdLoaded:[self.unitID length] > 0 ? self.unitID : @"" adExtra:nil];
}

- (void)CTAdViewDidRecieveInterstitialAdForSlot:(NSString *)slot {
    [ATLogger logMessage:[NSString stringWithFormat:@"YeahmobiInterstitial::CTAdViewDidRecieveInterstitialAdForSlot:%@", slot] type:ATLogTypeExternal];
}

- (void)CTAdView:(id<ATCTADMRAIDView>)adView didFailToReceiveAdWithError:(NSError*)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"YeahmobiInterstitial::CTAdView:didFailToReceiveAdWithError:%@", error] type:ATLogTypeExternal];
    [self trackInterstitialAdLoadFailed:error];
}

- (void)CTAdViewCloseButtonPressed:(id<ATCTADMRAIDView>)adView {
    [ATLogger logMessage:@"YeahmobiInterstitial::CTAdViewCloseButtonPressed:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
}

- (BOOL)CTAdView:(id<ATCTADMRAIDView>)adView shouldOpenURL:(NSURL*)url {
    [ATLogger logMessage:[NSString stringWithFormat:@"YeahmobiInterstitial::CTAdView:shouldOpenURL:%@", url] type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
    return YES;
}

- (void)CTAdViewInternalBrowserWillOpen:(id<ATCTADMRAIDView>)adView {
    [ATLogger logMessage:@"YeahmobiInterstitial::CTAdViewInternalBrowserWillOpen:" type:ATLogTypeExternal];
}

- (void)CTAdViewInternalBrowserDidOpen:(id<ATCTADMRAIDView>)adView {
    [ATLogger logMessage:@"YeahmobiInterstitial::CTAdViewInternalBrowserDidOpen:" type:ATLogTypeExternal];
}

- (void)CTAdViewInternalBrowserWillClose:(id<ATCTADMRAIDView>)adView {
    [ATLogger logMessage:@"YeahmobiInterstitial::CTAdViewInternalBrowserWillClose:" type:ATLogTypeExternal];
}

- (void)CTAdViewInternalBrowserDidClose:(id<ATCTADMRAIDView>)adView {
    [ATLogger logMessage:@"YeahmobiInterstitial::CTAdViewInternalBrowserDidClose:" type:ATLogTypeExternal];
}

- (void)CTAdViewWillLeaveApplication:(id<ATCTADMRAIDView>)adView {
    [ATLogger logMessage:@"YeahmobiInterstitial::CTAdViewWillLeaveApplication:" type:ATLogTypeExternal];
}

- (BOOL)CTAdView:(id<ATCTADMRAIDView>)adView shouldLogEvent:(NSString*)event ofType:(NSInteger)type {
    [ATLogger logMessage:[NSString stringWithFormat:@"YeahmobiInterstitial::CTAdView:shouldLogEvent:%@ ofType:%ld", event, type] type:ATLogTypeExternal];
    return YES;
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"slot_id"];
//    return extra;
//}
@end
