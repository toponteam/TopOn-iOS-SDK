//
//  ATTapjoyInterstitialCustomEvent.m
//  AnyThinkTapjoyInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/9.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATTapjoyInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"

@implementation ATTapjoyInterstitialCustomEvent
#pragma mark - placement
- (void)requestDidSucceed:(id<ATTJPlacement>)placement {
    [ATLogger logMessage:[NSString stringWithFormat:@"TapjoyInterstitial: requestDidSucceed"]  type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

- (void)requestDidFail:(id<ATTJPlacement>)placement error:(NSError*)error {
    [ATLogger logError:[NSString stringWithFormat:@"TapjoyInterstitial: requestDidFail, error:%@", error]  type:ATLogTypeExternal];
    [self trackInterstitialAdLoadFailed:error];
}

- (void)contentIsReady:(id<ATTJPlacement>)placement {
    [ATLogger logMessage:[NSString stringWithFormat:@"TapjoyInterstitial: contentIsReady"]  type:ATLogTypeExternal];
//    [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kAdAssetsCustomObjectKey:placement}];
    [self trackInterstitialAdLoaded:placement adExtra:nil];
}

- (void)contentDidAppear:(id<ATTJPlacement>)placement {
    [ATLogger logMessage:[NSString stringWithFormat:@"TapjoyInterstitial: contentDidAppear"]  type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
}

- (void)contentDidDisappear:(id<ATTJPlacement>)placement {
    [ATLogger logMessage:[NSString stringWithFormat:@"TapjoyInterstitial: contentDidDisappear"]  type:ATLogTypeExternal];
    [self trackInterstitialAdClose];
}

- (void)placement:(id<ATTJPlacement>)placement didRequestPurchase:(id<ATTJActionRequest>)request productId:(NSString*)productId {
    //
}

- (void)placement:(id<ATTJPlacement>)placement didRequestReward:(id<ATTJActionRequest>)request itemId:(NSString*)itemId quantity:(int)quantity {
    //
}
#pragma mark - video
- (void)videoDidStart:(id<ATTJPlacement>)placement {
    [ATLogger logMessage:[NSString stringWithFormat:@"TapjoyInterstitial: videoDidStart"]  type:ATLogTypeExternal];
    [self trackInterstitialAdVideoStart];
}

- (void)videoDidComplete:(id<ATTJPlacement>)placement {
    [ATLogger logMessage:[NSString stringWithFormat:@"TapjoyInterstitial: videoDidComplete"]  type:ATLogTypeExternal];
    [self trackInterstitialAdVideoEnd];
}

- (void)videoDidFail:(id<ATTJPlacement>)placement error:(NSString*)errorMsg {
    [ATLogger logError:[NSString stringWithFormat:@"TapjoyInterstitial: videoDidFail, msg:%@", errorMsg]  type:ATLogTypeExternal];
    NSError *error = [NSError errorWithDomain:@"Tapjoy interstitial ad video playing failed." code:10000 userInfo:@{NSLocalizedFailureReasonErrorKey:errorMsg, NSLocalizedDescriptionKey:errorMsg}];
    [self trackInterstitialAdDidFailToPlayVideo:error];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"placement_name"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"placement_name"];
//    return extra;
//}
@end
