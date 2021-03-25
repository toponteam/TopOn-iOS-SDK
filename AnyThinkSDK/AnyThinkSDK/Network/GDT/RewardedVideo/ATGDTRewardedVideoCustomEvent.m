//
//  ATGDTRewardedVideoCustomEvent.m
//  AnyThinkGDTRewardedVideoAdapter
//
//  Created by Martin Lau on 2018/12/11.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATGDTRewardedVideoCustomEvent.h"
#import "Utilities.h"
#import "ATRewardedVideoManager.h"

@interface ATGDTRewardedVideoCustomEvent()
@property(nonatomic, readonly) BOOL rewarded;
@property(nonatomic, readonly) BOOL loaded;
@end
@implementation ATGDTRewardedVideoCustomEvent
- (void)gdt_rewardVideoAdDidLoad:(id<ATGDTRewardVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"GDTRewardedVideo::gdt_rewardVideoAdDidLoad:" type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

- (void)gdt_rewardVideoAdVideoDidLoad:(id<ATGDTRewardVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"GDTRewardedVideo::gdt_rewardVideoAdVideoDidLoad:" type:ATLogTypeExternal];
    if (!_loaded) {
        _loaded = YES;
        [self trackRewardedVideoAdLoaded:rewardedVideoAd adExtra:nil];
    }
}

- (void)gdt_rewardVideoAdWillVisible:(id<ATGDTRewardVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"GDTRewardedVideo::gdt_rewardVideoAdWillVisible:" type:ATLogTypeExternal];
}

- (void)gdt_rewardVideoAdDidExposed:(id<ATGDTRewardVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"GDTRewardedVideo::gdt_rewardVideoAdDidExposed:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

- (void)gdt_rewardVideoAdDidClose:(id<ATGDTRewardVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"GDTRewardedVideo::gdt_rewardVideoAdDidClose:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdCloseRewarded:_rewarded];
}

- (void)gdt_rewardVideoAdDidClicked:(id<ATGDTRewardVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"GDTRewardedVideo::gdt_rewardVideoAdDidClicked:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdClick];
}

- (void)gdt_rewardVideoAd:(id<ATGDTRewardVideoAd>)rewardedVideoAd didFailWithError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"GDTRewardedVideo::gdt_rewardVideoAd:didFailWithError:%@", error] type:ATLogTypeExternal];
    if (_loaded) {
        NSError *playError = [error isKindOfClass:[NSError class]] ? error : [NSError errorWithDomain:@"com.anythink.RewardedVideo" code:100001 userInfo:@{NSLocalizedDescriptionKey:@"AT SDK has failed to play rewarded video", NSLocalizedFailureReasonErrorKey:@"GDT rewarded video has failed to play"}];
        [self trackRewardedVideoAdPlayEventWithError:playError];
    } else {
        [self trackRewardedVideoAdLoadFailed:error];
    }
}

- (void)gdt_rewardVideoAdDidRewardEffective:(id<ATGDTRewardVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"GDTRewardedVideo::gdt_rewardVideoAdDidRewardEffective:" type:ATLogTypeExternal];
    _rewarded = YES;
    [self trackRewardedVideoAdRewarded];
}

- (void)gdt_rewardVideoAdDidPlayFinish:(id<ATGDTRewardVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"GDTRewardedVideo::gdt_rewardVideoAdDidPlayFinish:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdVideoEnd];
}

#pragma mark - NativeExpressRewardVideo
- (void)gdt_nativeExpressRewardVideoAdDidLoad:(id<ATGDTNativeExpressRewardVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"GDTRewardedVideo::gdt_nativeExpressRewardVideoAdDidLoad:" type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

- (void)gdt_nativeExpressRewardVideoAdVideoDidLoad:(id<ATGDTNativeExpressRewardVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"GDTRewardedVideo::gdt_nativeExpressRewardVideoAdVideoDidLoad:" type:ATLogTypeExternal];
    if (!_loaded) {
        _loaded = YES;
        [self trackRewardedVideoAdLoaded:rewardedVideoAd adExtra:nil];
    }
}

- (void)gdt_nativeExpressRewardVideoAdWillVisible:(id<ATGDTNativeExpressRewardVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"GDTRewardedVideo::gdt_nativeExpressRewardVideoAdWillVisible:" type:ATLogTypeExternal];
}

- (void)gdt_nativeExpressRewardVideoAdDidExposed:(id<ATGDTNativeExpressRewardVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"GDTRewardedVideo::gdt_nativeExpressRewardVideoAdDidExposed:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

- (void)gdt_nativeExpressRewardVideoAdDidClose:(id<ATGDTNativeExpressRewardVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"GDTRewardedVideo::gdt_nativeExpressRewardVideoAdDidClose:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdCloseRewarded:_rewarded];
}

- (void)gdt_nativeExpressRewardVideoAdDidClicked:(id<ATGDTNativeExpressRewardVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"GDTRewardedVideo::gdt_nativeExpressRewardVideoAdDidClicked:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdClick];
}

- (void)gdt_nativeExpressRewardVideoAd:(id<ATGDTNativeExpressRewardVideoAd>)rewardedVideoAd didFailWithError:(NSError *)error {
    [ATLogger logMessage:@"GDTRewardedVideo::gdt_nativeExpressRewardVideoAd:" type:ATLogTypeExternal];
    if (_loaded) {
        NSError *playError = [error isKindOfClass:[NSError class]] ? error : [NSError errorWithDomain:@"com.anythink.RewardedVideo" code:100001 userInfo:@{NSLocalizedDescriptionKey:@"AT SDK has failed to play rewarded video", NSLocalizedFailureReasonErrorKey:@"GDT rewarded video has failed to play"}];
        [self trackRewardedVideoAdPlayEventWithError:playError];
    } else {
        [self trackRewardedVideoAdLoadFailed:error];
    }
}

- (void)gdt_nativeExpressRewardVideoAdDidRewardEffective:(id<ATGDTNativeExpressRewardVideoAd>)rewardedVideoAd info:(NSDictionary *)info{
    [ATLogger logMessage:[NSString stringWithFormat:@"GDTRewardedVideo::gdt_nativeExpressRewardVideoAdDidRewardEffective:info:%@",info] type:ATLogTypeExternal];
    _rewarded = YES;
    [self trackRewardedVideoAdRewarded];
}

- (void)gdt_nativeExpressRewardVideoAdDidPlayFinish:(id<ATGDTNativeExpressRewardVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"GDTRewardedVideo::gdt_nativeExpressRewardVideoAdDidPlayFinish:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdVideoEnd];
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
