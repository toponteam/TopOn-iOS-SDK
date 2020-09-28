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
//    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kAdAssetsCustomObjectKey:interstitial}];
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

- (NSString *)networkUnitId {
    return self.serverInfo[@"ad_place_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"ad_place_id"];
//    return extra;
//}
@end
