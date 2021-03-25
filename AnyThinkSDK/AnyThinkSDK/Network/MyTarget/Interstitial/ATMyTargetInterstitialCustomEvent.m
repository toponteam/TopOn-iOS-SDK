//
//  ATMyTargetInterstitialCustomEvent.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/12/25.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATMyTargetInterstitialCustomEvent.h"
#import "ATLogger.h"

@interface ATMyTargetInterstitialCustomEvent()

@end

@implementation ATMyTargetInterstitialCustomEvent

// MARK:- MTRGInterstitialAdDelegate

- (void)onLoadWithInterstitialAd:(id<ATMTRGInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"ATMyTargetInterstitialCustomEvent::onLoadWithInterstitialAd:" type:ATLogTypeExternal];
    [self trackInterstitialAdLoaded:interstitialAd adExtra:@{kAdAssetsPriceKey: _price ? _price : @"", kAdAssetsBidIDKey: _bidID ? _bidID : @""}];
}

- (void)onNoAdWithReason:(NSString *)reason interstitialAd:(id<ATMTRGInterstitialAd>)interstitialAd {
    [ATLogger logMessage:[NSString stringWithFormat:@"ATMyTargetInterstitialCustomEvent::onNoAdWithReason:%@",reason] type:ATLogTypeExternal];
    NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:1 userInfo:@{NSLocalizedFailureReasonErrorKey: reason}];
    [self trackInterstitialAdLoadFailed:error];

}

- (void)onClickWithInterstitialAd:(id<ATMTRGInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"ATMyTargetInterstitialCustomEvent::onClickWithInterstitialAd:" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
}

- (void)onCloseWithInterstitialAd:(id<ATMTRGInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"ATMyTargetInterstitialCustomEvent::onCloseWithInterstitialAd:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
}

- (void)onVideoCompleteWithInterstitialAd:(id<ATMTRGInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"ATMyTargetInterstitialCustomEvent::onVideoCompleteWithInterstitialAd:" type:ATLogTypeExternal];
    [self trackInterstitialAdVideoEnd];
}

- (void)onDisplayWithInterstitialAd:(id<ATMTRGInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"ATMyTargetInterstitialCustomEvent::onDisplayWithInterstitialAd:" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
    [self trackInterstitialAdVideoStart];
}

- (void)onLeaveApplicationWithInterstitialAd:(id<ATMTRGInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"ATMyTargetInterstitialCustomEvent::onDisplayWithInterstitialAd:" type:ATLogTypeExternal];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"];
}

@end
