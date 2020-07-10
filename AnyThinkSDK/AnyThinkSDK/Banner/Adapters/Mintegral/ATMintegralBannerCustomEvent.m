//
//  ATMintegralBannerCustomEvent.m
//  AnyThinkMintegralBannerAdapter
//
//  Created by Topon on 2019/11/15.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import "ATMintegralBannerCustomEvent.h"
#import "Utilities.h"
#import "ATBannerManager.h"
#import "ATAgentEvent.h"
#import "ATBannerView+Internal.h"

@implementation ATMintegralBannerCustomEvent
- (void)adViewLoadSuccess:(id<ATMTGBannerAdView>)adView {
    [ATLogger logMessage:@"MTGBanner::bannerAdViewDidLoad:" type:ATLogTypeExternal];
    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:adView, kBannerAssetsBannerViewKey, self, kBannerAssetsCustomEventKey, nil];
    if ([self.unitID length] > 0) assets[kBannerAssetsUnitIDKey] = self.unitID;
    [self handleAssets:assets];
}

- (void)adViewLoadFailedWithError:(NSError *)error adView:(id<ATMTGBannerAdView>)adView {
    [ATLogger logMessage:[NSString stringWithFormat:@"MTGBanner::banner:adViewLoadFailedWithError:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (void)adViewWillLogImpression:(id<ATMTGBannerAdView>)adView {
    [ATLogger logMessage:@"MTGBanner::adViewWillLogImpression:" type:ATLogTypeExternal];

}

- (void)adViewDidClicked:(id<ATMTGBannerAdView>)adView {
    [ATLogger logMessage:@"MTGBanner::adViewDidClicked:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(bannerView:didClickWithPlacementID: extra:)]) {
        [self.delegate bannerView:self.bannerView didClickWithPlacementID:self.banner.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)adViewWillLeaveApplication:(id<ATMTGBannerAdView>)adView {
    [ATLogger logMessage:@"MTGBanner::adViewWillLeaveApplication" type:ATLogTypeExternal];

}

- (void)adViewWillOpenFullScreen:(id<ATMTGBannerAdView>)adView {
    [ATLogger logMessage:@"MTGBanner::adViewWillOpenFullScreen" type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (self.banner.requestID != nil) { userInfo[kBannerNotificationUserInfoRequestIDKey] = self.banner.requestID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kBannerPresentModalViewControllerNotification object:nil userInfo:userInfo];
}

- (void)adViewCloseFullScreen:(id<ATMTGBannerAdView>)adView {
    [ATLogger logMessage:@"MTGBanner::adViewCloseFullScreen" type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (self.banner.requestID != nil) { userInfo[kBannerNotificationUserInfoRequestIDKey] = self.banner.requestID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kBannerDismissModalViewControllerNotification object:nil userInfo:userInfo];
}

- (void)adViewClosed:(id<ATMTGBannerAdView>)adView {
    [ATLogger logMessage:@"MTGBanner::adViewClosed:" type:ATLogTypeExternal];
    [self.bannerView loadNextWithoutRefresh];
    if ([self.delegate respondsToSelector:@selector(bannerView:didTapCloseButtonWithPlacementID:extra:)]) {
        [self.delegate bannerView:self.bannerView didTapCloseButtonWithPlacementID:self.banner.placementModel.placementID extra:[self delegateExtra]];
    }
    [self handleClose];
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.banner.unitGroup.content[@"unitid"];
    return extra;
}
@end
