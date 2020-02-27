//
//  ATUnityAdsInterstitialCustomEvent.m
//  AnyThinkUnityAdsInterstitialAdapter
//
//  Created by Martin Lau on 2018/12/25.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATUnityAdsInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATAPI.h"
#import "ATInterstitialManager.h"
@interface ATUnityAdsInterstitialCustomEvent()
@property(nonatomic, readonly) BOOL requestFinished;
@end
@implementation ATUnityAdsInterstitialCustomEvent
- (void)unityServicesDidError:(NSInteger)error withMessage:(NSString *)message {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsInterstitial::unityServicesDidError:%ld withMessage:%@", error, message] type:ATLogTypeExternal];
    [self handleLoadingFailure:[NSError errorWithDomain:@"com.anythink.UnityAdsInterstitialLoad" code:error userInfo:@{NSLocalizedDescriptionKey:@"anythinkSDK has failed to load interstitial.", NSLocalizedFailureReasonErrorKey:[message length] > 0 ? message : @"UnityAds SDK has failed to load interstitial." }]];
    _requestFinished = YES;
}
-(void)placementContentReady:(NSString *)placementId placementContent:(id<UMONShowAdPlacementContent>)decision {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsInterstitial::placementContentReady:%@ placementContent:", placementId] type:ATLogTypeExternal];
}

-(void)placementContentStateDidChange:(NSString *)placementId placementContent:(id<UMONShowAdPlacementContent>)placementContent previousState:(NSInteger)previousState newState:(NSInteger)newState {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsInterstitial::placementContentStateDidChange:%@ placementContent:previousState:%ld newState:%ld", placementId, previousState, newState] type:ATLogTypeExternal];
    if (newState == 0 && [placementId isEqualToString:self.unitID] && !_requestFinished) {
        [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsInterstitial::Ad ready for placementID:%@", placementId] type:ATLogTypeExternal];
        [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kAdAssetsCustomObjectKey:placementContent}];
        _requestFinished = YES;
    }
}

-(void)unityAdsDidStart:(NSString*)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsInterstitial::unityAdsDidStart:%@", placementId] type:ATLogTypeExternal];
    if ([placementId isEqualToString:self.unitID]) {
        [self trackShow];
        if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}]; }
    }
}

-(void)unityAdsDidFinish:(NSString*)placementId withFinishState:(NSInteger)finishState {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsInterstitial::unityAdsDidFinish:%@ withFinishState:%ld", placementId, finishState] type:ATLogTypeExternal];
    if ([placementId isEqualToString:self.unitID]) {
        [self handleClose];
        if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) {
            [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
        }
    }
}
@end
