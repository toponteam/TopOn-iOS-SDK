//
//  ATStartAppInterstitialCustomEvent.m
//  AnyThinkStartAppInterstitialAdapter
//
//  Created by Martin Lau on 2020/3/19.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATStartAppInterstitialCustomEvent.h"
#import "ATInterstitialManager.h"
#import "Utilities.h"

@interface ATStartAppInterstitialCustomEvent()
@property(nonatomic, readonly) BOOL closed;
@end
@implementation ATStartAppInterstitialCustomEvent
- (void) didLoadAd:(id<ATSTAAbstractAd>)ad {
    [ATLogger logMessage:@"StartAppInterstitial::didLoadAd:" type:ATLogTypeExternal];
    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:ad, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @""}];
}

- (void) failedLoadAd:(id<ATSTAAbstractAd>)ad withError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"StartAppInterstitial::failedLoadAd:withError:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error != nil ? error : [NSError errorWithDomain:@"com.anythink.StartAppInterstitialLoading" code:100001 userInfo:@{NSLocalizedDescriptionKey:@"StartApp failed to load ad", NSLocalizedFailureReasonErrorKey:@"StartApp failed to load ad"}]];
}

- (void) didShowAd:(id<ATSTAAbstractAd>)ad {
    [ATLogger logMessage:@"StartAppInterstitial::didShowAd:" type:ATLogTypeExternal];
    [self trackShow];
    if ([self.interstitial.unitGroup.content[@"is_video"] boolValue]) {
        [self trackVideoStart];
        if ([self.delegate respondsToSelector:@selector(interstitialDidStartPlayingVideoForPlacementID:extra:)]) { [self.delegate interstitialDidStartPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
    }
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
}

- (void) failedShowAd:(id<ATSTAAbstractAd>)ad withError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"StartAppInterstitial::failedShowAd:withError:%@", error] type:ATLogTypeExternal];
    if ([self.delegate respondsToSelector:@selector(interstitialFailedToShowForPlacementID:error:extra:)]) { [self.delegate interstitialFailedToShowForPlacementID:self.interstitial.placementModel.placementID error:error extra:[self delegateExtra]]; }
}

- (void) didCloseAd:(id<ATSTAAbstractAd>)ad {
    [ATLogger logMessage:@"StartAppInterstitial::didCloseAd:" type:ATLogTypeExternal];
    if (!_closed) {
        _closed = YES;
        [self handleClose];
        if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) { [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
    }
}

- (void) didClickAd:(id<ATSTAAbstractAd>)ad {
    [ATLogger logMessage:@"StartAppInterstitial::didClickAd:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
        [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
    //if the click leads to external browser, the close delegate method will not be called
    if (!_closed) {
        _closed = YES;
        [self handleClose];
        if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) { [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
    }
}

- (void) didCloseInAppStore:(id<ATSTAAbstractAd>)ad {
    [ATLogger logMessage:@"StartAppInterstitial::didCloseInAppStore:" type:ATLogTypeExternal];
    if (!_closed) {
        _closed = YES;
        [self handleClose];
        if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) { [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
    }
}

- (void) didCompleteVideo:(id<ATSTAAbstractAd>)ad {
    [ATLogger logMessage:@"StartAppInterstitial::didCompleteVideo:" type:ATLogTypeExternal];
    [self trackVideoEnd];
    if ([self.delegate respondsToSelector:@selector(interstitialDidEndPlayingVideoForPlacementID:extra:)]) {
        [self.delegate interstitialDidEndPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}
@end
