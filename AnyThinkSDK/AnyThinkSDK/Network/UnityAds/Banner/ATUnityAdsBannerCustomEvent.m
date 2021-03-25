//
//  ATUnityAdsBannerCustomEvent.m
//  AnyThinkUnityAdsBannerAdapter
//
//  Created by Martin Lau on 2018/12/25.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATUnityAdsBannerCustomEvent.h"
#import "Utilities.h"
#import "ATBannerManager.h"
#import "ATAPI+Internal.h"


@implementation ATUnityAdsBannerCustomEvent

#pragma mark : UADSBannerViewDelegate
- (void)bannerViewDidLoad:(id<UADSBannerView>)bannerView {
    [ATLogger logMessage:@"UnityAdsBanner::bannerViewDidLoad:" type:ATLogTypeExternal];
    [self trackBannerAdLoaded:bannerView adExtra:nil];
}

- (void)bannerViewDidClick:(id<UADSBannerView>)bannerView {
    [ATLogger logMessage:@"UnityAdsBanner::bannerViewDidClick:" type:ATLogTypeExternal];
    [self trackBannerAdClick];
}

- (void)bannerViewDidLeaveApplication:(id<UADSBannerView>)bannerView {
    [ATLogger logMessage:@"UnityAdsBanner::bannerViewDidLoad:" type:ATLogTypeExternal];
}

- (void)bannerViewDidError:(id<UADSBannerView>)bannerView error:(NSError *)error{
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsBanner::bannerViewDidError::error::%@",error] type:ATLogTypeExternal];
    if (error.code == 3) {
        [self trackBannerAdLoadFailed:error];
    }
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"placement_id"];
}

/// This is an override method, for more detailsplease refer to ATBannerCustomEvent.h
- (BOOL)sendImpressionTrackingIfNeed {
    return YES;
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.banner.unitGroup.content[@"placement_id"];
//    return extra;
//}
@end
