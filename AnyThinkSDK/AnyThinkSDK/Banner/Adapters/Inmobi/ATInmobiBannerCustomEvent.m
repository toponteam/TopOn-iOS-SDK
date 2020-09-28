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
-(void)banner:(id<ATIMBanner>)banner gotSignals:(NSData*)signals { [ATLogger logMessage:@"InmobiBanner::banner:gotSignals:" type:ATLogTypeExternal]; }

-(void)banner:(id<ATIMBanner>)banner failedToGetSignalsWithError:(id)status { [ATLogger logMessage:[NSString stringWithFormat:@"InmobiBanner::banner:failedToGetSignalsWithError:%@", status] type:ATLogTypeExternal]; }

-(void)banner:(id<ATIMBanner>)banner didReceiveWithMetaInfo:(id)info { [ATLogger logMessage:[NSString stringWithFormat:@"InmobiBanner::banner:didReceiveWithMetaInfo:"] type:ATLogTypeExternal]; }

-(void)banner:(id<ATIMBanner>)banner didFailToReceiveWithError:(id)error { [ATLogger logMessage:[NSString stringWithFormat:@"InmobiBanner::banner:didFailToReceiveWithError:%@", error] type:ATLogTypeExternal]; }

-(void)bannerDidFinishLoading:(id<ATIMBanner>)banner {
    [ATLogger logMessage:@"InmobiBanner::bannerDidFinishLoading:" type:ATLogTypeExternal];

    [self trackBannerAdLoaded:banner adExtra:nil];
}

-(void)banner:(id<ATIMBanner>)banner didFailToLoadWithError:(NSError*)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"InmobiBanner::banner:didFailToLoadWithError:%@", error] type:ATLogTypeExternal];
    [self trackBannerAdLoadFailed:error];
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
    [ATLogger logMessage:[NSString stringWithFormat:@"InmobiBanner::banner:rewardActionCompletedWithRewards:%@", rewards] type:ATLogTypeExternal];
}

-(void) handleClick {
    if (!_interacted || !_clickHandled) {
        [self trackBannerAdClick];
    }
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
