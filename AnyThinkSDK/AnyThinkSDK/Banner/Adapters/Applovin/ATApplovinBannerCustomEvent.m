//
//  ATApplovinBannerCustomEvent.m
//  AnyThinkApplovinBannerAdapter
//
//  Created by Martin Lau on 20/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATApplovinBannerCustomEvent.h"
#import "Utilities.h"
#import "ATBannerManager.h"
#import "ATBanner.h"
#import "ATPlacementModel.h"
#import "ATBannerView.h"
#import "ATBannerView+Internal.h"

@interface ATApplovinBannerCustomEvent()
@property(nonatomic, readonly) NSString *sdkKey;
@property(nonatomic, readonly) CGSize alSize;
@end
@implementation ATApplovinBannerCustomEvent
-(instancetype) initWithUnitID:(NSString *)unitID customInfo:(NSDictionary *)customInfo sdkKey:(NSString*)sdkKey alSize:(CGSize)alSize{
    self = [super initWithUnitID:unitID customInfo:customInfo];
    if (self != nil) {
        _sdkKey = sdkKey;
        _alSize = alSize;
    }
    return self;
}

- (void)adService:(id<ATALAdService>)adService didLoadAd:(id<ATALAd>)ad {
    [ATLogger logMessage:@"ApplovinBanner::adService:didLoadAd:" type:ATLogTypeExternal];
    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:_alAdView, kBannerAssetsBannerViewKey, self, kBannerAssetsCustomEventKey, ad, kAdAssetsCustomObjectKey, nil];
    if ([self.unitID length] > 0) assets[kBannerAssetsUnitIDKey] = self.unitID;
    [self handleAssets:assets];
}

- (void)adService:(id<ATALAdService>)adService didFailToLoadAdWithError:(int)code {
    [ATLogger logMessage:[NSString stringWithFormat:@"ApplovinBanner::adService:didFailToLoadAdWithError:%d", code] type:ATLogTypeExternal];
    [self handleLoadingFailure:[NSError errorWithDomain:@"com.anythink.ApplovinBannerr" code:code userInfo:@{NSLocalizedDescriptionKey:@"ATSDK has failed to load banner.", NSLocalizedFailureReasonErrorKey:@"Applovin has failed to load banner."}]];
}

- (void)ad:(id<ATALAd>)ad wasDisplayedIn:(UIView *)view {
    [ATLogger logMessage:@"ApplovinBanner::ad:wasDisplayedIn:" type:ATLogTypeExternal];
}

- (void)ad:(id<ATALAd>)ad wasHiddenIn:(UIView *)view {
    [ATLogger logMessage:@"ApplovinBanner::ad:wasHiddenIn:" type:ATLogTypeExternal];
    [self.bannerView loadNextWithoutRefresh];
    [self handleClose];
}

- (void)ad:(id<ATALAd>)ad wasClickedIn:(UIView *)view {
    [ATLogger logMessage:@"ApplovinBanner::ad:wasClickedIn:" type:ATLogTypeExternal];
}

- (void)ad:(id<ATALAd>)ad didPresentFullscreenForAdView:(id<ATALAdView>)adView {
    [ATLogger logMessage:@"ApplovinBanner::ad:didPresentFullscreenForAdView:" type:ATLogTypeExternal];
}

- (void)ad:(id<ATALAd>)ad willDismissFullscreenForAdView:(id<ATALAdView>)adView {
    [ATLogger logMessage:@"ApplovinBanner::ad:willDismissFullscreenForAdView:" type:ATLogTypeExternal];
}

- (void)ad:(id<ATALAd>)ad didDismissFullscreenForAdView:(id<ATALAdView>)adView {
    [ATLogger logMessage:@"ApplovinBanner::ad:didDismissFullscreenForAdView:" type:ATLogTypeExternal];
}

- (void)ad:(id<ATALAd>)ad willLeaveApplicationForAdView:(id<ATALAdView>)adView {
    [ATLogger logMessage:@"ApplovinBanner::ad:willLeaveApplicationForAdView:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(bannerView:didClickWithPlacementID: extra:)]) {
        [self.delegate bannerView:self.bannerView didClickWithPlacementID:self.banner.placementModel.placementID extra:@{kATBannerDelegateExtraNetworkIDKey:@(self.banner.unitGroup.networkFirmID), kATBannerDelegateExtraAdSourceIDKey:self.banner.unitGroup.unitID != nil ? self.banner.unitGroup.unitID : @"",kATBannerDelegateExtraIsHeaderBidding:@(self.banner.unitGroup.headerBidding),kATBannerDelegateExtraPriority:@(self.priorityIndex),kATBannerDelegateExtraPrice:@(self.banner.unitGroup.price)}];
    }
}

- (void)ad:(id<ATALAd>)ad didReturnToApplicationForAdView:(id<ATALAdView>)adView {
    [ATLogger logMessage:@"ApplovinBanner::ad:didReturnToApplicationForAdView:" type:ATLogTypeExternal];
}

- (void)ad:(id<ATALAd>)ad didFailToDisplayInAdView:(id<ATALAdView>)adView withError:(ATALAdViewDisplayErrorCode)code {
    [ATLogger logMessage:[NSString stringWithFormat:@"ApplovinBanner::ad:didFailToDisplayInAdView:withError:%d", (int)code] type:ATLogTypeExternal];
}
@end
