//
//  ATChartboostBannerCustomEvent.m
//  AnyThinkChartboostBannerAdapter
//
//  Created by Martin Lau on 2020/6/10.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATChartboostBannerCustomEvent.h"
#import "ATLogger.h"
#import "ATBannerManager.h"


@implementation ATChartboostBannerCustomEvent
- (void)didCacheAd:(id<ATCHBCacheEvent>)event error:(id<ATCHBError>)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"ChartboostBanner::didCacheAd:error:%@", error == nil ? @"" : @{@0:@"CHBCacheErrorCodeInternal",
                                                                                                                     @1:@"CHBCacheErrorCodeInternetUnavailable",
                                                                                                                     @5:@"CHBCacheErrorCodeNetworkFailure",
                                                                                                                     @6:@"CHBCacheErrorCodeNoAdFound",
                                                                                                                     @7:@"CHBCacheErrorCodeSessionNotStarted",
                                                                                                                     @16:@"CHBCacheErrorCodeAssetDownloadFailure",
                                                                                                                     @35:@"CHBCacheErrorCodePublisherDisabled"
    }[@(error.code)]] type:ATLogTypeExternal];
    if (error != nil) {
        [self trackBannerAdLoadFailed:[NSError errorWithDomain:@"com.anythink.ChartboostBannreLoading" code:error.code userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load banner", NSLocalizedFailureReasonErrorKey:@"Chartboost has failed to load banner"}]];
    } else {
//        [self handleAssets:@{kBannerAssetsUnitIDKey:self.unitID != nil ? self.unitID : @"", kBannerAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:event}];
        [self trackBannerAdLoaded:nil adExtra:@{kBannerAssetsUnitIDKey:self.unitID != nil ? self.unitID : @"", kBannerAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:event}];
    }
}

- (void)willShowAd:(id)event { [ATLogger logMessage:@"ChartboostBanner::willShowAd:" type:ATLogTypeExternal]; }

- (void)willShowAd:(id)event error:(id<ATCHBError>)error { [ATLogger logMessage:[NSString stringWithFormat:@"ChartboostBanner::willShowAd:error:%@", @(error.code)] type:ATLogTypeExternal]; }

- (void)didShowAd:(id)event error:(id<ATCHBError>)error { [ATLogger logMessage:[NSString stringWithFormat:@"ChartboostBanner::didShowAd:error:%@", @(error.code)] type:ATLogTypeExternal]; }

- (void)didClickAd:(id)event error:(id<ATCHBError>)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"ChartboostBanner::didClickAd:error:%@", error != nil ? @(error.code) : @""] type:ATLogTypeExternal];
    [self trackBannerAdClick];
}

- (void)didFinishHandlingClick:(id)event error:(id<ATCHBError>)error { [ATLogger logMessage:[NSString stringWithFormat:@"ChartboostBanner::didFinishHandlingClick:error:%@", @(error.code)] type:ATLogTypeExternal]; }

- (NSString *)networkUnitId {
    return self.serverInfo[@"location"];
}
@end
