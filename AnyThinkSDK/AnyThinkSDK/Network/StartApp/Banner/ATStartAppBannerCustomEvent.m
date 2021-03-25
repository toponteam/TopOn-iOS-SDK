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
    [self trackBannerAdLoaded:banner adExtra:nil];
}

- (void) didDisplayBannerAd:(id<ATSTABannerView>)banner {
    [ATLogger logMessage:@"StartAppBanner::didDisplayBannerAd:" type:ATLogTypeExternal];

}

/// This is an override method, for more detailsplease refer to ATBannerCustomEvent.h
- (BOOL)sendImpressionTrackingIfNeed {
    return YES;
}
- (void) failedLoadBannerAd:(id)banner withError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"StartAppBanner::failedLoadBannerAd:error:%@", error] type:ATLogTypeExternal];
    [self trackBannerAdLoadFailed:error != nil ? error : [NSError errorWithDomain:@"com.anythink.StartAppBannerLoading" code:0 userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:@"StartAppSDK has failed to load banner"}]];
}

- (void) didClickBannerAd:(id<ATSTABannerView>)banner {
    [ATLogger logMessage:@"StartAppBanner::didClickBannerAd:" type:ATLogTypeExternal];
    [banner setOrigin:banner.frame.origin];
    [self trackBannerAdClick];
}

- (void) didCloseBannerInAppStore:(id)banner { [ATLogger logMessage:@"StartAppBanner::didCloseBannerInAppStore:" type:ATLogTypeExternal]; }

- (NSString *)networkUnitId {
    return self.serverInfo[@"ad_tag"];
}
@end
