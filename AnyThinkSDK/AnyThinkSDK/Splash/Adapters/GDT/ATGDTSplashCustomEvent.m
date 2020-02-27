//
//  ATGDTSplashCustomEvent.m
//  AnyThinkGDTSplashAdapter
//
//  Created by Martin Lau on 2018/12/20.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATGDTSplashCustomEvent.h"
#import "Utilities.h"
#import "ATSplashManager.h"
#import "ATSplashDelegate.h"
@implementation ATGDTSplashCustomEvent
- (void)splashAdSuccessPresentScreen:(id<ATGDTSplashAd>)splashAd {
    [ATLogger logMessage:@"ATGDTSplash::splashAdSuccessPresentScreen:" type:ATLogTypeExternal];
    [_backgroundImageView removeFromSuperview];
    [self handleAssets:@{kAdAssetsCustomObjectKey:splashAd, kAdAssetsCustomEventKey:self, kAdAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"" }];
    //Custom event's trackShow will be invoked in ATSplashManager, after the assets has been handled.
}

- (void)splashAdFailToPresent:(id<ATGDTSplashAd>)splashAd withError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"ATGDTSplash::splashAdFailToPresent:withError:%@", error] type:ATLogTypeExternal];
    [_backgroundImageView removeFromSuperview];
    [self handleLoadingFailure:error];
}

- (void)splashAdApplicationWillEnterBackground:(id<ATGDTSplashAd>)splashAd {
    [ATLogger logMessage:@"ATGDTSplash::splashAdApplicationWillEnterBackground:" type:ATLogTypeExternal];
}

- (void)splashAdExposured:(id<ATGDTSplashAd>)splashAd {
    [ATLogger logMessage:@"ATGDTSplash::splashAdExposured:" type:ATLogTypeExternal];
}

- (void)splashAdClicked:(id<ATGDTSplashAd>)splashAd {
    [ATLogger logMessage:@"ATGDTSplash::splashAdClicked:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(splashDidClickForPlacementID:extra:)]) { [self.delegate splashDidClickForPlacementID:self.ad.placementModel.placementID extra:@{kATSplashDelegateExtraNetworkIDKey:@(self.ad.unitGroup.networkFirmID),kATSplashDelegateExtraAdSourceIDKey:self.ad.unitGroup.unitID != nil ? self.ad.unitGroup.unitID : @"",kATSplashDelegateExtraIsHeaderBidding:@(self.ad.unitGroup.headerBidding),kATSplashDelegateExtraPriority:@(self.priorityIndex),kATSplashDelegateExtraPrice:@(self.ad.unitGroup.price)}]; }
}

- (void)splashAdWillClosed:(id<ATGDTSplashAd>)splashAd {
    [ATLogger logMessage:@"ATGDTSplash::splashAdWillClosed:" type:ATLogTypeExternal];
}

- (void)splashAdClosed:(id<ATGDTSplashAd>)splashAd {
    [ATLogger logMessage:@"ATGDTSplash::splashAdClosed:" type:ATLogTypeExternal];
    if ([self.delegate respondsToSelector:@selector(splashDidCloseForPlacementID:extra:)]) { [self.delegate splashDidCloseForPlacementID:self.ad.placementModel.placementID extra:@{kATSplashDelegateExtraNetworkIDKey:@(self.ad.unitGroup.networkFirmID),kATSplashDelegateExtraAdSourceIDKey:self.ad.unitGroup.unitID != nil ? self.ad.unitGroup.unitID : @"",kATSplashDelegateExtraIsHeaderBidding:@(self.ad.unitGroup.headerBidding),kATSplashDelegateExtraPriority:@(self.priorityIndex),kATSplashDelegateExtraPrice:@(self.ad.unitGroup.price)}];
    }
}

- (void)splashAdWillPresentFullScreenModal:(id<ATGDTSplashAd>)splashAd {
    [ATLogger logMessage:@"ATGDTSplash::splashAdWillPresentFullScreenModal:" type:ATLogTypeExternal];
}

- (void)splashAdDidPresentFullScreenModal:(id<ATGDTSplashAd>)splashAd {
    [ATLogger logMessage:@"ATGDTSplash::splashAdDidPresentFullScreenModal:" type:ATLogTypeExternal];
}

- (void)splashAdWillDismissFullScreenModal:(id<ATGDTSplashAd>)splashAd {
    [ATLogger logMessage:@"ATGDTSplash::splashAdWillDismissFullScreenModal:" type:ATLogTypeExternal];
}

- (void)splashAdDidDismissFullScreenModal:(id<ATGDTSplashAd>)splashAd {
    [ATLogger logMessage:@"ATGDTSplash::splashAdDidDismissFullScreenModal:" type:ATLogTypeExternal];
}

- (void)splashAdLifeTime:(NSUInteger)time {
    [ATLogger logMessage:[NSString stringWithFormat:@"ATGDTSplash::splashAdLifeTime:%lu", (unsigned long)time] type:ATLogTypeExternal];
}
@end
