//
//  ATStartAppSplashCustomEvent.m
//  AnyThinkStartAppSplashAdapter
//
//  Created by Martin Lau on 2020/6/15.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATStartAppSplashCustomEvent.h"
#import "Utilities.h"
#import "ATSplashManager.h"
#import "ATSplashDelegate.h"
@implementation ATStartAppSplashCustomEvent
- (void)didLoadAd:(id)ad {
    [ATLogger logMessage:@"StartAppSplash::didLoadAd:" type:ATLogTypeExternal];
    [self handleAssets:@{kAdAssetsCustomObjectKey:ad, kAdAssetsCustomEventKey:self, kAdAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @""}];
}

- (void)failedLoadAd:(id)ad withError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"StartAppSplash::failedLoadAd:withError:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error != nil ? error : [NSError errorWithDomain:@"com.anythink.StartAppSplashLoading" code:0 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load splash", NSLocalizedFailureReasonErrorKey:@"StartAppSDK has failed to load splash"}]];
}

- (void)didShowAd:(id)ad { [ATLogger logMessage:@"StartAppSplash::didShowAd:" type:ATLogTypeExternal]; }

- (void)failedShowAd:(id)ad withError:(NSError *)error { [ATLogger logMessage:[NSString stringWithFormat:@"StartAppSplash::failedShowAd:withError:%@", error] type:ATLogTypeExternal]; }

- (void)didCloseAd:(id)ad {
    [ATLogger logMessage:@"StartAppSplash::didCloseAd:" type:ATLogTypeExternal];
    if ([self.delegate respondsToSelector:@selector(splashDidCloseForPlacementID:extra:)]) { [self.delegate splashDidCloseForPlacementID:self.ad.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)didClickAd:(id)ad {
    [ATLogger logMessage:@"StartAppSplash::didClickAd:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(splashDidClickForPlacementID:extra:)]) { [self.delegate splashDidClickForPlacementID:self.ad.placementModel.placementID extra:[self delegateExtra]]; }
}

- (void)didCloseInAppStore:(id)ad { [ATLogger logMessage:@"StartAppSplash::didCloseInAppStore:" type:ATLogTypeExternal]; }

- (void)didCompleteVideo:(id)ad { [ATLogger logMessage:@"StartAppSplash::didCompleteVideo:" type:ATLogTypeExternal]; }

- (void)didClickNativeAdDetails:(id)nativeAdDetails { [ATLogger logMessage:@"StartAppSplash::didClickNativeAdDetails:" type:ATLogTypeExternal]; }
@end
