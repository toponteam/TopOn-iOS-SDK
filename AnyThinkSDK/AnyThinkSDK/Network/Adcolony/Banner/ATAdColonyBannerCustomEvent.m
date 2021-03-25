//
//  ATAdColonyBannerCustomEvent.m
//  AnyThinkAdColonyBannerAdapter
//
//  Created by Martin Lau on 2020/6/10.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATAdColonyBannerCustomEvent.h"
#import "ATLogger.h"
#import "ATBannerManager.h"

@implementation ATAdColonyBannerCustomEvent
- (void)adColonyAdViewDidLoad:(id<ATAdColonyAdView>)adView {
    [ATLogger logMessage:@"AdColonyBanner::adColonyAdViewDidLoad:" type:ATLogTypeExternal];
    [self trackBannerAdLoaded:adView adExtra:nil];
}

- (void)adColonyAdViewDidFailToLoad:(NSError*)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"AdColonyBanner::adColonyAdViewDidFailToLoad:%@", error] type:ATLogTypeExternal];
    [self trackBannerAdLoadFailed:error];
}

- (void)adColonyAdViewWillLeaveApplication:(id<ATAdColonyAdView>)adView { [ATLogger logMessage:@"AdColonyBanner::adColonyAdViewWillLeaveApplication:" type:ATLogTypeExternal]; }

- (void)adColonyAdViewWillOpen:(id<ATAdColonyAdView>)adView {
    [ATLogger logMessage:@"AdColonyBanner::adColonyAdViewWillOpen:" type:ATLogTypeExternal];
}

/// This is an override method, for more detailsplease refer to ATBannerCustomEvent.h
- (BOOL)sendImpressionTrackingIfNeed {
    return YES;
}
- (void)adColonyAdViewDidClose:(id<ATAdColonyAdView>)adView { [ATLogger logMessage:@"AdColonyBanner::adColonyAdViewDidClose:" type:ATLogTypeExternal]; }

- (void)adColonyAdViewDidReceiveClick:(id<ATAdColonyAdView>)adView {
    [ATLogger logMessage:@"AdColonyBanner::adColonyAdViewDidReceiveClick:" type:ATLogTypeExternal];
    [self trackBannerAdClick];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"zone_id"];
}
//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.banner.unitGroup.content[@"unitid"];
//    return extra;
//}
@end
