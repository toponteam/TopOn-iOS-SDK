//
//  ATInmobiInterstitialCustomEvent.m
//  AnyThinkInmobiInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/8.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATInmobiInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"

@interface ATInmobiInterstitialCustomEvent()
@property(nonatomic, readonly) BOOL clickHandled;
@property(nonatomic, readonly) BOOL interacted;
@end
@implementation ATInmobiInterstitialCustomEvent
-(void)interstitial:(id<ATIMInterstitial>)interstitial didReceiveWithMetaInfo:(id)metaInfo {
    [ATLogger logMessage:@"InmobiInterstitial::interstitial:didReceiveWithMetaInfo:" type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

-(void)interstitialDidReceiveAd:(id<ATIMInterstitial>)interstitial { [ATLogger logMessage:@"InmobiInterstitial::interstitialDidReceiveAd:" type:ATLogTypeExternal]; }

-(void)interstitialDidFinishLoading:(id<ATIMInterstitial>)interstitial {
    [ATLogger logMessage:@"InmobiInterstitial::interstitialDidFinishLoading:" type:ATLogTypeExternal];
    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kAdAssetsCustomObjectKey:interstitial}];
}

-(void)interstitial:(id<ATIMInterstitial>)interstitial didFailToReceiveWithError:(NSError*)error { [ATLogger logError:[NSString stringWithFormat:@"InmobiInterstitial::interstitial:didFailToReceiveWithError:%@", error] type:ATLogTypeExternal]; }

-(void)interstitial:(id<ATIMInterstitial>)interstitial didFailToLoadWithError:(NSError*)error {
    [ATLogger logError:[NSString stringWithFormat:@"InmobiInterstitial::interstitial:didFailToLoadWithError:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

-(void)interstitialWillPresent:(id<ATIMInterstitial>)interstitial {
    [ATLogger logMessage:@"InmobiInterstitial::interstitialWillPresent:" type:ATLogTypeExternal];
    [self trackShow];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
}

-(void)interstitialDidPresent:(id<ATIMInterstitial>)interstitial {
    [ATLogger logMessage:@"InmobiInterstitial::interstitialDidPresent:" type:ATLogTypeExternal];
}

-(void)interstitial:(id<ATIMInterstitial>)interstitial didFailToPresentWithError:(NSError*)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"InmobiInterstitial::interstitialDidFailToPresentWithError:%@", error] type:ATLogTypeExternal];
    if ([self.delegate respondsToSelector:@selector(interstitialFailedToShowForPlacementID:error:extra:)]) {
        [self.delegate interstitialFailedToShowForPlacementID:self.interstitial.placementModel.placementID error:error extra:[self delegateExtra]];
    }
}

-(void)interstitialWillDismiss:(id<ATIMInterstitial>)interstitial {
    [ATLogger logMessage:@"InmobiInterstitial::interstitialWillDismiss:" type:ATLogTypeExternal];
}

-(void)interstitialDidDismiss:(id<ATIMInterstitial>)interstitial {
    [ATLogger logMessage:@"InmobiInterstitial::interstitialDidDismiss:" type:ATLogTypeExternal];
    [self handleClose];
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) {
        [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

-(void)interstitial:(id<ATIMInterstitial>)interstitial rewardActionCompletedWithRewards:(NSDictionary*)rewards {
    [ATLogger logMessage:[NSString stringWithFormat:@"InmobiInterstitial::interstitial:rewardActionCompletedWithRewards:%@", rewards] type:ATLogTypeExternal];
}

-(void)interstitial:(id<ATIMInterstitial>)interstitial didInteractWithParams:(NSDictionary*)params {
    [ATLogger logMessage:[NSString stringWithFormat:@"InmobiInterstitial::interstitialDidInteractWithParams:%@", params] type:ATLogTypeExternal];
    [self handleClick];
    _interacted = YES;
    if (_clickHandled) { _clickHandled = NO; }
}

-(void)userWillLeaveApplicationFromInterstitial:(id<ATIMInterstitial>)interstitial {
    [ATLogger logMessage:@"InmobiInterstitial::userWillLeaveApplicationFromInterstitial:" type:ATLogTypeExternal];
    _clickHandled = YES;
    [self handleClick];
    if (_interacted) { _interacted = NO; }
}

-(void) handleClick {
    if (!_interacted || !_clickHandled) {
        [self trackClick];
        if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
            [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
        }
    }
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"unit_id"];
    return extra;
}
@end
