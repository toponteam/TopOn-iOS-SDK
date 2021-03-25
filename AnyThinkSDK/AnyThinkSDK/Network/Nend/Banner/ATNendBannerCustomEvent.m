//
//  ATNendBannerCustomEvent.m
//  AnyThinkNendBannerAdapter
//
//  Created by Martin Lau on 2019/4/19.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATNendBannerCustomEvent.h"
#import "Utilities.h"
#import "ATBannerManager.h"


@implementation ATNendBannerCustomEvent
- (void)nadViewDidFinishLoad:(id<ATNADView>)adView {
    [ATLogger logMessage:@"NendBanner::nadViewDidFinishLoad:" type:ATLogTypeExternal];
}

- (void)nadViewDidReceiveAd:(id<ATNADView>)adView {
    [ATLogger logMessage:@"NendBanner::nadViewDidReceiveAd:" type:ATLogTypeExternal];

    [self trackBannerAdLoaded:adView adExtra:nil];
}

- (void)nadViewDidFailToReceiveAd:(id<ATNADView>)adView {
    [ATLogger logMessage:@"NendBanner::nadViewDidFailToReceiveAd:" type:ATLogTypeExternal];
    [self trackBannerAdLoadFailed:[NSError errorWithDomain:@"com.anythink.NendBannerLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load banner", NSLocalizedFailureReasonErrorKey:@"NendBanner has failed to load banner ad"}]];
}

- (void)nadViewDidClickAd:(id<ATNADView>)adView {
    [ATLogger logMessage:@"NendBanner::nadViewDidClickAd:" type:ATLogTypeExternal];
    [self trackBannerAdClick];
}

- (void)nadViewDidClickInformation:(id<ATNADView>)adView {
    [ATLogger logMessage:@"NendBanner::nadViewDidClickInformation:" type:ATLogTypeExternal];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"spot_id"];
}

/// This is an override method, for more detailsplease refer to ATBannerCustomEvent.h
- (BOOL)sendImpressionTrackingIfNeed {
    return YES;
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.banner.unitGroup.content[@"spot_id"];
//    return extra;
//}
@end
