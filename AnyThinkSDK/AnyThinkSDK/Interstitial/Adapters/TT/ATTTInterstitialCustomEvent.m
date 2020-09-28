//
//  ATTTInterstitialCustomEvent.m
//  AnyThinkTTInterstitialAdapter
//
//  Created by Martin Lau on 25/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATTTInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"

@implementation ATTTInterstitialCustomEvent
-(ATNativeADSourceType) adSourceType {
    return [self.interstitial.unitGroup.content[@"is_video"] boolValue] ? ATNativeADSourceTypeVideo : ATNativeADSourceTypeImage;
}
#pragma mark - interstitial delegate method(s)
- (void)interstitialAdDidLoad:(id<ATBUInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"TTInterstitial::interstitialAdDidLoad:" type:ATLogTypeExternal];
    [self trackInterstitialAdLoaded:interstitialAd adExtra:nil];
}

- (void)interstitialAd:(id<ATBUInterstitialAd>)interstitialAd didFailWithError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"TTInterstitial::interstitialAd:didFailWithError:%@", error] type:ATLogTypeExternal];
    [self trackInterstitialAdLoadFailed:error];
}

- (void)interstitialAdWillVisible:(id<ATBUInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"TTInterstitial::interstitialAdWillVisible:" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
}

- (void)interstitialAdDidClick:(id<ATBUInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"TTInterstitial::interstitialAdDidClick:" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
}

- (void)interstitialAdDidClose:(id<ATBUInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"TTInterstitial::interstitialAdDidClose:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
}

- (void)interstitialAdWillClose:(id<ATBUInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"TTInterstitial::interstitialAdWillClose:" type:ATLogTypeExternal];
}

#pragma mark - full screen video ad
- (void)fullscreenVideoMaterialMetaAdDidLoad:(id<ATBUFullscreenVideoAd>)fullscreenVideoAd {
    [ATLogger logMessage:@"TTInterstitial::fullscreenVideoMaterialMetaAdDidLoad:" type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

- (void)fullscreenVideoAdVideoDataDidLoad:(id<ATBUFullscreenVideoAd>)fullscreenVideoAd {
    [ATLogger logMessage:@"TTInterstitial::fullscreenVideoAdVideoDataDidLoad:" type:ATLogTypeExternal];
    [self trackInterstitialAdLoaded:fullscreenVideoAd adExtra:nil];
}

- (void)fullscreenVideoAdWillVisible:(id<ATBUFullscreenVideoAd>)fullscreenVideoAd {
    [ATLogger logMessage:@"TTInterstitial::fullscreenVideoAdWillVisible:" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
}

- (void)fullscreenVideoAdDidClose:(id<ATBUFullscreenVideoAd>)fullscreenVideoAd {
    [ATLogger logMessage:@"TTInterstitial::fullscreenVideoAdDidClose:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
}

- (void)fullscreenVideoAdDidClick:(id<ATBUFullscreenVideoAd>)fullscreenVideoAd {
    [ATLogger logMessage:@"TTInterstitial::fullscreenVideoAdDidClick:" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
}

- (void)fullscreenVideoAd:(id<ATBUFullscreenVideoAd>)fullscreenVideoAd didFailWithError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"TTInterstitial::fullscreenVideoAd:didFailWithError:%@", error] type:ATLogTypeExternal];
    [self trackInterstitialAdLoadFailed:error];
}

- (void)fullscreenVideoAdDidPlayFinish:(id<ATBUFullscreenVideoAd>)fullscreenVideoAd didFailWithError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"TTInterstitial::fullscreenVideoAdDidPlayFinish:didFailWithError:%@", error] type:ATLogTypeExternal];
    if (error != nil) {
        [self trackInterstitialAdDidFailToPlayVideo:error];
    } else {
        [self trackInterstitialAdVideoEnd];
    }
}

- (void)fullscreenVideoAdDidClickSkip:(id<ATBUFullscreenVideoAd>)fullscreenVideoAd {
    [ATLogger logMessage:@"TTInterstitial::fullscreenVideoAdDidClickSkip:" type:ATLogTypeExternal];
}

#pragma mark - express interstitial ad
- (void)nativeExpresInterstitialAdDidLoad:(id<ATBUNativeExpressInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"TTInterstitial::nativeExpresInterstitialAdDidLoad:" type:ATLogTypeExternal];
}

- (void)nativeExpresInterstitialAd:(id<ATBUNativeExpressInterstitialAd>)interstitialAd didFailWithError:(NSError * __nullable)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"TTInterstitial::nativeExpresInterstitialAd:didFailWithError:%@", error] type:ATLogTypeExternal];
    if (!_isFailed) {
        [self trackInterstitialAdLoadFailed:error != nil ? error : [NSError errorWithDomain:@"com.anythink.TTInterstitialAdLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:ATSDKAdLoadFailedErrorMsg, NSLocalizedFailureReasonErrorKey:@"TT has failed to load interstitial"}]];
        _isFailed = true;
    }
}

- (void)nativeExpresInterstitialAdRenderSuccess:(id<ATBUNativeExpressInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"TTInterstitial::nativeExpresInterstitialAdRenderSuccess:" type:ATLogTypeExternal];
    [self trackInterstitialAdLoaded:interstitialAd adExtra:nil];
}

