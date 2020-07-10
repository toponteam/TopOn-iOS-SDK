//
//  ATTTRewardedVideoCustomEvent.m
//  AnyThinkTTRewardedVideoAdapter
//
//  Created by Martin Lau on 14/08/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATTTRewardedVideoCustomEvent.h"
#import "Utilities.h"
#import "ATRewardedVideoManager.h"
@implementation ATTTRewardedVideoCustomEvent
- (void)rewardedVideoAdDidLoad:(id<ATBURewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"ATTTRewardedVideoCustomEvent::rewardedVideoAdDidLoad:" type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

- (void)rewardedVideoAdVideoDidLoad:(id<ATBURewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"ATTTRewardedVideoCustomEvent::rewardedVideoAdVideoDidLoad:" type:ATLogTypeExternal];
    [self handleAssets:@{kRewardedVideoAssetsUnitIDKey:self.unitID, kAdAssetsCustomObjectKey:rewardedVideoAd, kRewardedVideoAssetsCustomEventKey:self}];
}

- (void)rewardedVideoAdDidVisible:(id<ATBURewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"ATTTRewardedVideoCustomEvent::rewardedVideoAdDidVisible:" type:ATLogTypeExternal];
    [self trackShow];
    [self trackVideoStart];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)rewardedVideoAdDidClose:(id<ATBURewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"ATTTRewardedVideoCustomEvent::rewardedVideoAdDidClose:" type:ATLogTypeExternal];
    [self handleClose];
    [self saveVideoCloseEventRewarded:self.rewardGranted];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
        [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:[self delegateExtra]];
    }
}

- (void)rewardedVideoAdDidClick:(id<ATBURewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"ATTTRewardedVideoCustomEvent::rewardedVideoAdDidClick:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)rewardedVideoAd:(id<ATBURewardedVideoAd>)rewardedVideoAd didFailWithError:(NSError *)error {
    [ATLogger logMessage:@"ATTTRewardedVideoCustomEvent::rewardedVideoAd:didFailWithError:" type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (void)rewardedVideoAdDidPlayFinish:(id<ATBURewardedVideoAd>)rewardedVideoAd didFailWithError:(NSError *)error {
    [ATLogger logMessage:@"ATTTRewardedVideoCustomEvent::rewardedVideoAdDidPlayFinish:didFailWithError:" type:ATLogTypeExternal];
    if (error == nil) {
        [self trackVideoEnd];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) {
            [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
        }
    } else {
        [self saveVideoPlayEventWithError:error];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForPlacementID:error:extra:)]) { [self.delegate rewardedVideoDidFailToPlayForPlacementID:self.rewardedVideo.placementModel.placementID error:error extra:[self delegateExtra]]; }
    }
}

- (void)rewardedVideoAdServerRewardDidSucceed:(id<ATBURewardedVideoAd>)rewardedVideoAd verify:(BOOL)verify {
    [ATLogger logMessage:@"ATTTRewardedVideoCustomEvent::rewardedVideoAdServerRewardDidSucceed:verify:" type:ATLogTypeExternal];
    self.rewardGranted = YES;
    if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){
        [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)rewardedVideoAdServerRewardDidFail:(id<ATBURewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"ATTTRewardedVideoCustomEvent::rewardedVideoAdServerRewardDidFail:" type:ATLogTypeExternal];
    self.rewardGranted = NO;
}


#pragma mark - nativeExpressRVDelegate
- (void)nativeExpressRewardedVideoAdDidLoad:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"ATTTNativeExpressRewardedVideoCustomEvent::nativeExpressRewardedVideoAdDidLoad:" type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

- (void)nativeExpressRewardedVideoAd:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    [ATLogger logMessage:@"ATTTNativeExpressRewardedVideoCustomEvent::nativeExpressRewardedVideoAdDidLoad:didFailWithError:" type:ATLogTypeExternal];
    if (!_isFailed) {
        [self handleLoadingFailure:error];
        _isFailed = true;
    }
}

- (void)nativeExpressRewardedVideoAdDidDownLoadVideo:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"ATTTNativeExpressRewardedVideoCustomEvent::nativeExpressRewardedVideoAdDidDownLoadVideo:" type:ATLogTypeExternal];
}

- (void)nativeExpressRewardedVideoAdViewRenderSuccess:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"ATTTNativeExpressRewardedVideoCustomEvent::nativeExpressRewardedVideoAdViewRenderSuccess:" type:ATLogTypeExternal];
    [self handleAssets:@{kRewardedVideoAssetsUnitIDKey:self.unitID, kAdAssetsCustomObjectKey:rewardedVideoAd, kRewardedVideoAssetsCustomEventKey:self}];
}

- (void)nativeExpressRewardedVideoAdViewRenderFail:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd error:(NSError *_Nullable)error {
    [ATLogger logMessage:@"ATTTNativeExpressRewardedVideoCustomEvent::nativeExpressRewardedVideoAdViewRenderFail:didFailWithError:" type:ATLogTypeExternal];
    if (!_isFailed) {
        [self handleLoadingFailure:error];
        _isFailed = true;
    }
}

- (void)nativeExpressRewardedVideoAdWillVisible:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd {
    
}

- (void)nativeExpressRewardedVideoAdDidVisible:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"ATTTNativeExpressRewardedVideoCustomEvent::nativeExpressRewardedVideoAdDidVisible:" type:ATLogTypeExternal];
       [self trackShow];
       [self trackVideoStart];
       if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
           [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
       }
}

- (void)nativeExpressRewardedVideoAdWillClose:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd {
    
}

- (void)nativeExpressRewardedVideoAdDidClose:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"ATTTNativeExpressRewardedVideoCustomEvent::nativeExpressRewardedVideoAdDidClose:" type:ATLogTypeExternal];
    [self handleClose];
    [self saveVideoCloseEventRewarded:self.rewardGranted];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
        [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:[self delegateExtra]];
    }
}

- (void)nativeExpressRewardedVideoAdDidClick:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"ATTTNativeExpressRewardedVideoCustomEvent::nativeExpressRewardedVideoAdDidClick:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)nativeExpressRewardedVideoAdDidClickSkip:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd {
    
}

- (void)nativeExpressRewardedVideoAdDidPlayFinish:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    [ATLogger logMessage:@"ATTTNativeExpressRewardedVideoCustomEvent::nativeExpressRewardedVideoAdDidPlayFinish:didFailWithError:" type:ATLogTypeExternal];
    if (error == nil) {
        [self trackVideoEnd];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) {
            [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
        }
    } else {
        [self saveVideoPlayEventWithError:error];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForPlacementID:error:extra:)]) { [self.delegate rewardedVideoDidFailToPlayForPlacementID:self.rewardedVideo.placementModel.placementID error:error extra:[self delegateExtra]]; }
    }
}

- (void)nativeExpressRewardedVideoAdServerRewardDidSucceed:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd verify:(BOOL)verify {
    [ATLogger logMessage:@"ATTTNativeExpressRewardedVideoCustomEvent::nativeExpressRewardedVideoAdServerRewardDidSucceed:verify:" type:ATLogTypeExternal];
    self.rewardGranted = YES;
    if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){
        [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)nativeExpressRewardedVideoAdServerRewardDidFail:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"ATTTNativeExpressRewardedVideoCustomEvent::nativeExpressRewardedVideoAdServerRewardDidFail:" type:ATLogTypeExternal];
       self.rewardGranted = NO;
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"slot_id"];
    return extra;
}
@end
