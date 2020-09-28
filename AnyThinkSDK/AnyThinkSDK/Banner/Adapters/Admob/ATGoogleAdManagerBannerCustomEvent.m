//
//  ATGoogleAdManagerBannerCustomEvent.m
//  AnyThinkSDK
//
//  Created by stephen on 7/27/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATGoogleAdManagerBannerCustomEvent.h"
#import "Utilities.h"
#import "ATBannerManager.h"
#import "ATAd.h"
#import "ATPlacementModel.h"
#import "AnyThinkBanner.h"
#import "ATAgentEvent.h"

@implementation ATGoogleAdManagerBannerCustomEvent
- (void)adViewDidReceiveAd:(id<ATDFPBannerView>)bannerView {
    [ATLogger logMessage:@"GoogleAdManagerBanner::adViewDidReceiveAd:" type:ATLogTypeExternal];
    [self trackBannerAdLoaded:bannerView adExtra:nil];
}

- (void)adView:(id<ATDFPBannerView>)bannerView didFailToReceiveAdWithError:(NSError*)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"ADMobBanner::adView:didFailToReceiveAdWithError:%@", error] type:ATLogTypeExternal];
    [self trackBannerAdLoadFailed:error];
}

- (void)adViewWillPresentScreen:(id<ATDFPBannerView>)bannerView {
    [ATLogger logMessage:@"GoogleAdManagerBanner::adViewWillPresentScreen:" type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (self.banner.requestID != nil) { userInfo[kBannerNotificationUserInfoRequestIDKey] = self.banner.requestID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kBannerPresentModalViewControllerNotification object:nil userInfo:userInfo];
    [self trackBannerAdClick];
}

- (void)adViewWillDismissScreen:(id<ATDFPBannerView>)bannerView {
    [ATLogger logMessage:@"GoogleAdManagerBanner::adViewWillDismissScreen:" type:ATLogTypeExternal];
}

- (void)adViewDidDismissScreen:(id<ATDFPBannerView>)bannerView {
    [ATLogger logMessage:@"GoogleAdManagerBanner::adViewDidDismissScreen:" type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (self.banner.requestID != nil) { userInfo[kBannerNotificationUserInfoRequestIDKey] = self.banner.requestID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kBannerDismissModalViewControllerNotification object:nil userInfo:userInfo];
}

- (void)adViewWillLeaveApplication:(id<ATDFPBannerView>)bannerView {
    [ATLogger logMessage:@"GoogleAdManagerBanner::adViewWillLeaveApplication:" type:ATLogTypeExternal];
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