- (void)nativeExpresInterstitialAdRenderFail:(id<ATBUNativeExpressInterstitialAd>)interstitialAd error:(NSError * __nullable)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"TTInterstitial::nativeExpresInterstitialAdRenderFail:error:%@", error] type:ATLogTypeExternal];
    if (!_isFailed) {
        [self trackInterstitialAdLoadFailed:error != nil ? error : [NSError errorWithDomain:@"com.anythink.TTInterstitialAdLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:ATSDKAdLoadFailedErrorMsg, NSLocalizedFailureReasonErrorKey:@"TT has failed to load interstitial"}]];
        _isFailed = true;
    }

}

- (void)nativeExpresInterstitialAdWillVisible:(id<ATBUNativeExpressInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"TTInterstitial::nativeExpresInterstitialAdWillVisible:" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
}

- (void)nativeExpresInterstitialAdDidClick:(id<ATBUNativeExpressInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"TTInterstitial::nativeExpresInterstitialAdDidClick:" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
}

- (void)nativeExpresInterstitialAdWillClose:(id<ATBUNativeExpressInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"TTInterstitial::nativeExpresInterstitialAdWillClose:" type:ATLogTypeExternal];
}

- (void)nativeExpresInterstitialAdDidClose:(id<ATBUNativeExpressInterstitialAd>)interstitialAd {
    [ATLogger logMessage:@"TTInterstitial::nativeExpresInterstitialAdDidClose:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
}

#pragma mark - express fullScreen ad
- (void)nativeExpressFullscreenVideoAdDidLoad:(id <ATBUNativeExpressFullscreenVideoAd>)fullscreenVideoAd {
    [ATLogger logMessage:@"TTNaticeExpressFullScreenVideo::nativeExpressFullscreenVideoAdDidLoad:" type:ATLogTypeExternal];
    [self trackInterstitialAdLoaded:fullscreenVideoAd adExtra:nil];
}

- (void)nativeExpressFullscreenVideoAd:(id <ATBUNativeExpressFullscreenVideoAd>)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"TTNaticeExpressFullScreenVideo::nativeExpressFullscreenVideoAd:didFailWithError:%@", error] type:ATLogTypeExternal];
    if (!_isFailed) {
        [self trackInterstitialAdLoadFailed:error];
        _isFailed = true;
    }
}

- (void)nativeExpressFullscreenVideoAdViewRenderSuccess:(id <ATBUNativeExpressFullscreenVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"TTNaticeExpressFullScreenVideo::nativeExpressFullscreenVideoAdViewRenderSuccess:" type:ATLogTypeExternal];
}

- (void)nativeExpressFullscreenVideoAdViewRenderFail:(id <ATBUNativeExpressFullscreenVideoAd>)rewardedVideoAd error:(NSError *_Nullable)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"TTNaticeExpressFullScreenVideo::nativeExpressFullscreenVideoAdViewRenderFail:didFailWithError:%@", error] type:ATLogTypeExternal];
    if (!_isFailed) {
        [self trackInterstitialAdLoadFailed:error];
        _isFailed = true;
    }
}

- (void)nativeExpressFullscreenVideoAdDidDownLoadVideo:(id <ATBUNativeExpressFullscreenVideoAd>)fullscreenVideoAd {
    [ATLogger logMessage:@"TTNaticeExpressFullScreenVideo::nativeExpressFullscreenVideoAdDidDownLoadVideo:" type:ATLogTypeExternal];

}

- (void)nativeExpressFullscreenVideoAdWillVisible:(id <ATBUNativeExpressFullscreenVideoAd>)fullscreenVideoAd {
    [ATLogger logMessage:@"TTNaticeExpressFullScreenVideo::nativeExpressFullscreenVideoAdWillVisible:" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
}

- (void)nativeExpressFullscreenVideoAdDidVisible:(id <ATBUNativeExpressFullscreenVideoAd>)fullscreenVideoAd {
    
}

- (void)nativeExpressFullscreenVideoAdDidClick:(id <ATBUNativeExpressFullscreenVideoAd>)fullscreenVideoAd {
    [ATLogger logMessage:@"TTNaticeExpressFullScreenVideo::nativeExpressFullscreenVideoAdDidClick:" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
}

- (void)nativeExpressFullscreenVideoAdDidClickSkip:(id <ATBUNativeExpressFullscreenVideoAd>)fullscreenVideoAd {
    [ATLogger logMessage:@"TTNaticeExpressFullScreenVideo::nativeExpressFullscreenVideoAdDidClickSkip:" type:ATLogTypeExternal];

}

- (void)nativeExpressFullscreenVideoAdWillClose:(id <ATBUNativeExpressFullscreenVideoAd>)fullscreenVideoAd {
    [ATLogger logMessage:@"TTNaticeExpressFullScreenVideo::nativeExpressFullscreenVideoAdWillClose:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
}

- (void)nativeExpressFullscreenVideoAdDidClose:(id <ATBUNativeExpressFullscreenVideoAd>)fullscreenVideoAd {
    
}

- (void)nativeExpressFullscreenVideoAdDidPlayFinish:(id <ATBUNativeExpressFullscreenVideoAd>)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"TTNaticeExpressFullScreenVideo::nativeExpressFullscreenVideoAdDidPlayFinish:didFailWithError:%@", error] type:ATLogTypeExternal];
    if (error != nil) {
        [self trackInterstitialAdDidFailToPlayVideo:error];
    } else {
        [self trackInterstitialAdVideoEnd];
    }
    
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
