//
//  ATInmobiRewardedVideoCustomEvent.m
//  AnyThinkInmobiRewardedVideoAdapter
//
//  Created by Martin Lau on 09/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATInmobiRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "Utilities.h"
#import <objc/runtime.h>

@interface ATInmobiRewardedVideoCustomEvent()
@property(nonatomic) BOOL rewarded;
@property(nonatomic, readonly) BOOL clickHandled;
@property(nonatomic, readonly) BOOL interacted;
@end

@implementation ATInmobiRewardedVideoCustomEvent

-(void)interstitialDidReceiveAd:(id<ATIMInterstitial>)interstitial {
    [ATLogger logMessage:@"InmobiRewardedVideo::interstitialDidReceiveAd:" type:ATLogTypeExternal];
}

-(void)interstitialDidFinishLoading:(id<ATIMInterstitial>)interstitial {
    [ATLogger logMessage:@"InmobiRewardedVideo::interstitialDidFinishLoading:" type:ATLogTypeExternal];
    
    [self trackRewardedVideoAdLoaded:interstitial adExtra:@{kAdAssetsPriceKey: _price ? _price : @"0", kAdAssetsBidIDKey : _bidID ? _bidID : @""}];
}

-(void)interstitial:(id<ATIMInterstitial>)interstitial didFailToLoadWithError:(NSError*)error {
    [ATLogger logError:[NSString stringWithFormat:@"InmobiRewardedVideo::interstitial:didFailToLoadWithError:%@", error] type:ATLogTypeExternal];
    
    [self trackRewardedVideoAdLoadFailed:error];
}

-(void)InmobiRewardedVideo:(id<ATIMInterstitial>)interstitial {
    [ATLogger logMessage:@"Inmobi: interstitialWillPresent" type:ATLogTypeExternal];

}

-(void)interstitialDidPresent:(id<ATIMInterstitial>)interstitial {
    [ATLogger logMessage:@"InmobiRewardedVideo: interstitialDidPresent" type:ATLogTypeExternal];
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

-(void)interstitial:(id<ATIMInterstitial>)interstitial didFailToPresentWithError:(NSError*)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"InmobiRewardedVideo: interstitialDidFailToPresentWithError:%@", error] type:ATLogTypeExternal];
    [self trackRewardedVideoAdPlayEventWithError:error];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForPlacementID:error:extra:)]) { [self.delegate rewardedVideoDidFailToPlayForPlacementID:self.rewardedVideo.placementModel.placementID error:error extra:[self delegateExtra]]; }
}

-(void)interstitialWillDismiss:(id<ATIMInterstitial>)interstitial {
    [ATLogger logMessage:@"InmobiRewardedVideo: interstitialWillDismiss" type:ATLogTypeExternal];
}

-(void)interstitialDidDismiss:(id<ATIMInterstitial>)interstitial {
    [ATLogger logMessage:@"InmobiRewardedVideo: interstitialDidDismiss" type:ATLogTypeExternal];
    [self trackRewardedVideoAdCloseRewarded:_rewarded];
}

-(void)interstitial:(id<ATIMInterstitial>)interstitial didInteractWithParams:(NSDictionary*)params {
    [ATLogger logMessage:[NSString stringWithFormat:@"InmobiRewardedVideo: interstitialDidInteractWithParams:%@", params] type:ATLogTypeExternal];
    [self handleClick];
    _interacted = YES;
    if (_clickHandled) { _clickHandled = NO; }
}

-(void)interstitial:(id<ATIMInterstitial>)interstitial rewardActionCompletedWithRewards:(NSDictionary*)rewards {
    [ATLogger logMessage:[NSString stringWithFormat:@"InmobiRewardedVideo: interstitialRewardActionCompletedWithRewards:%@", rewards] type:ATLogTypeExternal];
    _rewarded = YES;
    [self trackRewardedVideoAdVideoEnd];
    [self trackRewardedVideoAdRewarded];
}

-(void)userWillLeaveApplicationFromInterstitial:(id<ATIMInterstitial>)interstitial {
    [ATLogger logMessage:@"InmobiRewardedVideo: userWillLeaveApplicationFromInterstitial" type:ATLogTypeExternal];
    _clickHandled = YES;
    [self handleClick];
    if (_interacted) { _interacted = NO; }
}

-(void) handleClick {
    if (!_interacted || !_clickHandled) {
        [self trackRewardedVideoAdClick];
    }
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"unit_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"unit_id"];
//    return extra;
//}
@end
