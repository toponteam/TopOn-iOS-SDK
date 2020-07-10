//
//  ATFyberBannerCustomEvent.m
//  AnyThinkFyberBannerAdapter
//
//  Created by Martin Lau on 2020/4/9.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATFyberBannerCustomEvent.h"
#import "Utilities.h"

@implementation ATFyberBannerCustomEvent
- (UIViewController * _Nonnull)IAParentViewControllerForUnitController:(id  _Nullable)unitController {
    [ATLogger logMessage:@"FyberBanner::IAParentViewControllerForUnitController:" type:ATLogTypeExternal];
    return self.bannerView.presentingViewController;
}

- (void)IAAdDidReceiveClick:(id  _Nullable)unitController {
    [ATLogger logMessage:@"FyberBanner::IAAdDidReceiveClick:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(bannerView:didClickWithPlacementID: extra:)]) {
        [self.delegate bannerView:self.bannerView didClickWithPlacementID:self.banner.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)IAAdWillLogImpression:(id  _Nullable)unitController {
    [ATLogger logMessage:@"FyberBanner::IAAdWillLogImpression:" type:ATLogTypeExternal];
}

- (void)IAUnitControllerWillPresentFullscreen:(id  _Nullable)unitController {
    [ATLogger logMessage:@"FyberBanner::IAUnitControllerWillPresentFullscreen:" type:ATLogTypeExternal];
}

- (void)IAUnitControllerDidPresentFullscreen:(id  _Nullable)unitController {
    [ATLogger logMessage:@"FyberBanner::IAUnitControllerDidPresentFullscreen:" type:ATLogTypeExternal];
}

- (void)IAUnitControllerWillDismissFullscreen:(id  _Nullable)unitController {
    [ATLogger logMessage:@"FyberBanner::IAUnitControllerWillDismissFullscreen:" type:ATLogTypeExternal];
}

- (void)IAUnitControllerDidDismissFullscreen:(id  _Nullable)unitController {
    [ATLogger logMessage:@"FyberBanner::IAUnitControllerWillDismissFullscreen:" type:ATLogTypeExternal];
}

- (void)IAUnitControllerWillOpenExternalApp:(id  _Nullable)unitController {
    [ATLogger logMessage:@"FyberBanner::IAUnitControllerWillOpenExternalApp:" type:ATLogTypeExternal];
}
@end
