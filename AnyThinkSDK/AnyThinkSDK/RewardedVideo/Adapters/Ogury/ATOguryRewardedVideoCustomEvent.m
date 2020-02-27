//
//  ATOguryRewardedVideoCustomEvent.m
//  AnyThinkOguryRewardedVideoAdapter
//
//  Created by Topon on 2019/11/27.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import "ATOguryRewardedVideoCustomEvent.h"
#import "Utilities.h"
#import "ATRewardedVideoManager.h"

@implementation ATOguryRewardedVideoCustomEvent

-(void)oguryAdsOptinVideoAdAvailable {
    [ATLogger logMessage:@"OguryRewardedVideo::oguryAdsOptinVideoAdAvailable:" type:ATLogTypeExternal];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

-(void)oguryAdsOptinVideoAdNotAvailable {
    NSString *desc = @"oguryAdsOptinVideoAdNotAvailable";
    NSError *error = [NSError errorWithDomain:desc code:0 userInfo:nil];
    [ATLogger logError:[NSString stringWithFormat:@"OguryInterstitial::oguryAdsOptinVideoAdNotAvailable:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

-(void)oguryAdsOptinVideoAdLoaded {
    [ATLogger logMessage:@"OguryRewardedVideo::oguryAdsOptinVideoAdLoaded:" type:ATLogTypeExternal];
    NSMutableDictionary *assets = [NSMutableDictionary dictionaryWithDictionary:@{kRewardedVideoAssetsUnitIDKey:self.unitID, kAdAssetsCustomObjectKey:self.OguryAd, kRewardedVideoAssetsCustomEventKey:self}];
    [self handleAssets:assets];
}

-(void)oguryAdsOptinVideoAdNotLoaded {

}

-(void)oguryAdsOptinVideoAdDisplayed {
    [ATLogger logMessage:@"OguryRewardedVideo::oguryAdsOptinVideoAdDisplayed:" type:ATLogTypeExternal];
    [self trackShow];
    [self trackVideoStart];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
}

-(void)oguryAdsOptinVideoAdClosed {
    [self trackVideoEnd];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
    [ATLogger logMessage:@"OguryRewardedVideo::oguryAdsOptinVideoAdClosed:" type:ATLogTypeExternal];
    [self handleClose];
    [self saveVideoCloseEventRewarded:self.rewardGranted];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
        [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
}

-(void)oguryAdsOptinVideoAdRewarded:(id<ATOGARewardItem>)item {
    self.rewardGranted = YES;
    if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){
        [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price)}];
    }
}

-(void)oguryAdsOptinVideoAdError:(ATOguryAdsErrorType)errorType {
    NSString *desc = OguryRVStatusTypeStringMap[errorType];
    NSError *error = [NSError errorWithDomain:desc code:errorType userInfo:nil];
    [ATLogger logError:[NSString stringWithFormat:@"OguryInterstitial::oguryAdsInterstitialAdError:%@", error] type:ATLogTypeExternal];
    [self handleLoadingFailure:error];
}

NSString *OguryRVStatusTypeStringMap[] = {
    [OguryAdsErrorLoadFailed] = @"OguryAdsErrorLoadFailed",
    [OguryAdsErrorNoInternetConnection] = @"OguryAdsErrorNoInternetConnection",
    [OguryAdsErrorAdDisable] = @"OguryAdsErrorAdDisable",
    [OguryAdsErrorProfigNotSynced] = @"OguryAdsErrorProfigNotSynced",
    [OguryAdsErrorAdExpired] = @"OguryAdsErrorAdExpired",
    [OguryAdsErrorSdkInitNotCalled] = @"OguryAdsErrorSdkInitNotCalled"
};

@end
