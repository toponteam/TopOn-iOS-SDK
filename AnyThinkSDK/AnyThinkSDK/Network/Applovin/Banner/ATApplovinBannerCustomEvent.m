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
-(instancetype) initWithUnitID:(NSString *)unitID serverInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo sdkKey:(NSString*)sdkKey alSize:(CGSize)alSize{
    self = [super initWithInfo:serverInfo localInfo:localInfo];
    if (self != nil) {
        _sdkKey = sdkKey;
        _alSize = alSize;
    }
    return self;
}

- (void)adService:(id<ATALAdService>)adService didLoadAd:(id<ATALAd>)ad {
    [ATLogger logMessage:@"ApplovinBanner::adService:didLoadAd:" type:ATLogTypeExternal];
    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:ad, kAdAssetsCustomObjectKey, nil];
    [self trackBannerAdLoaded:_alAdView adExtra:assets];
}

- (void)adService:(id<ATALAdService>)adService didFailToLoadAdWithError:(int)code {
    [ATLogger logMessage:[NSString stringWithFormat:@"ApplovinBanner::adService:didFailToLoadAdWithError:%d", code] type:ATLogTypeExternal];
    [self trackBannerAdLoadFailed:[NSError errorWithDomain:@"com.anythink.ApplovinBannerr" code:code userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:@"Applovin has failed to load banner."}]];
}

- (void)ad:(id<ATALAd>)ad wasDisplayedIn:(UIView *)view {
    [ATLogger logMessage:@"ApplovinBanner::ad:wasDisplayedIn:" type:ATLogTypeExternal];
    [self trackBannerAdImpression];
}

- (void)ad:(id<ATALAd>)ad wasHiddenIn:(UIView *)view {
    [ATLogger logMessage:@"ApplovinBanner::ad:wasHiddenIn:" type:ATLogTypeExternal];
    [self.bannerView loadNextWithoutRefresh];
    [self trackBannerAdClosed];
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
    [self trackBannerAdClick];
}

- (void)ad:(id<ATALAd>)ad didReturnToApplicationForAdView:(id<ATALAdView>)adView {
    [ATLogger logMessage:@"ApplovinBanner::ad:didReturnToApplicationForAdView:" type:ATLogTypeExternal];
}

- (void)ad:(id<ATALAd>)ad didFailToDisplayInAdView:(id<ATALAdView>)adView withError:(ATALAdViewDisplayErrorCode)code {
    [ATLogger logMessage:[NSString stringWithFormat:@"ApplovinBanner::ad:didFailToDisplayInAdView:withError:%d", (int)code] type:ATLogTypeExternal];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"zone_id"] != nil ? self.serverInfo[@"zone_id"] : @"";
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.banner.unitGroup.content[@"zone_id"] != nil ? self.banner.unitGroup.content[@"zone_id"] : @"";
//    return extra;
//}
@end
