//
//  ATAdmobBannerCustomEvent.m
//  AnyThinkAdmobBannerAdapter
//
//  Created by Martin Lau on 19/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdmobBannerCustomEvent.h"
#import "Utilities.h"
#import "ATBannerManager.h"
#import "ATAd.h"
#import "ATPlacementModel.h"
#import "AnyThinkBanner.h"
#import "ATAgentEvent.h"

@implementation ATAdmobBannerCustomEvent
- (void)adViewDidReceiveAd:(id<ATGADBannerView>)bannerView {
    [ATLogger logMessage:@"ADMobBanner::adViewDidReceiveAd:" type:ATLogTypeExternal];
    [self trackBannerAdLoaded:bannerView adExtra:nil];
}

- (void)adView:(id<ATGADBannerView>)bannerView didFailToReceiveAdWithError:(NSError*)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"ADMobBanner::adView:didFailToReceiveAdWithError:%@", error] type:ATLogTypeExternal];
    [self trackBannerAdLoadFailed:error];
}

- (void)adViewWillPresentScreen:(id<ATGADBannerView>)bannerView {
    [ATLogger logMessage:@"ADMobBanner::adViewWillPresentScreen:" type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (self.banner.requestID != nil) { userInfo[kBannerNotificationUserInfoRequestIDKey] = self.banner.requestID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kBannerPresentModalViewControllerNotification object:nil userInfo:userInfo];
    [self trackBannerAdClick];
}

- (void)adViewWillDismissScreen:(id<ATGADBannerView>)bannerView {
    [ATLogger logMessage:@"ADMobBanner::adViewWillDismissScreen:" type:ATLogTypeExternal];
}

- (void)adViewDidDismissScreen:(id<ATGADBannerView>)bannerView {
    [ATLogger logMessage:@"ADMobBanner::adViewDidDismissScreen:" type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (self.banner.requestID != nil) { userInfo[kBannerNotificationUserInfoRequestIDKey] = self.banner.requestID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kBannerDismissModalViewControllerNotification object:nil userInfo:userInfo];
}

- (void)adViewWillLeaveApplication:(id<ATGADBannerView>)bannerView {
    [ATLogger logMessage:@"ADMobBanner::adViewWillLeaveApplication:" type:ATLogTypeExternal];
    [self trackBannerAdClick];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"unit_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.banner.unitGroup.content[@"unit_id"];
//    return extra;
//}
@end
