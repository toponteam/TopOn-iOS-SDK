//
//  ATTapjoyRewardedVideoCustomEvent.m
//  AnyThinkTapjoyRewardedVideoAdapter
//
//  Created by Martin Lau on 11/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATTapjoyRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "Utilities.h"
#import <objc/runtime.h>

@interface ATTapjoyRewardedVideoCustomEvent()
@property(nonatomic) BOOL rewarded;
@end
@implementation ATTapjoyRewardedVideoCustomEvent
#pragma mark - placement
- (void)requestDidSucceed:(id<ATTJPlacement>)placement {
    [ATLogger logMessage:[NSString stringWithFormat:@"Tapjoy: requestDidSucceed"]  type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

- (void)requestDidFail:(id<ATTJPlacement>)placement error:(NSError*)error {
    [ATLogger logError:[NSString stringWithFormat:@"Tapjoy: requestDidFail, error:%@", error]  type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (void)contentIsReady:(id<ATTJPlacement>)placement {
    [ATLogger logMessage:[NSString stringWithFormat:@"Tapjoy: contentIsReady"]  type:ATLogTypeExternal];
    objc_setAssociatedObject(placement, (__bridge_retained void*)kTapjoyRVCustomEventKey, self, OBJC_ASSOCIATION_RETAIN);
    [self handleAssets:@{kRewardedVideoAssetsUnitIDKey:self.unitID, kAdAssetsCustomObjectKey:placement}];
}

- (void)contentDidAppear:(id<ATTJPlacement>)placement {
    [self trackShow];
    [ATLogger logMessage:[NSString stringWithFormat:@"Tapjoy: contentDidAppear"]  type:ATLogTypeExternal];
}

- (void)contentDidDisappear:(id<ATTJPlacement>)placement {
    [ATLogger logMessage:[NSString stringWithFormat:@"Tapjoy: contentDidDisappear"]  type:ATLogTypeExternal];
    [self handleClose];
    [self saveVideoCloseEventRewarded:_rewarded];
    [[ATRewardedVideoManager sharedManager] removeCustomEventForKey:self.rewardedVideo.placementModel.placementID];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
        [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:[self delegateExtra]];
    }
}

- (void)placement:(id<ATTJPlacement>)placement didRequestPurchase:(id<ATTJActionRequest>)request productId:(NSString*)productId {
    //
}

- (void)placement:(id<ATTJPlacement>)placement didRequestReward:(id<ATTJActionRequest>)request itemId:(NSString*)itemId quantity:(int)quantity {
    //
}
#pragma mark - video
- (void)videoDidStart:(id<ATTJPlacement>)placement {
    [ATLogger logMessage:[NSString stringWithFormat:@"Tapjoy: videoDidStart"]  type:ATLogTypeExternal];
    [self trackVideoStart];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)videoDidComplete:(id<ATTJPlacement>)placement {
    [ATLogger logMessage:[NSString stringWithFormat:@"Tapjoy: videoDidComplete"]  type:ATLogTypeExternal];
    _rewarded = YES;
    self.rewardGranted = YES;
    [self trackVideoEnd];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
    if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){
        [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)videoDidFail:(id<ATTJPlacement>)placement error:(NSString*)errorMsg {
    [ATLogger logError:[NSString stringWithFormat:@"Tapjoy: videoDidFail, msg:%@", errorMsg]  type:ATLogTypeExternal];
    NSError *error = [NSError errorWithDomain:@"Tapjoy rewarded video playing failed." code:10000 userInfo:@{NSLocalizedFailureReasonErrorKey:errorMsg, NSLocalizedDescriptionKey:errorMsg}];
    [self saveVideoPlayEventWithError:error];
    [[ATRewardedVideoManager sharedManager] removeCustomEventForKey:self.rewardedVideo.placementModel.placementID];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForPlacementID:error:extra:)]) { [self.delegate rewardedVideoDidFailToPlayForPlacementID:self.rewardedVideo.placementModel.placementID error:error extra:[self delegateExtra]]; }
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"placement_name"];
    return extra;
}
@end
