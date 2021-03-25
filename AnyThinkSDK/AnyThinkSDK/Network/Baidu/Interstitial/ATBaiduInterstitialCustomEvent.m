//
//  ATBaiduInterstitialCustomEvent.m
//  AnyThinkBaiduInterstitialAdapter
//
//  Created by Martin Lau on 2018/11/30.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATBaiduInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATAPI.h"
#import "ATInterstitialManager.h"

@implementation ATBaiduInterstitialCustomEvent
- (NSString *)publisherId {
    return self.serverInfo[@"app_id"];
}

- (BOOL) enableLocation {
    [ATLogger logMessage:@"BaiduInterstitial::enableLocation" type:ATLogTypeExternal];
    return NO;
}

- (void)interstitialSuccessToLoadAd:(id<ATBaiduMobAdInterstitial>)interstitial {
    [ATLogger logMessage:@"BaiduInterstitial::interstitialSuccessToLoadAd:" type:ATLogTypeExternal];
    [self trackInterstitialAdLoaded:interstitial adExtra:nil];
}

- (void)interstitialFailToLoadAd:(id<ATBaiduMobAdInterstitial>)interstitial {
    [ATLogger logMessage:@"BaiduInterstitial::interstitialFailToLoadAd:" type:ATLogTypeExternal];
    [self trackInterstitialAdLoadFailed:[NSError errorWithDomain:@"com.anythink.BaiduInterstitial" code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:@"BaiduSDK has failed to load interstitial."}]];
}

- (void)interstitialWillPresentScreen:(id<ATBaiduMobAdInterstitial>)interstitial {
    [ATLogger logMessage:@"BaiduInterstitial::interstitialWillPresentScreen:" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
}

- (void)interstitialSuccessPresentScreen:(id<ATBaiduMobAdInterstitial>)interstitial {
    [ATLogger logMessage:@"BaiduInterstitial::interstitialSuccessPresentScreen:" type:ATLogTypeExternal];
}

- (void)interstitialFailPresentScreen:(id<ATBaiduMobAdInterstitial>)interstitial withError:(NSInteger) reason {
    [ATLogger logMessage:@"BaiduInterstitial::interstitialFailPresentScreen:" type:ATLogTypeExternal];
}

- (void)interstitialDidAdClicked:(id<ATBaiduMobAdInterstitial>)interstitial {
    [ATLogger logMessage:@"BaiduInterstitial::interstitialDidAdClicked:" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
}

- (void)interstitialDidDismissScreen:(id<ATBaiduMobAdInterstitial>)interstitial {
    [ATLogger logMessage:@"BaiduInterstitial::interstitialDidDismissScreen:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
    interstitial.delegate = nil;
    self.delegate = nil;
}

- (void)interstitialDidDismissLandingPage:(id<ATBaiduMobAdInterstitial>)interstitial {
    [ATLogger logMessage:@"BaiduInterstitial::interstitialDidDismissLandingPage:" type:ATLogTypeExternal];
}


#pragma mark - BaiduMobAdExpressFullScreenVideoDelegate
- (void)fullScreenVideoAdLoadSuccess:(id<ATBaiduMobAdExpressFullScreenVideo>)video {
    [ATLogger logMessage:@"BaiduInterstitial::fullScreenVideoAdLoadSuccess:" type:ATLogTypeExternal];
    [self trackInterstitialAdLoaded:video adExtra:nil];
}

- (void)fullScreenVideoAdLoadFail:(id<ATBaiduMobAdExpressFullScreenVideo>)video{
    [ATLogger logMessage:@"BaiduInterstitial::fullScreenVideoAdLoadFail:" type:ATLogTypeExternal];
    [self trackInterstitialAdLoadFailed:[NSError errorWithDomain:@"com.anythink.BaiduInterstitial" code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:@"BaiduSDK has failed to load interstitial."}]];
}

- (void)fullScreenVideoAdLoaded:(id<ATBaiduMobAdExpressFullScreenVideo>)video {
    [ATLogger logMessage:@"BaiduInterstitial::fullScreenVideoAdLoaded:" type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

- (void)fullScreenVideoAdLoadFailed:(id<ATBaiduMobAdExpressFullScreenVideo>)video withError:(ATBaiduMobFailReason)reason {
    [ATLogger logMessage:[NSString stringWithFormat:@"BaiduInterstitial::fullScreenVideoAdLoadFailed:withError:%u",reason] type:ATLogTypeExternal];
}

- (void)fullScreenVideoAdDidStarted:(id<ATBaiduMobAdExpressFullScreenVideo>)video {
    [ATLogger logMessage:@"BaiduInterstitial::fullScreenVideoAdDidStarted:" type:ATLogTypeExternal];
    [self trackInterstitialAdVideoStart];
}

- (void)fullScreenVideoAdShowFailed:(id<ATBaiduMobAdExpressFullScreenVideo>)video withError:(ATBaiduMobFailReason)reason {
    [ATLogger logMessage:[NSString stringWithFormat:@"BaiduInterstitial::fullScreenVideoAdShowFailed:withError:%u",reason] type:ATLogTypeExternal];
    [self trackInterstitialAdShowFailed:[NSError errorWithDomain:@"com.anythink.BaiduInterstitial" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"BaiduSDK has failed to show interstitial video", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"BaiduSDK has failed to show interstitial video, reason:%u",reason]}]];
}

- (void)fullScreenVideoAdDidPlayFinish:(id<ATBaiduMobAdExpressFullScreenVideo>)video {
    [ATLogger logMessage:@"BaiduInterstitial::fullScreenVideoAdDidPlayFinish:" type:ATLogTypeExternal];
    [self trackInterstitialAdVideoEnd];
}

- (void)fullScreenVideoAdDidClose:(id<ATBaiduMobAdExpressFullScreenVideo>)video withPlayingProgress:(CGFloat)progress {
    [ATLogger logMessage:@"BaiduInterstitial::fullScreenVideoAdDidClose:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
    video.delegate = nil;
    self.delegate = nil;
}

- (void)fullScreenVideoAdDidSkip:(id<ATBaiduMobAdExpressFullScreenVideo>)video withPlayingProgress:(CGFloat)progress {
    [ATLogger logMessage:@"BaiduInterstitial::fullScreenVideoAdDidSkip:withPlayingProgress:" type:ATLogTypeExternal];
    
}

- (void)fullScreenVideoAdDidClick:(id<ATBaiduMobAdExpressFullScreenVideo>)video withPlayingProgress:(CGFloat)progress {
    [ATLogger logMessage:@"BaiduInterstitial::fullScreenVideoAdDidClick:withPlayingProgress:" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"ad_place_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"ad_place_id"];
//    return extra;
//}
@end
