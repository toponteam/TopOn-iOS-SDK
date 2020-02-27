//
//  ATFlurryBannerCustomEvent.m
//  AnyThinkFlurryBannerAdapter
//
//  Created by Martin Lau on 2018/10/8.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATFlurryBannerCustomEvent.h"
#import "Utilities.h"
#import "ATBannerManager.h"

@implementation ATFlurryBannerCustomEvent
- (void) adBannerDidFetchAd:(id<ATFlurryAdBanner>)bannerAd {
    [ATLogger logMessage:@"FlurryBanner::adBannerDidFetchAd:" type:ATLogTypeExternal];
    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:bannerAd, kBannerAssetsBannerViewKey, self, kBannerAssetsCustomEventKey, nil];
    if ([self.unitID length] > 0) assets[kBannerAssetsUnitIDKey] = self.unitID;
    [self handleAssets:assets];
}

- (void) adBannerDidRender:(id<ATFlurryAdBanner>)bannerAd {
    [ATLogger logMessage:@"FlurryBanner::adBannerDidRender:" type:ATLogTypeExternal];
}

- (void) adBannerWillPresentFullscreen:(id<ATFlurryAdBanner>)bannerAd {
    [ATLogger logMessage:@"FlurryBanner::adBannerWillPresentFullscreen:" type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (self.banner.requestID != nil) { userInfo[kBannerNotificationUserInfoRequestIDKey] = self.banner.requestID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kBannerPresentModalViewControllerNotification object:nil userInfo:userInfo];
}

- (void) adBannerWillLeaveApplication:(id<ATFlurryAdBanner>)bannerAd {
    [ATLogger logMessage:@"FlurryBanner::adBannerWillLeaveApplication:" type:ATLogTypeExternal];
}

- (void) adBannerWillDismissFullscreen:(id<ATFlurryAdBanner>)bannerAd {
    [ATLogger logMessage:@"FlurryBanner::adBannerWillDismissFullscreen:" type:ATLogTypeExternal];
}

- (void) adBannerDidDismissFullscreen:(id<ATFlurryAdBanner>)bannerAd {
    [ATLogger logMessage:@"FlurryBanner::adBannerDidDismissFullscreen:" type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (self.banner.requestID != nil) { userInfo[kBannerNotificationUserInfoRequestIDKey] = self.banner.requestID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kBannerDismissModalViewControllerNotification object:nil userInfo:userInfo];
}

- (void) adBannerDidReceiveClick:(id<ATFlurryAdBanner>)bannerAd {
    [ATLogger logMessage:@"FlurryBanner::adBannerDidReceiveClick:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(bannerView:didClickWithPlacementID: extra:)]) {
        [self.delegate bannerView:self.bannerView didClickWithPlacementID:self.banner.placementModel.placementID extra:@{kATBannerDelegateExtraNetworkIDKey:@(self.banner.unitGroup.networkFirmID), kATBannerDelegateExtraAdSourceIDKey:self.banner.unitGroup.unitID != nil ? self.banner.unitGroup.unitID : @"",kATBannerDelegateExtraIsHeaderBidding:@(self.banner.unitGroup.headerBidding),kATBannerDelegateExtraPriority:@(self.priorityIndex),kATBannerDelegateExtraPrice:@(self.banner.unitGroup.price)}];
    }
}

- (void) adBannerVideoDidFinish:(id<ATFlurryAdBanner>)bannerAd {
    [ATLogger logMessage:@"FlurryBanner::adBannerVideoDidFinish:" type:ATLogTypeExternal];
}

- (void) adBanner:(id<ATFlurryAdBanner>) bannerAd adError:(NSInteger) adError errorDescription:(NSError*) errorDescription {
    [ATLogger logMessage:[NSString stringWithFormat:@"FlurryBanner::adBanner: adError:%ld, errorDescription:%@", adError, errorDescription] type:ATLogTypeExternal];
    if (adError == 1) {[self handleLoadingFailure:errorDescription];}// Failed to fetch ad
}
@end
