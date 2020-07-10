//
//  ATStartAppBannerCustomEvent.m
//  AnyThinkStartAppBannerAdapter
//
//  Created by Martin Lau on 2020/5/28.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATStartAppBannerCustomEvent.h"
#import "Utilities.h"
#import "ATBannerManager.h"

@implementation ATStartAppBannerCustomEvent
- (void) bannerAdIsReadyToDisplay:(id<ATSTABannerView>)banner {
    [ATLogger logMessage:@"StartAppBanner::bannerAdIsReadyToDisplay:" type:ATLogTypeExternal];
    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:banner, kBannerAssetsBannerViewKey, self, kBannerAssetsCustomEventKey, nil];
    if ([self.unitID length] > 0) assets[kBannerAssetsUnitIDKey] = self.unitID;
    [self handleAssets:assets];
}

- (void) didDisplayBannerAd:(id<ATSTABannerView>)banner {
    [ATLogger logMessage:@"StartAppBanner::didDisplayBannerAd:" type:ATLogTypeExternal];
    
}

- (void) failedLoadBannerAd:(id)banner withError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"StartAppBanner::failedLoadBannerAd:error:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error != nil ? error : [NSError errorWithDomain:@"com.anythink.StartAppBannerLoading" code:0 userInfo:@{NSLocalizedDescriptionKey:@"ATSDK has failed to load banner ad", NSLocalizedFailureReasonErrorKey:@"StartAppSDK has failed to load banner"}]];
}

- (void) didClickBannerAd:(id<ATSTABannerView>)banner {
    [ATLogger logMessage:@"StartAppBanner::didClickBannerAd:" type:ATLogTypeExternal];
    [banner setOrigin:banner.frame.origin];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(bannerView:didClickWithPlacementID:extra:)]) { [self.delegate bannerView:self.bannerView didClickWithPlacementID:self.banner.placementModel.placementID extra:[self delegateExtra]]; }
}

- (void) didCloseBannerInAppStore:(id)banner { [ATLogger logMessage:@"StartAppBanner::didCloseBannerInAppStore:" type:ATLogTypeExternal]; }
@end
