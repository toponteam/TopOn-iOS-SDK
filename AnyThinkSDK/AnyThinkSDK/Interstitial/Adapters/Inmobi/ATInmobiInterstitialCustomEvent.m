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
//    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kAdAssetsCustomObjectKey:interstitial}];
    [self trackInterstitialAdLoaded:interstitial adExtra:nil];
}

-(void)interstitial:(id<ATIMInterstitial>)interstitial didFailToReceiveWithError:(NSError*)error { [ATLogger logError:[NSString stringWithFormat:@"InmobiInterstitial::interstitial:didFailToReceiveWithError:%@", error] type:ATLogTypeExternal]; }

-(void)interstitial:(id<ATIMInterstitial>)interstitial didFailToLoadWithError:(NSError*)error {
    [ATLogger logError:[NSString stringWithFormat:@"InmobiInterstitial::interstitial:didFailToLoadWithError:%@", error] type:ATLogTypeExternal];
    [self trackInterstitialAdLoadFailed:error];
}

-(void)interstitialWillPresent:(id<ATIMInterstitial>)interstitial {
    [ATLogger logMessage:@"InmobiInterstitial::interstitialWillPresent:" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
}

-(void)interstitialDidPresent:(id<ATIMInterstitial>)interstitial {
    [ATLogger logMessage:@"InmobiInterstitial::interstitialDidPresent:" type:ATLogTypeExternal];
}

-(void)interstitial:(id<ATIMInterstitial>)interstitial didFailToPresentWithError:(NSError*)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"InmobiInterstitial::interstitialDidFailToPresentWithError:%@", error] type:ATLogTypeExternal];
    [self trackInterstitialAdShowFailed:error];
}

-(void)interstitialWillDismiss:(id<ATIMInterstitial>)interstitial {
    [ATLogger logMessage:@"InmobiInterstitial::interstitialWillDismiss:" type:ATLogTypeExternal];
}

-(void)interstitialDidDismiss:(id<ATIMInterstitial>)interstitial {
    [ATLogger logMessage:@"InmobiInterstitial::interstitialDidDismiss:" type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
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
        [self trackInterstitialAdClick];
    }
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"unit_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"unit_id"];
//    return extra;
//}
@end
