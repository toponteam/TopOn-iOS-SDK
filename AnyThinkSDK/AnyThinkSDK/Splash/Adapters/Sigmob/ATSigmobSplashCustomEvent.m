//
//  ATSigmobSplashCustomEvent.m
//  AnyThinkSigmobSplashAdapter
//
//  Created by Martin Lau on 2019/9/9.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATSigmobSplashCustomEvent.h"
#import "Utilities.h"
#import "ATSplashManager.h"
#import "ATSplashDelegate.h"
@implementation ATSigmobSplashCustomEvent
- (void)onSplashAdSuccessPresentScreen:(id<ATWindSplashAd>)splashAd {
    [ATLogger logMessage:@"SigmobSplash::onSplashAdSuccessPresentScreen:" type:ATLogTypeExternal];
    [self handleAssets:@{kAdAssetsCustomObjectKey:splashAd, kAdAssetsCustomEventKey:self, kAdAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"" }];
}

- (void)onSplashAdFailToPresent:(id<ATWindSplashAd>)splashAd withError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobSplash::onSplashAdFailToPresent:withError:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error != nil ? error : [NSError errorWithDomain:@"com.anythink.SigmobSplashLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load splash", NSLocalizedFailureReasonErrorKey:@"Sigmob has failed to load splash"}]];
}

- (void)onSplashAdClicked:(id<ATWindSplashAd>)splashAd {
    [ATLogger logMessage:@"SigmobSplash::onSplashAdClicked:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(splashDidClickForPlacementID:extra:)]) { [self.delegate splashDidClickForPlacementID:self.ad.placementModel.placementID extra:@{kATSplashDelegateExtraNetworkIDKey:@(self.ad.unitGroup.networkFirmID),kATSplashDelegateExtraAdSourceIDKey:self.ad.unitGroup.unitID != nil ? self.ad.unitGroup.unitID : @"",kATSplashDelegateExtraIsHeaderBidding:@(self.ad.unitGroup.headerBidding),kATSplashDelegateExtraPriority:@(self.priorityIndex),kATSplashDelegateExtraPrice:@(self.ad.unitGroup.price)}]; }
}

- (void)onSplashAdWillClosed:(id<ATWindSplashAd>)splashAd {
    [ATLogger logMessage:@"SigmobSplash::onSplashAdWillClosed:" type:ATLogTypeExternal];
}

- (void)onSplashAdClosed:(id<ATWindSplashAd>)splashAd {
    [ATLogger logMessage:@"SigmobSplash::onSplashAdClosed:" type:ATLogTypeExternal];
    if ([self.delegate respondsToSelector:@selector(splashDidCloseForPlacementID:extra:)]) { [self.delegate splashDidCloseForPlacementID:self.ad.placementModel.placementID extra:@{kATSplashDelegateExtraNetworkIDKey:@(self.ad.unitGroup.networkFirmID),kATSplashDelegateExtraAdSourceIDKey:self.ad.unitGroup.unitID != nil ? self.ad.unitGroup.unitID : @"",kATSplashDelegateExtraIsHeaderBidding:@(self.ad.unitGroup.headerBidding),kATSplashDelegateExtraPriority:@(self.priorityIndex),kATSplashDelegateExtraPrice:@(self.ad.unitGroup.price)}];
    }
}
@end
