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
    [self trackRewardedVideoAdLoaded:rewardedVideoAd adExtra:nil];
}

- (void)rewardedVideoAdDidVisible:(id<ATBURewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"ATTTRewardedVideoCustomEvent::rewardedVideoAdDidVisible:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

- (void)rewardedVideoAdDidClose:(id<ATBURewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"ATTTRewardedVideoCustomEvent::rewardedVideoAdDidClose:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdCloseRewarded:self.rewardGranted];
}

- (void)rewardedVideoAdDidClick:(id<ATBURewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"ATTTRewardedVideoCustomEvent::rewardedVideoAdDidClick:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdClick];
}

- (void)rewardedVideoAd:(id<ATBURewardedVideoAd>)rewardedVideoAd didFailWithError:(NSError *)error {
    [ATLogger logMessage:@"ATTTRewardedVideoCustomEvent::rewardedVideoAd:didFailWithError:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoadFailed:error];
}

- (void)rewardedVideoAdDidPlayFinish:(id<ATBURewardedVideoAd>)rewardedVideoAd didFailWithError:(NSError *)error {
    [ATLogger logMessage:@"ATTTRewardedVideoCustomEvent::rewardedVideoAdDidPlayFinish:didFailWithError:" type:ATLogTypeExternal];
    if (error == nil) {
        [self trackRewardedVideoAdVideoEnd];
    } else {
        [self trackRewardedVideoAdPlayEventWithError:error];
    }
}

- (void)rewardedVideoAdServerRewardDidSucceed:(id<ATBURewardedVideoAd>)rewardedVideoAd verify:(BOOL)verify {
    [ATLogger logMessage:@"ATTTRewardedVideoCustomEvent::rewardedVideoAdServerRewardDidSucceed:verify:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdRewarded];
}

- (void)rewardedVideoAdServerRewardDidFail:(id<ATBURewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"ATTTRewardedVideoCustomEvent::rewardedVideoAdServerRewardDidFail:" type:ATLogTypeExternal];
    self.rewardGranted = NO;
}


#pragma mark - nativeExpressRVDelegate
- (void)nativeExpressRewardedVideoAdDidLoad:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"ATTTNativeExpressRewardedVideoCustomEvent::nativeExpressRewardedVideoAdDidLoad:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoaded:rewardedVideoAd adExtra:nil];
}

- (void)nativeExpressRewardedVideoAd:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    [ATLogger logMessage:@"ATTTNativeExpressRewardedVideoCustomEvent::nativeExpressRewardedVideoAdDidLoad:didFailWithError:" type:ATLogTypeExternal];
    if (!_isFailed) {
        [self trackRewardedVideoAdLoadFailed:error];
        _isFailed = true;
    }
}

- (void)nativeExpressRewardedVideoAdDidDownLoadVideo:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"ATTTNativeExpressRewardedVideoCustomEvent::nativeExpressRewardedVideoAdDidDownLoadVideo:" type:ATLogTypeExternal];
}

- (void)nativeExpressRewardedVideoAdViewRenderSuccess:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"ATTTNativeExpressRewardedVideoCustomEvent::nativeExpressRewardedVideoAdViewRenderSuccess:" type:ATLogTypeExternal];
}

- (void)nativeExpressRewardedVideoAdViewRenderFail:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd error:(NSError *_Nullable)error {
    [ATLogger logMessage:@"ATTTNativeExpressRewardedVideoCustomEvent::nativeExpressRewardedVideoAdViewRenderFail:didFailWithError:" type:ATLogTypeExternal];
    if (!_isFailed) {
        [self trackRewardedVideoAdLoadFailed:error];
        _isFailed = true;
    }
}

- (void)nativeExpressRewardedVideoAdWillVisible:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd {
    
}

- (void)nativeExpressRewardedVideoAdDidVisible:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"ATTTNativeExpressRewardedVideoCustomEvent::nativeExpressRewardedVideoAdDidVisible:" type:ATLogTypeExternal];
       [self trackRewardedVideoAdShow];
       [self trackRewardedVideoAdVideoStart];
}

- (void)nativeExpressRewardedVideoAdWillClose:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd {
    
}

- (void)nativeExpressRewardedVideoAdDidClose:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"ATTTNativeExpressRewardedVideoCustomEvent::nativeExpressRewardedVideoAdDidClose:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdCloseRewarded:self.rewardGranted];
}

- (void)nativeExpressRewardedVideoAdDidClick:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"ATTTNativeExpressRewardedVideoCustomEvent::nativeExpressRewardedVideoAdDidClick:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdClick];
}

- (void)nativeExpressRewardedVideoAdDidClickSkip:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd {
    
}

- (void)nativeExpressRewardedVideoAdDidPlayFinish:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    [ATLogger logMessage:@"ATTTNativeExpressRewardedVideoCustomEvent::nativeExpressRewardedVideoAdDidPlayFinish:didFailWithError:" type:ATLogTypeExternal];
    if (error == nil) {
        [self trackRewardedVideoAdVideoEnd];
    } else {
        [self trackRewardedVideoAdPlayEventWithError:error];
    }
}

- (void)nativeExpressRewardedVideoAdServerRewardDidSucceed:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd verify:(BOOL)verify {
    [ATLogger logMessage:@"ATTTNativeExpressRewardedVideoCustomEvent::nativeExpressRewardedVideoAdServerRewardDidSucceed:verify:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdRewarded];
}

- (void)nativeExpressRewardedVideoAdServerRewardDidFail:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"ATTTNativeExpressRewardedVideoCustomEvent::nativeExpressRewardedVideoAdServerRewardDidFail:" type:ATLogTypeExternal];
       self.rewardGranted = NO;
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"slot_id"];
//    return extra;
//}
@end
