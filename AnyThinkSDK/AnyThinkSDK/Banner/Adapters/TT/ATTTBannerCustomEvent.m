//
//  ATTTBannerCustomEvent.m
//  AnyThinkTTBannerAdapter
//
//  Created by Martin Lau on 20/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATTTBannerCustomEvent.h"
#import "Utilities.h"
#import "ATBannerManager.h"
#import "ATAgentEvent.h"
#import "ATBannerView+Internal.h"

@implementation ATTTBannerCustomEvent
- (void)bannerAdViewDidLoad:(id<ATBUBannerAdView>)bannerAdView WithAdmodel:(id<ATBUNativeAd>)nativeAd {
    [ATLogger logMessage:@"TTBanner::bannerAdViewDidLoad:WithAdmodel:" type:ATLogTypeExternal];
    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:bannerAdView, kBannerAssetsBannerViewKey, self, kBannerAssetsCustomEventKey, nil];
    if ([self.unitID length] > 0) assets[kBannerAssetsUnitIDKey] = self.unitID;
//    [self handleAssets:assets];
    [self trackBannerAdLoaded:bannerAdView adExtra:assets];
}

- (void)bannerAdViewDidBecomVisible:(id<ATBUBannerAdView>)bannerAdView WithAdmodel:(id<ATBUNativeAd>)nativeAd {
    [ATLogger logMessage:@"TTBanner::bannerAdViewDidBecomVisible:WithAdmodel:" type:ATLogTypeExternal];
}

- (void)bannerAdViewDidClick:(id<ATBUBannerAdView>)bannerAdView WithAdmodel:(id<ATBUNativeAd>)nativeAd {
    [ATLogger logMessage:@"TTBanner::bannerAdViewDidClick:WithAdmodel:" type:ATLogTypeExternal];
    [self trackBannerAdClick];
}

- (void)bannerAdView:(id<ATBUBannerAdView>)bannerAdView didLoadFailWithError:(NSError *_Nullable)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"TTBanner::bannerAdView:didLoadFailWithError:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (void)bannerAdView:(id<ATBUBannerAdView>)bannerAdView dislikeWithReason:(NSArray *_Nullable)filterwords {
    [ATLogger logMessage:@"TTBanner::bannerAdView:dislikeWithReason:" type:ATLogTypeExternal];
    [self.bannerView loadNextWithoutRefresh];
    [self trackBannerAdClosed];
}

#pragma mark - express banner view delegate
- (void)nativeExpressBannerAdViewDidLoad:(id<ATBUNativeExpressBannerView>)bannerAdView {
    [ATLogger logMessage:@"TTBanner::nativeExpressBannerAdViewDidLoad:" type:ATLogTypeExternal];
}

- (void)nativeExpressBannerAdView:(id<ATBUNativeExpressBannerView>)bannerAdView didLoadFailWithError:(NSError *_Nullable)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"TTBanner::nativeExpressBannerAdView:didLoadFailWithError:%@", error] type:ATLogTypeExternal];
    if (!_isFailed) {
        [self handleLoadingFailure:error];
        _isFailed = true;
    }
}

- (void)nativeExpressBannerAdViewRenderSuccess:(id<ATBUNativeExpressBannerView>)bannerAdView {
    [ATLogger logMessage:@"TTBanner::nativeExpressBannerAdViewRenderSuccess:" type:ATLogTypeExternal];

    [self trackBannerAdLoaded:bannerAdView adExtra:nil];
}

- (void)nativeExpressBannerAdViewRenderFail:(id<ATBUNativeExpressBannerView>)bannerAdView error:(NSError * __nullable)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"TTBanner::nativeExpressBannerAdViewRenderFail:error:%@", error] type:ATLogTypeExternal];
    if (!_isFailed) {
        [self trackBannerAdLoadFailed:error];
        _isFailed = true;
    }
}

- (void)nativeExpressBannerAdViewWillBecomVisible:(id<ATBUNativeExpressBannerView>)bannerAdView {
    [ATLogger logMessage:@"TTBanner::nativeExpressBannerAdViewWillBecomVisible:" type:ATLogTypeExternal];
}

- (void)nativeExpressBannerAdViewDidClick:(id<ATBUNativeExpressBannerView>)bannerAdView {
    [ATLogger logMessage:@"TTBanner::nativeExpressBannerAdViewDidClick:" type:ATLogTypeExternal];
    [self trackBannerAdClick];
}

- (void)nativeExpressBannerAdView:(id<ATBUNativeExpressBannerView>)bannerAdView dislikeWithReason:(NSArray *_Nullable)filterwords {
    [ATLogger logMessage:@"TTBanner::nativeExpressBannerAdView:dislikeWithReason:" type:ATLogTypeExternal];
    [self.bannerView loadNextWithoutRefresh];
//    if ([self.delegate respondsToSelector:@selector(bannerView:didTapCloseButtonWithPlacementID:extra:)]) {
//        [self.delegate bannerView:self.bannerView didTapCloseButtonWithPlacementID:self.banner.placementModel.placementID extra:[self delegateExtra]];
//    }
    [self trackBannerAdClosed];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.banner.unitGroup.content[@"slot_id"];
//    return extra;
//}
@end
