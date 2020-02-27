//
//  ATBaiduBannerCustomEvent.m
//  AnyThinkBaiduBannerAdapter
//
//  Created by Martin Lau on 2018/11/30.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATBaiduBannerCustomEvent.h"
#import "Utilities.h"
#import "ATBannerManager.h"
#import "ATBannerView+Internal.h"
@interface ATBaiduBannerCustomEvent()
@property(nonatomic, readonly) id baiduBannerView;
@property(nonatomic, readonly) NSString *appID;
@property(nonatomic, readonly) BOOL impressed;
@end
@implementation ATBaiduBannerCustomEvent
-(instancetype) initWithUnitID:(NSString*)unitID customInfo:(NSDictionary*)customInfo bannerView:(id)bannerView {
    self = [super initWithUnitID:unitID customInfo:customInfo];
    if (self != nil) {
        _baiduBannerView = bannerView;
        _appID = customInfo[@"app_id"];
    }
    return self;
}

- (NSString *)publisherId {
    [ATLogger logMessage:@"BaiduBanner::publisherId" type:ATLogTypeExternal];
    return _appID;
}

- (BOOL)enableLocation {
    [ATLogger logMessage:@"BaiduBanner::enableLocation" type:ATLogTypeExternal];
    return NO;
}

- (void)willDisplayAd:(id<ATBaiduMobAdView>)adview {
    [ATLogger logMessage:@"BaiduBanner::willDisplayAd:" type:ATLogTypeExternal];
}

- (void)failedDisplayAd:(NSInteger)reason {
    [ATLogger logMessage:[NSString stringWithFormat:@"BaiduBanner::failedDisplayAd:%ld", (long)reason] type:ATLogTypeExternal];
    [self handleLoadingFailure:[NSError errorWithDomain:@"com.anythink.BaiduBanner" code:reason userInfo:@{NSLocalizedDescriptionKey:@"ATSDK has failed to load banner.", NSLocalizedFailureReasonErrorKey:@"BaiduSDK has failed to load banner."}]];
}

- (void)didAdImpressed {
    [ATLogger logMessage:@"BaiduBanner::didAdImpressed" type:ATLogTypeExternal];
    if (!_impressed) {
        _impressed = YES;
        NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:_baiduBannerView, kBannerAssetsBannerViewKey, self, kBannerAssetsCustomEventKey, nil];
        if ([self.unitID length] > 0) assets[kBannerAssetsUnitIDKey] = self.unitID;
        [self handleAssets:assets];
    }
}

- (void)didAdClicked {
    [ATLogger logMessage:@"BaiduBanner::didAdClicked" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(bannerView:didClickWithPlacementID: extra:)]) {
        [self.delegate bannerView:self.bannerView didClickWithPlacementID:self.banner.placementModel.placementID extra:@{kATBannerDelegateExtraNetworkIDKey:@(self.banner.unitGroup.networkFirmID), kATBannerDelegateExtraAdSourceIDKey:self.banner.unitGroup.unitID != nil ? self.banner.unitGroup.unitID : @"",kATBannerDelegateExtraIsHeaderBidding:@(self.banner.unitGroup.headerBidding),kATBannerDelegateExtraPriority:@(self.priorityIndex),kATBannerDelegateExtraPrice:@(self.banner.unitGroup.price)}];
    }
}

- (void)didDismissLandingPage {
    [ATLogger logMessage:@"BaiduBanner::didDismissLandingPage" type:ATLogTypeExternal];
}

- (void)didAdClose {
    [ATLogger logMessage:@"BaiduBanner::didAdClose" type:ATLogTypeExternal];
    [self.bannerView loadNextWithoutRefresh];
    if ([self.delegate respondsToSelector:@selector(bannerView:didTapCloseButtonWithPlacementID:extra:)]) {
        [self.delegate bannerView:self.bannerView didTapCloseButtonWithPlacementID:self.banner.placementModel.placementID extra:@{kATBannerDelegateExtraNetworkIDKey:@(self.banner.unitGroup.networkFirmID), kATBannerDelegateExtraAdSourceIDKey:self.banner.unitGroup.unitID != nil ? self.banner.unitGroup.unitID : @"",kATBannerDelegateExtraIsHeaderBidding:@(self.banner.unitGroup.headerBidding),kATBannerDelegateExtraPriority:@(self.priorityIndex),kATBannerDelegateExtraPrice:@(self.banner.unitGroup.price)}];
    }
    [self handleClose];
}
@end
