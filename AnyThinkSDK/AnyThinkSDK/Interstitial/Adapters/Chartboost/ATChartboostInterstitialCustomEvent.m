//
//  ATChartboostInterstitialCustomEvent.m
//  AnyThinkChartboostInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/9.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATChartboostInterstitialCustomEvent.h"
#import "ATChartboostInterstitialAdapter.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
#import "ATAPI.h"
NSString *CacheErrorDesc_ATCHBInterstitial(NSUInteger code) {
    return @{
        @0:@"CHBCacheErrorCodeInternal",
        @1:@"CHBCacheErrorCodeInternetUnavailable",
        @5:@"CHBCacheErrorCodeNetworkFailure",
        @6:@"CHBCacheErrorCodeNoAdFound",
        @7:@"CHBCacheErrorCodeSessionNotStarted",
        @16:@"CHBCacheErrorCodeAssetDownloadFailure",
        @35:@"CHBCacheErrorCodePublisherDisabled"
    }[@(code)];
}

NSString *ShowErrorDesc_ATCHBInterstitial(NSUInteger code) {
    return @{
        @0:@"CHBShowErrorCodeInternal",
        @7:@"CHBShowErrorCodeSessionNotStarted",
        @8:@"CHBShowErrorCodeAdAlreadyVisible",
        @25:@"CHBShowErrorCodeInternetUnavailable",
        @33:@"CHBShowErrorCodePresentationFailure",
        @34:@"CHBShowErrorCodeNoCachedAd"
    }[@(code)];
}

NSString *ClickErrorDesc_ATCHBInterstitial(NSUInteger code) {
    return @{
        @0:@"CHBClickErrorCodeUriInvalid",
        @1:@"CHBClickErrorCodeUriUnrecognized",
        @2:@"CHBClickErrorCodeConfirmationGateFailure",
        @3:@"CHBClickErrorCodeInternal"
    }[@(code)];
}

@interface ATChartboostInterstitialCustomEvent()
@property (nonatomic, weak) ATChartboostInterstitialAdapter *adapter;
@end
@implementation ATChartboostInterstitialCustomEvent
- (void)didCacheAd:(id)event error:(id<ATCHBError>)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"ChartboostInterstitial::didCacheAd:error:%@", error != nil ? CacheErrorDesc_ATCHBInterstitial(error.code) : @""] type:ATLogTypeExternal];
    if (error == nil) {
        [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:_interstitialAd, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @""}];
    } else {
        [self handleLoadingFailure:[NSError errorWithDomain:@"com.anythink.ChartboostInterstitalLoading" code:error.code userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load interstitial", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Chartboost has failed to cache interstitial with code:%@", CacheErrorDesc_ATCHBInterstitial(error.code)]}]];
    }
}

- (void)willShowAd:(id)event { [ATLogger logMessage:@"ChartboostInterstitial::willShowAd:" type:ATLogTypeExternal]; }

- (void)didShowAd:(id)event error:(id<ATCHBError>)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"ChartboostInterstitial::didShowAd:error:%@", error != nil ? ShowErrorDesc_ATCHBInterstitial(error.code) : @""] type:ATLogTypeExternal];
    if (error == nil) {
    [self trackShow];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
    } else {
        if ([self.delegate respondsToSelector:@selector(interstitialFailedToShowForPlacementID:error:extra:)]) { [self.delegate interstitialFailedToShowForPlacementID:self.interstitial.placementModel.placementID error:[NSError errorWithDomain:@"com.anythink.ChartboostInterstitialShow" code:error.code userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to show interstitial", NSLocalizedFailureReasonErrorKey:@"Chartboost SDK has failed to show interstitial"}] extra:[self delegateExtra]]; }
    }
}

- (BOOL)shouldConfirmClick:(id)event confirmationHandler:(void(^)(BOOL))confirmationHandler {
    [ATLogger logMessage:@"ChartboostInterstitial::shouldConfirmClick:confirmationHandler:" type:ATLogTypeExternal];
    return NO;
}

- (void)didClickAd:(id)event error:(id<ATCHBError>)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"ChartboostInterstitial::didClickAd:error:%@", error != nil ? ClickErrorDesc_ATCHBInterstitial(error.code) : @""] type:ATLogTypeExternal];
    if (error == nil) {
        [self trackClick];
        if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) { [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
    }
}

- (void)didFinishHandlingClick:(id)event error:(id<ATCHBError>)error { [ATLogger logMessage:[NSString stringWithFormat:@"ChartboostInterstitial::didFinishHandlingClick:error:%@", error != nil ? ClickErrorDesc_ATCHBInterstitial(error.code) : @""] type:ATLogTypeExternal]; }

- (void)didDismissAd:(id)event {
    [ATLogger logMessage:@"ChartboostInterstitial::didDismissAd:" type:ATLogTypeExternal];
    [self handleClose];
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) { [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"location"];
    return extra;
}
@end
