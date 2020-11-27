//
//  ATTTSplashCustomEvent.m
//  AnyThinkTTSplashAdapter
//
//  Created by Martin Lau on 2018/12/21.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATTTSplashCustomEvent.h"
#import "Utilities.h"
#import "ATSplashManager.h"
#import "ATSplashDelegate.h"

@implementation ATTTSplashCustomEvent
- (void)splashAdDidClick:(id<ATBUSplashAdView>)splashAd {
    [ATLogger logMessage:@"TTSplash::splashAdDidClick" type:ATLogTypeExternal];
    [self trackSplashAdClick];
}

- (void)splashAdDidClose:(id<ATBUSplashAdView>)splashAd {
    [ATLogger logMessage:@"TTSplash::splashAdDidClose" type:ATLogTypeExternal];
    [_containerView removeFromSuperview];
    [_backgroundImageView removeFromSuperview];
    [(UIView*)splashAd removeFromSuperview];
    [self trackSplashAdClosed];
}

- (void)splashAdWillClose:(id<ATBUSplashAdView>)splashAd {
    [ATLogger logMessage:@"TTSplash::splashAdWillClose" type:ATLogTypeExternal];
}

- (void)splashAdDidLoad:(id<ATBUSplashAdView>)splashAd {
    [ATLogger logMessage:@"TTSplash::splashAdDidLoad" type:ATLogTypeExternal];
    if ([[NSDate date] timeIntervalSinceDate:_expireDate] > 0) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadSplashADMsg, NSLocalizedFailureReasonErrorKey:@"It took too long for TT to load splash."}];
        [_backgroundImageView removeFromSuperview];
        [self trackSplashAdLoadFailed:error];
    } else {
        [_window addSubview:_containerView];
        [_window addSubview:_ttSplashView];
        [self trackSplashAdLoaded:splashAd];
        [self trackSplashAdShow];
    }
}

- (void)splashAd:(id<ATBUSplashAdView>)splashAd didFailWithError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"TTSplash::splashAd:didFailWithError:%@", error] type:ATLogTypeExternal];
    [_backgroundImageView removeFromSuperview];
    [_ttSplashView removeFromSuperview];
    [_containerView removeFromSuperview];
    [self handleLoadingFailure:error];
}

- (void)splashAdWillVisible:(id<ATBUSplashAdView>)splashAd {
    [ATLogger logMessage:@"TTSplash::splashAdWillVisible" type:ATLogTypeExternal];
}


#pragma mark - nativeExpressSplash

- (void)nativeExpressSplashViewDidLoad:(id<BUNativeExpressSplashView>)splashAdView {
    
}

- (void)nativeExpressSplashView:(id<BUNativeExpressSplashView>)splashAdView didFailWithError:(NSError * _Nullable)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"TTSplash::splashAd:didFailWithError:%@", error] type:ATLogTypeExternal];
    [_backgroundImageView removeFromSuperview];
    [_ttSplashView removeFromSuperview];
    [_containerView removeFromSuperview];
    [self trackSplashAdLoadFailed:error];
}

- (void)nativeExpressSplashViewRenderSuccess:(id<BUNativeExpressSplashView>)splashAdView {
    [ATLogger logMessage:@"TTSplash::splashAdDidLoad" type:ATLogTypeExternal];
    if ([[NSDate date] timeIntervalSinceDate:_expireDate] > 0) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadSplashADMsg, NSLocalizedFailureReasonErrorKey:@"It took too long for TT to load splash."}];
        [_backgroundImageView removeFromSuperview];
        [self trackSplashAdLoadFailed:error];
    } else {
        [_window addSubview:_containerView];
        [_window addSubview:_ttSplashView];
        [self trackSplashAdLoaded:splashAdView];
    }
}

- (void)nativeExpressSplashViewRenderFail:(id<BUNativeExpressSplashView>)splashAdView error:(NSError * __nullable)error {
    [_backgroundImageView removeFromSuperview];
    [self trackSplashAdLoadFailed:error];
}

- (void)nativeExpressSplashViewWillVisible:(id<BUNativeExpressSplashView>)splashAdView {
    
}

- (void)nativeExpressSplashViewDidClick:(id<BUNativeExpressSplashView>)splashAdView {
    [ATLogger logMessage:@"TTSplash::splashAdDidClick" type:ATLogTypeExternal];
    [self trackSplashAdClick];
}

- (void)nativeExpressSplashViewDidClickSkip:(id<BUNativeExpressSplashView>)splashAdView {
    
}

- (void)nativeExpressSplashViewDidClose:(id<BUNativeExpressSplashView>)splashAdView {
    [ATLogger logMessage:@"TTSplash::splashAdDidClose" type:ATLogTypeExternal];
    [_containerView removeFromSuperview];
    [_backgroundImageView removeFromSuperview];
    [(UIView*)splashAdView removeFromSuperview];
    [self trackSplashAdClosed];

}

- (void)nativeExpressSplashViewFinishPlayDidPlayFinish:(id<BUNativeExpressSplashView>)splashView didFailWithError:(NSError *)error {
    
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.ad.unitGroup.content[@"slot_id"];
//    return extra;
//}

@end
