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
- (UIViewController *)viewControllerForPresentingModalView {
    [ATLogger logMessage:@"MopubBanner::viewControllerForPresentingModalView" type:ATLogTypeExternal];
    return self.rootViewController;
}

- (void)adViewDidLoadAd:(id<ATMPAdView>)view {
    [ATLogger logMessage:@"MopubBanner::adViewDidLoadAd:" type:ATLogTypeExternal];
    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:view, kBannerAssetsBannerViewKey, self, kBannerAssetsCustomEventKey, nil];
    if ([self.unitID length] > 0) assets[kBannerAssetsUnitIDKey] = self.unitID;
    [self handleAssets:assets];
}

- (void)adViewDidFailToLoadAd:(id<ATMPAdView>)view {
    [ATLogger logMessage:@"MopubBanner::adViewDidFailToLoadAd:" type:ATLogTypeExternal];
    [self handleLoadingFailure:[NSError errorWithDomain:@"com.anythink.MopubBannerr" code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"ATSDK has failed to load banner.", NSLocalizedFailureReasonErrorKey:@"Mopub has failed to load banner."}]];
}

- (void)willPresentModalViewForAd:(id<ATMPAdView>)view {
    [ATLogger logMessage:@"MopubBanner::willPresentModalViewForAd:" type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (self.banner.requestID != nil) { userInfo[kBannerNotificationUserInfoRequestIDKey] = self.banner.requestID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kBannerPresentModalViewControllerNotification object:nil userInfo:userInfo];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(bannerView:didClickWithPlacementID: extra:)]) {
        [self.delegate bannerView:self.bannerView didClickWithPlacementID:self.banner.placementModel.placementID extra:@{kATBannerDelegateExtraNetworkIDKey:@(self.banner.unitGroup.networkFirmID), kATBannerDelegateExtraAdSourceIDKey:self.banner.unitGroup.unitID != nil ? self.banner.unitGroup.unitID : @"",kATBannerDelegateExtraIsHeaderBidding:@(self.banner.unitGroup.headerBidding),kATBannerDelegateExtraPriority:@(self.priorityIndex),kATBannerDelegateExtraPrice:@(self.banner.unitGroup.price)}];
    }
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
@end
