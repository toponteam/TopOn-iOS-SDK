//
//  ATAppnextBannerCustomEvent.m
//  AnyThinkAppnextBannerAdapter
//
//  Created by Martin Lau on 2018/10/15.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAppnextBannerCustomEvent.h"
#import "Utilities.h"
#import "ATBannerManager.h"

@implementation ATAppnextBannerCustomEvent
- (void) onAppnextBannerLoadedSuccessfully {
    [ATLogger logMessage:@"AppnextBanner::onAppnextBannerLoadedSuccessfully" type:ATLogTypeExternal];
    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:_anBannerView, kBannerAssetsBannerViewKey, self, kBannerAssetsCustomEventKey, nil];
    if ([self.unitID length] > 0) assets[kBannerAssetsUnitIDKey] = self.unitID;
    [self handleAssets:assets];
}

- (void) onAppnextBannerError:(NSInteger) error {
    [ATLogger logMessage:[NSString stringWithFormat:@"AppnextBanner::onAppnextBannerError:%ld", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:[NSError errorWithDomain:@"com.anythink.AppnextBanner" code:error userInfo:@{NSLocalizedDescriptionKey:@"ATSDK has failed to load banner.", NSLocalizedFailureReasonErrorKey:@"Appnext has failed to load banner."}]];
}

- (void) onAppnextBannerClicked {
    [ATLogger logMessage:@"AppnextBanner::onAppnextBannerClicked" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(bannerView:didClickWithPlacementID: extra:)]) {
        [self.delegate bannerView:self.bannerView didClickWithPlacementID:self.banner.placementModel.placementID extra:@{kATBannerDelegateExtraNetworkIDKey:@(self.banner.unitGroup.networkFirmID), kATBannerDelegateExtraAdSourceIDKey:self.banner.unitGroup.unitID != nil ? self.banner.unitGroup.unitID : @"",kATBannerDelegateExtraIsHeaderBidding:@(self.banner.unitGroup.headerBidding),kATBannerDelegateExtraPriority:@(self.priorityIndex),kATBannerDelegateExtraPrice:@(self.banner.unitGroup.price)}];
    }
}

- (void) onAppnextBannerImpressionReported {
    [ATLogger logMessage:@"AppnextBanner::onAppnextBannerImpressionReported" type:ATLogTypeExternal];
}
@end
