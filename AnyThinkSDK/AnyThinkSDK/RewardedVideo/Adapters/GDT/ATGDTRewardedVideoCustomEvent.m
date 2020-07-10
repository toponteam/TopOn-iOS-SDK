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
        [self handleAssets:@{kRewardedVideoAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kRewardedVideoAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:rewardedVideoAd}];
    }
}

- (void)gdt_rewardVideoAdWillVisible:(id<ATGDTRewardVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"GDTRewardedVideo::gdt_rewardVideoAdWillVisible:" type:ATLogTypeExternal];
}

- (void)gdt_rewardVideoAdDidExposed:(id<ATGDTRewardVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"GDTRewardedVideo::gdt_rewardVideoAdDidExposed:" type:ATLogTypeExternal];
    [self trackShow];
    [self trackVideoStart];
    
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)gdt_rewardVideoAdDidClose:(id<ATGDTRewardVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"GDTRewardedVideo::gdt_rewardVideoAdDidClose:" type:ATLogTypeExternal];
    [self handleClose];
    [self saveVideoCloseEventRewarded:_rewarded];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
        [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:[self delegateExtra]];
    }
}

- (void)gdt_rewardVideoAdDidClicked:(id<ATGDTRewardVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"GDTRewardedVideo::gdt_rewardVideoAdDidClicked:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)gdt_rewardVideoAd:(id<ATGDTRewardVideoAd>)rewardedVideoAd didFailWithError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"GDTRewardedVideo::gdt_rewardVideoAd:didFailWithError:%@", error] type:ATLogTypeExternal];
    if (_loaded) {
        NSError *playError = [error isKindOfClass:[NSError class]] ? error : [NSError errorWithDomain:@"com.anythink.RewardedVideo" code:100001 userInfo:@{NSLocalizedDescriptionKey:@"AT SDK has failed to play rewarded video", NSLocalizedFailureReasonErrorKey:@"GDT rewarded video has failed to play"}];
        [self saveVideoPlayEventWithError:error];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForPlacementID:error:extra:)]) { [self.delegate rewardedVideoDidFailToPlayForPlacementID:self.rewardedVideo.placementModel.placementID error:playError extra:[self delegateExtra]]; }
    } else {
        [self handleLoadingFailure:error];
    }
}

- (void)gdt_rewardVideoAdDidRewardEffective:(id<ATGDTRewardVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"GDTRewardedVideo::gdt_rewardVideoAdDidRewardEffective:" type:ATLogTypeExternal];
    self.rewardGranted = YES;
    _rewarded = YES;
    if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){
        [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)gdt_rewardVideoAdDidPlayFinish:(id<ATGDTRewardVideoAd>)rewardedVideoAd {
    [ATLogger logMessage:@"GDTRewardedVideo::gdt_rewardVideoAdDidPlayFinish:" type:ATLogTypeExternal];
    [self trackVideoEnd];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"unit_id"];
    return extra;
}
@end
