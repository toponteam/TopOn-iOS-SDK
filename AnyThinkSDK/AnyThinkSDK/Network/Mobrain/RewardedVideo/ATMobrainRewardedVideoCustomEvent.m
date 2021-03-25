//
//  ATMobrainRewardedVideoCustomEvent.m
//  AnyThinkMobrainAdapter
//
//  Created by Topon on 2/1/21.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import "ATMobrainRewardedVideoCustomEvent.h"
#import "Utilities.h"

@implementation ATMobrainRewardedVideoCustomEvent

/**
 This method is called when video ad material loaded successfully.
 */
- (void)rewardedVideoAdDidLoad:(id<ATABURewardedVideoAd>_Nonnull)rewardedVideoAd {
    [ATLogger logMessage:@"ATMobrainRewardedVideo::rewardedVideoAdDidLoad" type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoaded:rewardedVideoAd adExtra:nil];
}

/**
 This method is called when video ad materia failed to load.
 @param error : the reason of error
 */
- (void)rewardedVideoAd:(id<ATABURewardedVideoAd>_Nonnull)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    [ATLogger logError:@"ATMobrainRewardedVideo::didFailWithError" type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoadFailed:error];
}

/**
 This method is called when cached successfully.
 */
- (void)rewardedVideoAdDidDownLoadVideo:(id<ATABURewardedVideoAd>_Nonnull)rewardedVideoAd {
    [ATLogger logMessage:@"ATMobrainRewardedVideo::rewardedVideoAdDidDownLoadVideo" type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

/**
 This method is called when a ExpressAdView failed to render.
 Only for expressAd,when hasExpressAdGot = yes
 @param error : the reason of error
 */
- (void)rewardedVideoAdViewRenderFail:(id<ATABURewardedVideoAd>_Nonnull)rewardedVideoAd error:(NSError * __nullable)error {
    [ATLogger logMessage:@"ATMobrainRewardedVideo::rewardedVideoAdViewRenderFail" type:ATLogTypeExternal];
    [self trackRewardedVideoAdPlayEventWithError:error];
}

/**
 This method is called when video ad slot has been shown.
 */
- (void)rewardedVideoAdDidVisible:(id<ATABURewardedVideoAd>_Nonnull)rewardedVideoAd {
    [ATLogger logMessage:@"ATMobrainRewardedVideo::rewardedVideoAdDidVisible" type:ATLogTypeExternal];
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

/**
 This method is called when video ad is clicked.
 */
- (void)rewardedVideoAdDidClick:(id<ATABURewardedVideoAd>_Nonnull)rewardedVideoAd {
    [ATLogger logMessage:@"ATMobrainRewardedVideo::rewardedVideoAdDidClick" type:ATLogTypeExternal];
    [self trackRewardedVideoAdClick];
}

/**
 This method is called when video ad is skiped.
 */
- (void)rewardedVideoAdDidSkip:(id<ATABURewardedVideoAd> _Nonnull)rewardedVideoAd {
    [ATLogger logMessage:@"ATMobrainRewardedVideo::rewardedVideoAdDidSkip" type:ATLogTypeExternal];
}
/**
 This method is called when video ad is closed.
 */
- (void)rewardedVideoAdDidClose:(id<ATABURewardedVideoAd>_Nonnull)rewardedVideoAd {
    [ATLogger logMessage:@"ATMobrainRewardedVideo::rewardedVideoAdDidClose" type:ATLogTypeExternal];
    [self trackRewardedVideoAdVideoEnd];
    [self trackRewardedVideoAdCloseRewarded:self.rewardGranted];
}

/**
 Server verification which is requested asynchronously is succeeded.include C2C and S2S methods .
 @param verify :return YES when return value is 2000.
 */
- (void)rewardedVideoAdServerRewardDidSucceed:(id<ATABURewardedVideoAd>_Nonnull)rewardedVideoAd verify:(BOOL)verify {
    [ATLogger logMessage:@"ATMobrainRewardedVideo::rewardedVideoAdServerRewardDidSucceed" type:ATLogTypeExternal];
    if (verify) {
        [self trackRewardedVideoAdRewarded];
    }
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"];
}

- (NSDictionary *)networkCustomInfo {
    
    id<ATABURewardedVideoAd> rvAd = self.rewardedVideo.customObject;
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    [extra AT_setDictValue:@([rvAd getAdNetworkPlaformId]) key:@"network_id"];
    [extra AT_setDictValue:[rvAd getAdNetworkRitId] key:@"network_unit_id"];
    [extra AT_setDictValue:[rvAd getPreEcpm] key:@"network_ecpm"];

    return extra;
}

@end
