//
//  ATYeahmobiBannerCustomEvent.m
//  AnyThinkYeahmobiBannerAdapter
//
//  Created by Martin Lau on 2018/10/16.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATYeahmobiBannerCustomEvent.h"
#import "Utilities.h"
#import "ATBannerManager.h"

@implementation ATYeahmobiBannerCustomEvent
- (void)CTAdViewDidRecieveBannerAd:(id<ATCTADMRAIDView>)adView {
    [ATLogger logMessage:@"YeahmobiBanner::CTAdViewDidRecieveBannerAd:" type:ATLogTypeExternal];
    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:adView, kBannerAssetsBannerViewKey, self, kBannerAssetsCustomEventKey, nil];
    if ([self.unitID length] > 0) assets[kBannerAssetsUnitIDKey] = self.unitID;
    [self handleAssets:assets];
}

- (void)CTAdView:(id<ATCTADMRAIDView>)adView didFailToReceiveAdWithError:(NSError*)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"YeahmobiBanner::CTAdView:didFailToReceiveAdWithError:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (BOOL)CTAdView:(id<ATCTADMRAIDView>)adView shouldOpenURL:(NSURL*)url {
    [ATLogger logMessage:[NSString stringWithFormat:@"YeahmobiBanner::CTAdView:shouldOpenURL:%@", url] type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(bannerView:didClickWithPlacementID: extra:)]) {
        [self.delegate bannerView:self.bannerView didClickWithPlacementID:self.banner.placementModel.placementID extra:[self delegateExtra]];
    }
    return YES;
}

- (void)CTAdViewWillLeaveApplication:(id<ATCTADMRAIDView>)adView {
    [ATLogger logMessage:@"YeahmobiBanner::CTAdViewWillLeaveApplication:" type:ATLogTypeExternal];
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.banner.unitGroup.content[@"slot_id"];
    return extra;
}
@end
