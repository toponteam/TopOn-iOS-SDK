//
//  ATInmobiBannerCustomEvent.m
//  AnyThinkInmobiBannerAdapter
//
//  Created by Martin Lau on 2018/10/8.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATInmobiBannerCustomEvent.h"
#import "Utilities.h"
#import "ATBannerManager.h"

@interface ATInmobiBannerCustomEvent()
@property(nonatomic, readonly) BOOL clickHandled;
@property(nonatomic, readonly) BOOL interacted;
@end
@implementation ATInmobiBannerCustomEvent
-(void)bannerDidFinishLoading:(id<ATIMBanner>)banner {
    [ATLogger logMessage:@"InmobiBanner::bannerDidFinishLoading:" type:ATLogTypeExternal];
    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithObjectsAndKeys:banner, kBannerAssetsBannerViewKey, self, kBannerAssetsCustomEventKey, nil];
    if ([self.unitID length] > 0) assets[kBannerAssetsUnitIDKey] = self.unitID;
    [self handleAssets:assets];
}

-(void)banner:(id<ATIMBanner>)banner didFailToLoadWithError:(NSError*)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"InmobiBanner::banner:didFailToLoadWithError:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

-(void)banner:(id<ATIMBanner>)banner didInteractWithParams:(NSDictionary*)params {
    [ATLogger logMessage:[NSString stringWithFormat:@"InmobiBanner::banner:didInteractWithParams:%@", params] type:ATLogTypeExternal];
    [self handleClick];
    _interacted = YES;
    if (_clickHandled) { _clickHandled = NO; }
}

-(void)userWillLeaveApplicationFromBanner:(id<ATIMBanner>)banner {
    [ATLogger logMessage:@"InmobiBanner::userWillLeaveApplicationFromBanner:" type:ATLogTypeExternal];
    _clickHandled = YES;
    [self handleClick];
    if (_interacted) { _interacted = NO; }
}

-(void)bannerWillPresentScreen:(id<ATIMBanner>)banner {
    [ATLogger logMessage:@"InmobiBanner::bannerWillPresentScreen:" type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (self.banner.requestID != nil) { userInfo[kBannerNotificationUserInfoRequestIDKey] = self.banner.requestID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kBannerPresentModalViewControllerNotification object:nil userInfo:userInfo];
}

-(void)bannerDidPresentScreen:(id<ATIMBanner>)banner {
    [ATLogger logMessage:@"InmobiBanner::bannerDidPresentScreen:" type:ATLogTypeExternal];
    [self handleClick];
}

-(void)bannerWillDismissScreen:(id<ATIMBanner>)banner {
    [ATLogger logMessage:@"InmobiBanner::bannerWillDismissScreen:" type:ATLogTypeExternal];
}

-(void)bannerDidDismissScreen:(id<ATIMBanner>)banner {
    [ATLogger logMessage:@"InmobiBanner::bannerDidDismissScreen:" type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (self.banner.requestID != nil) { userInfo[kBannerNotificationUserInfoRequestIDKey] = self.banner.requestID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kBannerDismissModalViewControllerNotification object:nil userInfo:userInfo];
}

-(void)banner:(id<ATIMBanner>)banner rewardActionCompletedWithRewards:(NSDictionary*)rewards {
    [ATLogger logMessage:@"InmobiBanner::" type:ATLogTypeExternal];
}

-(void) handleClick {
    if (!_interacted || !_clickHandled) {
        [self trackClick];
        if ([self.delegate respondsToSelector:@selector(bannerView:didClickWithPlacementID: extra:)]) {
            [self.delegate bannerView:self.bannerView didClickWithPlacementID:self.banner.placementModel.placementID extra:@{kATBannerDelegateExtraNetworkIDKey:@(self.banner.unitGroup.networkFirmID), kATBannerDelegateExtraAdSourceIDKey:self.banner.unitGroup.unitID != nil ? self.banner.unitGroup.unitID : @"",kATBannerDelegateExtraIsHeaderBidding:@(self.banner.unitGroup.headerBidding),kATBannerDelegateExtraPriority:@(self.priorityIndex),kATBannerDelegateExtraPrice:@(self.banner.unitGroup.price)}];
        }
    }
}
@end
