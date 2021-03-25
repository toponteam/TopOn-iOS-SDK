//
//  ATMopubBannerCustomEvent.m
//  AnyThinkMopubBannerAdapter
//
//  Created by Martin Lau on 30/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMopubBannerCustomEvent.h"
#import "Utilities.h"
#import "ATBannerManager.h"
#import "ATAPI.h"

@implementation ATMopubBannerCustomEvent

/// This is an override method, for more detailsplease refer to ATBannerCustomEvent.h
- (BOOL)sendImpressionTrackingIfNeed {
    return YES;
}

- (UIViewController *)viewControllerForPresentingModalView {
    [ATLogger logMessage:@"MopubBanner::viewControllerForPresentingModalView" type:ATLogTypeExternal];
    return self.rootViewController;
}

- (void)adViewDidLoadAd:(id<ATMPAdView>)view {
    [ATLogger logMessage:@"MopubBanner::adViewDidLoadAd:" type:ATLogTypeExternal];

    [self trackBannerAdLoaded:view adExtra:nil];
}

- (void)adViewDidFailToLoadAd:(id<ATMPAdView>)view {
    [ATLogger logMessage:@"MopubBanner::adViewDidFailToLoadAd:" type:ATLogTypeExternal];
    [self trackBannerAdLoadFailed:[NSError errorWithDomain:@"com.anythink.MopubBannerr" code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:@"Mopub has failed to load banner."}]];
}

- (void)willPresentModalViewForAd:(id<ATMPAdView>)view {
    [ATLogger logMessage:@"MopubBanner::willPresentModalViewForAd:" type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (self.banner.requestID != nil) { userInfo[kBannerNotificationUserInfoRequestIDKey] = self.banner.requestID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kBannerPresentModalViewControllerNotification object:nil userInfo:userInfo];
    [self trackBannerAdClick];
}

- (void)didDismissModalViewForAd:(id<ATMPAdView>)view {
    [ATLogger logMessage:@"MopubBanner::didDismissModalViewForAd:" type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (self.banner.requestID != nil) { userInfo[kBannerNotificationUserInfoRequestIDKey] = self.banner.requestID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kBannerDismissModalViewControllerNotification object:nil userInfo:userInfo];
}

- (void)willLeaveApplicationFromAd:(id<ATMPAdView>)view {
    [ATLogger logMessage:@"MopubBanner::willLeaveApplicationFromAd:" type:ATLogTypeExternal];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"unitid"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.banner.unitGroup.content[@"unitid"];
//    return extra;
//}
@end
