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
    return self.customInfo[@"app_id"];
}

- (BOOL) enableLocation {
    [ATLogger logMessage:@"BaiduInterstitial::enableLocation" type:ATLogTypeExternal];
    return NO;
}

- (void)interstitialSuccessToLoadAd:(id<ATBaiduMobAdInterstitial>)interstitial {
    [ATLogger logMessage:@"BaiduInterstitial::interstitialSuccessToLoadAd:" type:ATLogTypeExternal];
    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kAdAssetsCustomObjectKey:interstitial}];
}

- (void)interstitialFailToLoadAd:(id<ATBaiduMobAdInterstitial>)interstitial {
    [ATLogger logMessage:@"BaiduInterstitial::interstitialFailToLoadAd:" type:ATLogTypeExternal];
    [self handleLoadingFailure:[NSError errorWithDomain:@"com.anythink.BaiduInterstitial" code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"ATSDK has failed to load interstitial.", NSLocalizedFailureReasonErrorKey:@"BaiduSDK has failed to load interstitial."}]];
}

- (void)interstitialWillPresentScreen:(id<ATBaiduMobAdInterstitial>)interstitial {
    [ATLogger logMessage:@"BaiduInterstitial::interstitialWillPresentScreen:" type:ATLogTypeExternal];
    [self trackShow];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
}

- (void)interstitialSuccessPresentScreen:(id<ATBaiduMobAdInterstitial>)interstitial {
    [ATLogger logMessage:@"BaiduInterstitial::interstitialSuccessPresentScreen:" type:ATLogTypeExternal];
}

- (void)interstitialFailPresentScreen:(id<ATBaiduMobAdInterstitial>)interstitial withError:(NSInteger) reason {
    [ATLogger logMessage:@"BaiduInterstitial::interstitialFailPresentScreen:" type:ATLogTypeExternal];
}

- (void)interstitialDidAdClicked:(id<ATBaiduMobAdInterstitial>)interstitial {
    [ATLogger logMessage:@"BaiduInterstitial::interstitialDidAdClicked:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
        [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)interstitialDidDismissScreen:(id<ATBaiduMobAdInterstitial>)interstitial {
    [ATLogger logMessage:@"BaiduInterstitial::interstitialDidDismissScreen:" type:ATLogTypeExternal];
    [self handleClose];
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) {
        [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
    interstitial.delegate = nil;
    self.delegate = nil;
}

- (void)interstitialDidDismissLandingPage:(id<ATBaiduMobAdInterstitial>)interstitial {
    [ATLogger logMessage:@"BaiduInterstitial::interstitialDidDismissLandingPage:" type:ATLogTypeExternal];
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"ad_place_id"];
    return extra;
}
@end
