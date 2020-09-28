//
//  ATBaiduBannerCustomEvent.m
//  AnyThinkBaiduBannerAdapter
//
//  Created by Martin Lau on 2018/11/30.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATBaiduBannerCustomEvent.h"
#import "Utilities.h"
#import "ATBannerManager.h"
#import "ATBannerView+Internal.h"

@interface ATBaiduBannerCustomEvent()
@property(nonatomic, readonly) id baiduBannerView;
@property(nonatomic, readonly) NSString *appID;
@property(nonatomic, readonly) BOOL impressed;
@end
@implementation ATBaiduBannerCustomEvent
-(instancetype) initWithUnitID:(NSString*)unitID serverInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo bannerView:(id)bannerView {
    self = [super initWithInfo:serverInfo localInfo:localInfo];
    if (self != nil) {
        _baiduBannerView = bannerView;
        _appID = serverInfo[@"app_id"];
    }
    return self;
}

- (NSString *)publisherId {
    [ATLogger logMessage:@"BaiduBanner::publisherId" type:ATLogTypeExternal];
    return _appID;
}

- (BOOL)enableLocation {
    [ATLogger logMessage:@"BaiduBanner::enableLocation" type:ATLogTypeExternal];
    return NO;
}

- (void)willDisplayAd:(id<ATBaiduMobAdView>)adview {
    [ATLogger logMessage:@"BaiduBanner::willDisplayAd:" type:ATLogTypeExternal];
}

- (void)failedDisplayAd:(NSInteger)reason {
    [ATLogger logMessage:[NSString stringWithFormat:@"BaiduBanner::failedDisplayAd:%ld", (long)reason] type:ATLogTypeExternal];
    [self trackBannerAdLoadFailed:[NSError errorWithDomain:@"com.anythink.BaiduBanner" code:reason userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:@"BaiduSDK has failed to load banner."}]];
}

- (void)didAdImpressed {
    [ATLogger logMessage:@"BaiduBanner::didAdImpressed" type:ATLogTypeExternal];
    if (!_impressed) {
        _impressed = YES;
        [self trackBannerAdLoaded:_baiduBannerView adExtra:nil];
    }
}

- (void)didAdClicked {
    [ATLogger logMessage:@"BaiduBanner::didAdClicked" type:ATLogTypeExternal];
    [self trackBannerAdClick];
}

- (void)didDismissLandingPage {
    [ATLogger logMessage:@"BaiduBanner::didDismissLandingPage" type:ATLogTypeExternal];
}

- (void)didAdClose {
    [ATLogger logMessage:@"BaiduBanner::didAdClose" type:ATLogTypeExternal];
    [self.bannerView loadNextWithoutRefresh];
//    if ([self.delegate respondsToSelector:@selector(bannerView:didTapCloseButtonWithPlacementID:extra:)]) {
//        [self.delegate bannerView:self.bannerView didTapCloseButtonWithPlacementID:self.banner.placementModel.placementID extra:[self delegateExtra]];
//    }
    [self trackBannerAdClosed];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"ad_place_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.banner.unitGroup.content[@"ad_place_id"];
//    return extra;
//}
@end
