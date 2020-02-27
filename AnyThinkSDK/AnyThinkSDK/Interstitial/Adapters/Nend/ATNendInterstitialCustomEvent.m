//
//  ATNendInterstitialCustomEvent.m
//  AnyThinkNendInterstitialAdapter
//
//  Created by Martin Lau on 2019/4/18.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATNendInterstitialCustomEvent.h"
#import "ATNendInterstitialAdapter.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
@implementation ATNendInterstitialCustomEvent
-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(instancetype) initWithUnitID:(NSString *)unitID customInfo:(NSDictionary *)customInfo {
    self = [super initWithUnitID:unitID customInfo:customInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadedNotification:) name:kATNendInterstitialLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClickNotification:) name:kATNendInterstitialClickNotification object:nil];
    }
    return self;
}

-(void) handleLoadedNotification:(NSNotification*)notification {
    NSString *spotID = notification.userInfo[kATNendInterstitialNotificationUserInfoSpotIDKey];
    if ([spotID isEqualToString:self.unitID]) {
        NSInteger status = [notification.userInfo[kATNendInterstitialNotificationUserInfoStatusKey] integerValue];
        if (status == 0) {
            [self handleAssets:@{kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kInterstitialAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:self.unitID != nil ? self.unitID : @""}];
        } else {
            [self handleLoadingFailure:[NSError errorWithDomain:@"com.anythink.NendInterstitialLoading" code:status userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load interstitial ad", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Nend interstitial has failed to load interstitial ad with error code:%ld", status]}]];
        }
    }
}

-(void) handleClickNotification:(NSNotification*)notification {
    if (self.interstitial != nil) {
        NSString *spotID = notification.userInfo[kATNendInterstitialNotificationUserInfoSpotIDKey];
        if ([spotID isEqualToString:self.unitID]) {
            NSInteger status = [notification.userInfo[kATNendInterstitialNotificationUserInfoClickTypeKey] integerValue];
            if (status == 0) {//Click
                [self handleClick];
            } else if (status == 1) {//Close
                [self handleClose];
            }
        }
    }
}

-(void) handleClick {
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
        [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}

-(void) handleClose {
    [super handleClose];
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) {
        [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}

-(void) handleShowSuccess {
    [self trackShow];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}]; }
}

-(void) handleShowFailure:(NSInteger)code {
    if ([self.delegate respondsToSelector:@selector(interstitialFailedToShowForPlacementID:error:extra:)]) {
        [self.delegate interstitialFailedToShowForPlacementID:self.interstitial.placementModel.placementID error:[NSError errorWithDomain:@"com.anythink.NendInterstitialShow" code:code userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to show interstitial.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Nend has failed to show interstitial with code:%ld", code]}] extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}

#pragma mark - interstitial video
- (void)nadInterstitialVideoAdDidReceiveAd:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd {
    [ATLogger logMessage:@"NendInterstitialVideo::nadInterstitialVideoAdDidReceiveAd:" type:ATLogTypeExternal];
    [self handleAssets:@{kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kInterstitialAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:nadInterstitialVideoAd}];
}

- (void)nadInterstitialVideoAd:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd didFailToLoadWithError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"NendInterstitialVideo::nadInterstitialVideoAd:didFailToLoadWithError:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

- (void)nadInterstitialVideoAdDidFailedToPlay:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd {
    [ATLogger logMessage:@"NendInterstitialVideo::nadInterstitialVideoAdDidFailedToPlay:" type:ATLogTypeExternal];
    if ([self.delegate respondsToSelector:@selector(interstitialDidFailToPlayVideoForPlacementID:error:extra:)]) {
        [self.delegate interstitialDidFailToPlayVideoForPlacementID:self.interstitial.placementModel.placementID error:[NSError errorWithDomain:@"com.anythink.NendInterstitialVideoPlayingFailure" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to play video for interstitial", NSLocalizedFailureReasonErrorKey:@"NendInterstitialVideo failed to play video"}] extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}

- (void)nadInterstitialVideoAdDidOpen:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd {
    [ATLogger logMessage:@"NendInterstitialVideo::nadInterstitialVideoAdDidOpen:" type:ATLogTypeExternal];
    [self handleShowSuccess];
}

- (void)nadInterstitialVideoAdDidClose:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd {
    [ATLogger logMessage:@"NendInterstitialVideo::nadInterstitialVideoAdDidClose:" type:ATLogTypeExternal];
    [self handleClose];
}

- (void)nadInterstitialVideoAdDidStartPlaying:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd {
    [ATLogger logMessage:@"NendInterstitialVideo::nadInterstitialVideoAdDidStartPlaying:" type:ATLogTypeExternal];
    [self trackVideoStart];
    if ([self.delegate respondsToSelector:@selector(interstitialDidStartPlayingVideoForPlacementID:extra:)]) {
        [self.delegate interstitialDidStartPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}

- (void)nadInterstitialVideoAdDidStopPlaying:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd {
    [ATLogger logMessage:@"NendInterstitialVideo::nadInterstitialVideoAdDidStopPlaying:" type:ATLogTypeExternal];
}

- (void)nadInterstitialVideoAdDidCompletePlaying:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd {
    [ATLogger logMessage:@"NendInterstitialVideo::nadInterstitialVideoAdDidCompletePlaying:" type:ATLogTypeExternal];
    [self trackVideoEnd];
    if ([self.delegate respondsToSelector:@selector(interstitialDidEndPlayingVideoForPlacementID:extra:)]) {
        [self.delegate interstitialDidEndPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}

- (void)nadInterstitialVideoAdDidClickAd:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd {
    [ATLogger logMessage:@"NendInterstitialVideo::nadInterstitialVideoAdDidClickAd:" type:ATLogTypeExternal];
    [self handleClick];
}

- (void)nadInterstitialVideoAdDidClickInformation:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd {
    [ATLogger logMessage:@"NendInterstitialVideo::nadInterstitialVideoAdDidClickInformation:" type:ATLogTypeExternal];
}

#pragma mark - interstitial video
-(void) completeFullBoardLoad:(id<ATNADFullBoard>)fullBoard errorCode:(NSInteger)error {
    if (fullBoard != nil) {
        [self handleAssets:@{kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kInterstitialAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:fullBoard}];
    } else {
        [self handleLoadingFailure:[NSError errorWithDomain:@"com.anythink.NendFullBoardLoading" code:error userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load interstitial", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"NADFullBoard has failed to load ad with error code:%ld", error]}]];
    }
}

- (void)NADFullBoardDidShowAd:(id<ATNADFullBoard>)ad {
    [ATLogger logMessage:@"NendInterstitialFullBoard::NADFullBoardDidShowAd:" type:ATLogTypeExternal];
    [self handleShowSuccess];
}

- (void)NADFullBoardDidDismissAd:(id<ATNADFullBoard>)ad {
    [ATLogger logMessage:@"NendInterstitialFullBoard::NADFullBoardDidDismissAd:" type:ATLogTypeExternal];
    [self handleClose];
}

- (void)NADFullBoardDidClickAd:(id<ATNADFullBoard>)ad {
    [ATLogger logMessage:@"NendInterstitialFullBoard::NADFullBoardDidClickAd:" type:ATLogTypeExternal];
    [self handleClick];
}
@end
