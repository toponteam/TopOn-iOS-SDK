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
    [self handleAssets:@{kBannerAssetsBannerViewKey:adView, kBannerAssetsCustomEventKey:self, kBannerAssetsUnitIDKey:self.unitID}];
}

- (void)nadViewDidFailToReceiveAd:(id<ATNADView>)adView {
    [ATLogger logMessage:@"NendBanner::nadViewDidFailToReceiveAd:" type:ATLogTypeExternal];
    [self handleLoadingFailure:[NSError errorWithDomain:@"com.anythink.NendBannerLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load banner", NSLocalizedFailureReasonErrorKey:@"NendBanner has failed to load banner ad"}]];
}

- (void)nadViewDidClickAd:(id<ATNADView>)adView {
    [ATLogger logMessage:@"NendBanner::nadViewDidClickAd:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(bannerView:didClickWithPlacementID: extra:)]) {
        [self.delegate bannerView:self.bannerView didClickWithPlacementID:self.banner.placementModel.placementID extra:@{kATBannerDelegateExtraNetworkIDKey:@(self.banner.unitGroup.networkFirmID), kATBannerDelegateExtraAdSourceIDKey:self.banner.unitGroup.unitID != nil ? self.banner.unitGroup.unitID : @"",kATBannerDelegateExtraIsHeaderBidding:@(self.banner.unitGroup.headerBidding),kATBannerDelegateExtraPriority:@(self.priorityIndex),kATBannerDelegateExtraPrice:@(self.banner.unitGroup.price)}];
    }
}

- (void)nadViewDidClickInformation:(id<ATNADView>)adView {
    [ATLogger logMessage:@"NendBanner::nadViewDidClickInformation:" type:ATLogTypeExternal];
}
@end
