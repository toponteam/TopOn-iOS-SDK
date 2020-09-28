//
//  ATFacebookBannerCustomEvent.m
//  AnyThinkFacebookBannerAdapter
//
//  Created by Martin Lau on 29/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATFacebookBannerCustomEvent.h"
#import "ATBannerManager.h"
#import "Utilities.h"

@implementation ATFacebookBannerCustomEvent
- (void)adViewDidClick:(id<ATFBAdView>)adView {
    [ATLogger logMessage:@"FacebookBanner::adViewDidClick" type:ATLogTypeExternal];
    [self trackBannerAdClick];
}

- (void)adViewDidFinishHandlingClick:(id<ATFBAdView>)adView {
    [ATLogger logMessage:@"FacebookBanner::adViewDidFinishHandlingClick" type:ATLogTypeExternal];
}

- (void)adViewDidLoad:(id<ATFBAdView>)adView {
    [ATLogger logMessage:@"FacebookBanner::adViewDidLoad" type:ATLogTypeExternal];
    [self trackBannerAdLoaded:adView adExtra:nil];
}

- (void)adView:(id<ATFBAdView>)adView didFailWithError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"FacebookBanner::adView:didFailWithError:%@", error] type:ATLogTypeExternal];
    [self trackBannerAdLoadFailed:error];
}

- (void)adViewWillLogImpression:(id<ATFBAdView>)adView {
    [ATLogger logMessage:@"FacebookBanner::adViewWillLogImpression" type:ATLogTypeExternal];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"unit_id"];
}
//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.banner.unitGroup.content[@"unit_id"];
//    return extra;
//}
@end
