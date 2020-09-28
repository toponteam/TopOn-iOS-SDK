//
//  ATGDTBannerCustomEvent.m
//  AnyThinkGDTBannerAdapter
//
//  Created by Martin Lau on 20/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATGDTBannerCustomEvent.h"
#import "Utilities.h"
#import "ATBannerManager.h"
#import "AnyThinkBanner.h"
#import "ATPlacementModel.h"
#import "ATBannerView.h"
#import "ATBannerView+Internal.h"

@interface ATGDTBannerCustomEvent()
@end

@implementation ATGDTBannerCustomEvent

#pragma mark - banner 2.0 delegate(s)
- (void)unifiedBannerViewDidLoad:(id<GDTUnifiedBannerView>)unifiedBannerView {
    [ATLogger logMessage:@"GDTBanner::unifiedBannerViewDidLoad:" type:ATLogTypeExternal];
    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:unifiedBannerView, kBannerAssetsBannerViewKey, self, kBannerAssetsCustomEventKey, nil];
    if ([self.unitID length] > 0) { assets[kBannerAssetsUnitIDKey] = self.unitID; }
    [self handleAssets:assets];
}

- (void)unifiedBannerViewFailedToLoad:(id<GDTUnifiedBannerView>)unifiedBannerView error:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"GDTBanner::unifiedBannerViewFailedToLoad:error:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (void)unifiedBannerViewWillExpose:(id<GDTUnifiedBannerView>)unifiedBannerView {
    [ATLogger logMessage:@"GDTBanner::unifiedBannerViewWillExpose:" type:ATLogTypeExternal];
}

- (void)unifiedBannerViewClicked:(id<GDTUnifiedBannerView>)unifiedBannerView {
    [ATLogger logMessage:@"GDTBanner::unifiedBannerViewClicked:" type:ATLogTypeExternal];
    [self trackBannerAdClick];
}

- (void)unifiedBannerViewWillPresentFullScreenModal:(id<GDTUnifiedBannerView>)unifiedBannerView {
    [ATLogger logMessage:@"GDTBanner::unifiedBannerViewWillPresentFullScreenModal:" type:ATLogTypeExternal];
}

- (void)unifiedBannerViewDidPresentFullScreenModal:(id<GDTUnifiedBannerView>)unifiedBannerView {
    [ATLogger logMessage:@"GDTBanner::unifiedBannerViewDidPresentFullScreenModal:" type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (self.banner.requestID != nil) { userInfo[kBannerNotificationUserInfoRequestIDKey] = self.banner.requestID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kBannerPresentModalViewControllerNotification object:nil userInfo:userInfo];
}

- (void)unifiedBannerViewWillDismissFullScreenModal:(id<GDTUnifiedBannerView>)unifiedBannerView {
    [ATLogger logMessage:@"GDTBanner::unifiedBannerViewWillDismissFullScreenModal:" type:ATLogTypeExternal];
}

- (void)unifiedBannerViewDidDismissFullScreenModal:(id<GDTUnifiedBannerView>)unifiedBannerView {
    [ATLogger logMessage:@"GDTBanner::unifiedBannerViewDidDismissFullScreenModal:" type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (self.banner.requestID != nil) { userInfo[kBannerNotificationUserInfoRequestIDKey] = self.banner.requestID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kBannerDismissModalViewControllerNotification object:nil userInfo:userInfo];
}

- (void)unifiedBannerViewWillLeaveApplication:(id<GDTUnifiedBannerView>)unifiedBannerView {
    [ATLogger logMessage:@"GDTBanner::unifiedBannerViewWillLeaveApplication:" type:ATLogTypeExternal];
}

- (void)unifiedBannerViewWillClose:(id<GDTUnifiedBannerView>)unifiedBannerView {
    [ATLogger logMessage:@"GDTBanner::unifiedBannerViewWillClose:" type:ATLogTypeExternal];
    [self.bannerView loadNextWithoutRefresh];
    [self trackBannerAdClosed];
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
