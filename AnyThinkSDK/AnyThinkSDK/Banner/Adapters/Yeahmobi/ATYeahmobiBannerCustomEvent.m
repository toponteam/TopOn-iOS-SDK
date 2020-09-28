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
//    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:adView, kBannerAssetsBannerViewKey, self, kBannerAssetsCustomEventKey, nil];
//    if ([self.unitID length] > 0) assets[kBannerAssetsUnitIDKey] = self.unitID;
//    [self handleAssets:assets];
    [self trackBannerAdLoaded:adView adExtra:nil];
}

- (void)CTAdView:(id<ATCTADMRAIDView>)adView didFailToReceiveAdWithError:(NSError*)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"YeahmobiBanner::CTAdView:didFailToReceiveAdWithError:%@", error] type:ATLogTypeExternal];
    [self trackBannerAdLoadFailed:error];
}

- (BOOL)CTAdView:(id<ATCTADMRAIDView>)adView shouldOpenURL:(NSURL*)url {
    [ATLogger logMessage:[NSString stringWithFormat:@"YeahmobiBanner::CTAdView:shouldOpenURL:%@", url] type:ATLogTypeExternal];
    [self trackBannerAdClick];
    return YES;
}

- (void)CTAdViewWillLeaveApplication:(id<ATCTADMRAIDView>)adView {
    [ATLogger logMessage:@"YeahmobiBanner::CTAdViewWillLeaveApplication:" type:ATLogTypeExternal];
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
