//
//  ATAdManager+RewardedVideo.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 05/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdManager+RewardedVideo.h"
#import "ATAdManager+Internal.h"
#import "ATPlacementModel.h"
#import "ATRewardedVideo.h"
#import "ATRewardedVideoAdapter.h"
#import "ATRewardedVideoManager.h"
#import "ATPlacementSettingManager.h"
#import <objc/runtime.h>
#import "UIViewController+AdObjectAssociation.h"
#import "Utilities.h"
#import "ATGeneralAdAgentEvent.h"
#import "ATCapsManager.h"
#import "ATRewardedVideoCustomEvent.h"
NSString *const kATAdLoadingExtraKeywordKey = @"keyword";
NSString *const kATAdLoadingExtraUserDataKeywordKey = @"user_data_keyword";
NSString *const kATAdLoadingExtraUserIDKey = @"userID";
NSString *const kATAdLoadingExtraLocationKey = @"location";
NSString *const kATAdLoadingExtraMediaExtraKey = @"media_ext";

NSString *const kATRewardedVideoCallbackExtraAdsourceIDKey = @"adsource_id";
NSString *const kATRewardedVideoCallbackExtraNetworkIDKey = @"network_firm_id";
NSString *const kATRewardedVideoCallbackExtraIsHeaderBidding = @"adsource_isHeaderBidding";
NSString *const kATRewardedVideoCallbackExtraPrice = @"adsource_price";
NSString *const kATRewardedVideoCallbackExtraPriority = @"adsource_index";

@implementation ATAdManager (RewardedVideo)
-(BOOL) rewardedVideoReadyForPlacementID:(NSString*)placementID {
    BOOL ready = [self rewardedVideoReadyForPlacementID:placementID scene:nil caller:ATAdManagerReadyAPICallerReady rewardedVidel:nil];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[ATGeneralAdAgentEvent apiLogInfoWithPlacementID:placementID format:ATAdFormatRewardedVideo api:kATAPIIsReady]];
    info[@"result"] = ready ? @"YES" : @"NO";
    [ATLogger logMessage:[NSString stringWithFormat:@"\nAPI invocation info:\n*****************************\n%@ \n*****************************", info] type:ATLogTypeTemporary];
    return ready;
}

-(BOOL) rewardedVideoReadyForPlacementID:(NSString*)placementID scene:(NSString*)scene caller:(ATAdManagerReadyAPICaller)caller rewardedVidel:(ATRewardedVideo *__strong *)rewardedVideo {
    return [[ATAdManager sharedManager] adReadyForPlacementID:placementID scene:scene caller:caller context:^BOOL(NSDictionary *__autoreleasing *extra) {
        ATRewardedVideo *localRV = [[ATRewardedVideoManager sharedManager] rewardedVideoForPlacementID:placementID invalidateStatus:caller == ATAdManagerReadyAPICallerShow extra:extra];
        if (rewardedVideo != nil) { *rewardedVideo = localRV; }
        return localRV != nil;
    }];
}

- (ATCheckLoadModel*)checkRewardedVideoLoadStatusForPlacementID:(NSString *)placementID {
    ATRewardedVideo *rewardedVideo = nil;
    ATCheckLoadModel *checkLoadModel = [[ATCheckLoadModel alloc] init];
    if ([[ATWaterfallManager sharedManager] loadingAdForPlacementID:placementID]) {
        checkLoadModel.isLoading = YES;
    }
    if ([self rewardedVideoReadyForPlacementID:placementID scene:nil caller:ATAdManagerReadyAPICallerReady rewardedVidel:&rewardedVideo]) {
        checkLoadModel.isReady = YES;
        NSMutableDictionary *delegateExtra = [NSMutableDictionary dictionaryWithDictionary:[rewardedVideo.customEvent delegateExtra]];
        if ([delegateExtra containsObjectForKey:kATADDelegateExtraIDKey]) { [delegateExtra removeObjectForKey:kATADDelegateExtraIDKey]; }
        checkLoadModel.adOfferInfo = delegateExtra;
    }
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[ATGeneralAdAgentEvent apiLogInfoWithPlacementID:placementID format:ATAdFormatInterstitial api:kATAPICheckLoadStatus]];
    info[@"result"] = @{@"isLoading":checkLoadModel.isLoading ? @"YES" : @"NO", @"isReady":checkLoadModel.isReady ? @"YES" : @"NO", @"adOfferInfo":![Utilities isBlankDictionary:checkLoadModel.adOfferInfo] ? checkLoadModel.adOfferInfo : @{}};
    [ATLogger logMessage:[NSString stringWithFormat:@"\nAPI invocation info:\n*****************************\n%@ \n*****************************", info] type:ATLogTypeTemporary];
    return checkLoadModel;
}

-(void) showRewardedVideoWithPlacementID:(NSString*)placementID scene:(NSString*)scene inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    [ATLogger logMessage:[NSString stringWithFormat:@"\nAPI invocation info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent apiLogInfoWithPlacementID:placementID format:1 api:kATAPIShow]] type:ATLogTypeTemporary];
    NSString *showingScene = nil;
    if ([Utilities validateShowingScene:scene]) {
        showingScene = scene;
    } else {
        NSLog(@"Invalid scene is passed:%@, scene should be a string of 14 characters from '_', [0-9], [a-z], [A-Z]", scene);
    }
    NSError *error = nil;
    ATRewardedVideo *rewardedVideo = nil;
    if ([self rewardedVideoReadyForPlacementID:placementID scene:showingScene caller:ATAdManagerReadyAPICallerShow rewardedVidel:&rewardedVideo]) {
        rewardedVideo.scene = showingScene;
        viewController.ad = rewardedVideo;
        [rewardedVideo.customEvent saveShowAPIContext];
        [rewardedVideo.unitGroup.adapterClass showRewardedVideo:rewardedVideo inViewController:viewController delegate:delegate];
        rewardedVideo.showTimes++;
        [[ATCapsManager sharedManager] setShowFlagForPlacementID:placementID requestID:rewardedVideo.requestID];
        [[ATPlacementSettingManager sharedManager] setStatus:NO forPlacementID:rewardedVideo.placementModel.placementID];
    } else {
        error = [NSError errorWithDomain:ATADShowingErrorDomain code:100001 userInfo:@{NSLocalizedDescriptionKey:@"ATSDK has failed to show rewarded video ad", NSLocalizedFailureReasonErrorKey:@"Rewarded video ad's not ready for the placement"}];
    }
    if (error != nil) {
        if ([delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForPlacementID:error:extra:)]) {
            [delegate rewardedVideoDidFailToPlayForPlacementID:placementID error:error extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:rewardedVideo.unitGroup.unitID != nil ? rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(rewardedVideo.priority),kATRewardedVideoCallbackExtraPrice:rewardedVideo != nil ? (rewardedVideo.unitGroup.headerBidding ? @([rewardedVideo.unitGroup.bidPrice doubleValue]):@([rewardedVideo.unitGroup.price doubleValue])) : @(0)}];
        }
    }
}

-(void) showRewardedVideoWithPlacementID:(NSString*)placementID inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    [self showRewardedVideoWithPlacementID:placementID scene:nil inViewController:viewController delegate:delegate];
}
@end
