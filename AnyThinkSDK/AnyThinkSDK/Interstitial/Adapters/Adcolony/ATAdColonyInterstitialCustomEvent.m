//
//  ATAdColonyInterstitialCustomEvent.m
//  AnyThinkAdColonyInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/9.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdColonyInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
@implementation ATAdColonyInterstitialCustomEvent
-(ATNativeADSourceType) adSourceType {
    return ATNativeADSourceTypeVideo;
}

#pragma mark -new delegate
- (void)adColonyInterstitialDidLoad:(id<ATAdColonyInterstitial> _Nonnull)interstitial {
    [ATLogger logMessage:@"AdColonyInterstitial::adColonyInterstitialDidLoad:" type:ATLogTypeInternal];
       [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kAdAssetsCustomObjectKey:interstitial}];
}

- (void)adColonyInterstitialDidFailToLoad:(id<AdColonyAdRequestError>)error {
    [ATLogger logMessage:@"AdColonyInterstitial::handleLoadFailure" type:ATLogTypeInternal];
    
    [self handleLoadingFailure:(NSError*)error];
}

- (void)adColonyInterstitialWillOpen:(id<ATAdColonyInterstitial> _Nonnull)interstitial {
    [ATLogger logMessage:@"AdColonyInterstitial::adColonyInterstitialWillOpen" type:ATLogTypeInternal];
    [self trackShow];
    [self trackVideoStart];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }

    if ([self.delegate respondsToSelector:@selector(interstitialDidStartPlayingVideoForPlacementID:extra:)]) {
        [self.delegate interstitialDidStartPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)adColonyInterstitialDidClose:(id<ATAdColonyInterstitial> _Nonnull)interstitial {
    [ATLogger logMessage:@"AdColonyInterstitial::adColonyInterstitialDidClose" type:ATLogTypeInternal];
    [super handleClose];
    [self trackVideoEnd];
    if ([self.delegate respondsToSelector:@selector(interstitialDidEndPlayingVideoForPlacementID:extra:)]) {
       [self.delegate interstitialDidEndPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) {
        [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
   
}

- (void)adColonyInterstitialExpired:(id<ATAdColonyInterstitial> _Nonnull)interstitial {
    
}

- (void)adColonyInterstitialWillLeaveApplication:(id<ATAdColonyInterstitial> _Nonnull)interstitial {
    
}

- (void)adColonyInterstitialDidReceiveClick:(id<ATAdColonyInterstitial> _Nonnull)interstitial {
    [ATLogger logMessage:@"AdColonyInterstitial::adColonyInterstitialDidReceiveClick" type:ATLogTypeInternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
        [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)adColonyInterstitial:(id<ATAdColonyInterstitial> _Nonnull)interstitial iapOpportunityWithProductId:(NSString * _Nonnull)iapProductID andEngagement:(ATAdColonyIAPEngagement)engagement {
    
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"zone_id"];
    return extra;
}
@end
