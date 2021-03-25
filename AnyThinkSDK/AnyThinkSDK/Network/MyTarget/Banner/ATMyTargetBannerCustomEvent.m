//
//  ATMyTargetBannerCustomEvent.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/12/25.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATMyTargetBannerCustomEvent.h"
#import "ATLogger.h"

@implementation ATMyTargetBannerCustomEvent

- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"];
}

- (void)onLoadWithAdView:(id<ATMTRGAdView>)adView {
    [ATLogger logMessage:@"ATMyTargetBannerCustomEvent::onLoadWithAdView:" type:ATLogTypeExternal];
    [self trackBannerAdLoaded:adView adExtra:@{kAdAssetsPriceKey: _price ? _price : @"", kAdAssetsBidIDKey: _bidID ? _bidID : @""}];
}

- (void)onNoAdWithReason:(NSString *)reason adView:(id<ATMTRGAdView>)adView {
    [ATLogger logMessage:[NSString stringWithFormat:@"ATMyTargetBannerCustomEvent::onNoAdWithReason:%@",reason] type:ATLogTypeExternal];
    NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:1 userInfo:@{NSLocalizedFailureReasonErrorKey: reason}];
    [self trackBannerAdLoadFailed:error];
}

- (void)onAdClickWithAdView:(id<ATMTRGAdView>)adView {
    [ATLogger logMessage:@"ATMyTargetBannerCustomEvent::onAdClickWithAdView:" type:ATLogTypeExternal];
    [self trackBannerAdClick];
}

- (void)onAdShowWithAdView:(id<ATMTRGAdView>)adView {
    [ATLogger logMessage:@"ATMyTargetBannerCustomEvent::onAdShowWithAdView:" type:ATLogTypeExternal];
    [self trackBannerAdImpression];
}

//- (void)onShowModalWithAdView:(id<ATMTRGAdView>)adView {
//    [ATLogger logMessage:@"ATMyTargetBannerCustomEvent::onShowModalWithAdView:" type:ATLogTypeExternal];
//    [self trackBannerAdImpression];
//}

- (void)onDismissModalWithAdView:(id<ATMTRGAdView>)adView {
    [ATLogger logMessage:@"ATMyTargetBannerCustomEvent::onDismissModalWithAdView:" type:ATLogTypeExternal];
    [self trackBannerAdClosed];
}

- (void)onLeaveApplicationWithAdView:(id<ATMTRGAdView>)adView {
    [ATLogger logMessage:@"ATMyTargetBannerCustomEvent::onLeaveApplicationWithAdView:" type:ATLogTypeExternal];

}

@end
