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
- (void)splashAdDidLoad:(id<ATGDTSplashAd>)splashAd {
    [ATLogger logMessage:@"ATGDTSplash::splashAdDidLoad:" type:ATLogTypeExternal];
    [self handleAssets:@{kAdAssetsCustomObjectKey:splashAd, kAdAssetsCustomEventKey:self, kAdAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"" }];
    if ([[NSDate date] timeIntervalSinceDate:_loadStartDate] < _timeout) {
        [splashAd showAdInWindow:_window withBottomView:_bottomView skipView:_skipView];
    } else {
        [self handleLoadingFailure:[NSError errorWithDomain:@"com.anythink.GDTSplashAdLoading" code:1 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load splash ad", NSLocalizedFailureReasonErrorKey:@"GDTSDK has failed to fetch splash ad within the specified time limit."}]];
    }
}

- (void)splashAdSuccessPresentScreen:(id)splashAd {
    [ATLogger logMessage:@"ATGDTSplash::splashAdSuccessPresentScreen:" type:ATLogTypeExternal];
}

- (void)splashAdFailToPresent:(id)splashAd withError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"ATGDTSplash::splashAdFailToPresent:withError:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error != nil ? error : [NSError errorWithDomain:@"com.anythink.GDTSplashAdLoading" code:0 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load splash ad", NSLocalizedFailureReasonErrorKey:@"GDTSDK has failed to fetch splash ad"}]];
}

- (void)splashAdApplicationWillEnterBackground:(id)splashAd {
    [ATLogger logMessage:@"ATGDTSplash::splashAdApplicationWillEnterBackground:" type:ATLogTypeExternal];
}

- (void)splashAdExposured:(id)splashAd {
    [ATLogger logMessage:@"ATGDTSplash::splashAdExposured:" type:ATLogTypeExternal];
    if ([self.delegate respondsToSelector:@selector(splashDidShowForPlacementID:extra:)]) { [self.delegate splashDidShowForPlacementID:self.ad.placementModel.placementID extra:[self delegateExtra]]; }
    //Custom event's trackShow will be invoked in ATSplashManager, after the assets has been handled.
}

- (void)splashAdClicked:(id)splashAd {
    [ATLogger logMessage:@"ATGDTSplash::splashAdClicked:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(splashDidClickForPlacementID:extra:)]) { [self.delegate splashDidClickForPlacementID:self.ad.placementModel.placementID extra:[self delegateExtra]]; }
}

- (void)splashAdWillClosed:(id)splashAd {
    [ATLogger logMessage:@"ATGDTSplash::splashAdWillClosed:" type:ATLogTypeExternal];
}

- (void)splashAdClosed:(id)splashAd {
    [ATLogger logMessage:@"ATGDTSplash::splashAdClosed:" type:ATLogTypeExternal];
    if ([self.delegate respondsToSelector:@selector(splashDidCloseForPlacementID:extra:)]) { [self.delegate splashDidCloseForPlacementID:self.ad.placementModel.placementID extra:[self delegateExtra]]; }
}

- (void)splashAdWillPresentFullScreenModal:(id)splashAd {
    [ATLogger logMessage:@"ATGDTSplash::splashAdWillPresentFullScreenModal:" type:ATLogTypeExternal];
}

- (void)splashAdDidPresentFullScreenModal:(id)splashAd {
    [ATLogger logMessage:@"ATGDTSplash::splashAdDidPresentFullScreenModal:" type:ATLogTypeExternal];
}

- (void)splashAdWillDismissFullScreenModal:(id)splashAd {
    [ATLogger logMessage:@"ATGDTSplash::splashAdWillDismissFullScreenModal:" type:ATLogTypeExternal];
}

- (void)splashAdDidDismissFullScreenModal:(id)splashAd {
    [ATLogger logMessage:@"ATGDTSplash::splashAdDidDismissFullScreenModal:" type:ATLogTypeExternal];
}

- (void)splashAdLifeTime:(NSUInteger)time {
    [ATLogger logMessage:[NSString stringWithFormat:@"ATGDTSplash::splashAdLifeTime:%lu", (unsigned long)time] type:ATLogTypeExternal];
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.ad.unitGroup.content[@"unit_id"];
    return extra;
}
@end
