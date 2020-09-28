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
    [self trackRewardedVideoAdLoadFailed:error];
}

-(void)oguryAdsOptinVideoAdLoaded {
    [ATLogger logMessage:@"OguryRewardedVideo::oguryAdsOptinVideoAdLoaded:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoaded:self.OguryAd adExtra:nil];
}

-(void)oguryAdsOptinVideoAdNotLoaded {

}

-(void)oguryAdsOptinVideoAdDisplayed {
    [ATLogger logMessage:@"OguryRewardedVideo::oguryAdsOptinVideoAdDisplayed:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

-(void)oguryAdsOptinVideoAdClosed {
    [self trackRewardedVideoAdVideoEnd];
    [ATLogger logMessage:@"OguryRewardedVideo::oguryAdsOptinVideoAdClosed:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdCloseRewarded:self.rewardGranted];
}

-(void)oguryAdsOptinVideoAdRewarded:(id<ATOGARewardItem>)item {
    [self trackRewardedVideoAdRewarded];
}

-(void)oguryAdsOptinVideoAdError:(ATOguryAdsErrorType)errorType {
    NSString *desc = OguryRVStatusTypeStringMap[errorType];
    NSError *error = [NSError errorWithDomain:desc code:errorType userInfo:nil];
    [ATLogger logError:[NSString stringWithFormat:@"OguryInterstitial::oguryAdsInterstitialAdError:%@", error] type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoadFailed:error];
}

NSString *OguryRVStatusTypeStringMap[] = {
    [OguryAdsErrorLoadFailed] = @"OguryAdsErrorLoadFailed",
    [OguryAdsErrorNoInternetConnection] = @"OguryAdsErrorNoInternetConnection",
    [OguryAdsErrorAdDisable] = @"OguryAdsErrorAdDisable",
    [OguryAdsErrorProfigNotSynced] = @"OguryAdsErrorProfigNotSynced",
    [OguryAdsErrorAdExpired] = @"OguryAdsErrorAdExpired",
    [OguryAdsErrorSdkInitNotCalled] = @"OguryAdsErrorSdkInitNotCalled"
};

- (NSString *)networkUnitId {
    return self.serverInfo[@"unit_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"unit_id"];
//    return extra;
//}

@end
