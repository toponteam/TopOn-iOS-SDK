//
//  ATUnityAdsRewardedVideoAdapter.m
//  AnyThinkUnityAdsRewardedVideoAdapter
//
//  Created by Martin Lau on 11/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATUnityAdsRewardedVideoAdapter.h"
#import "ATAdManager+RewardedVideo.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import "AnyThinkRewardedVideo.h"
#import "ATUnityAdsRewardedVideoCustomEvent.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"

NSString *const kATUnityAdsRVLoadedNotification = @"com.anythink.UnityAdsRewardAdLoaded";
NSString *const kATUnityAdsRVFailedToLoadNotification = @"com.anythink.UnityAdsRewardAdFailedToLoad";
NSString *const kATUnityAdsRVPlayStartNotification = @"com.anythink.UnityAdsRewardAdPlayStart";
NSString *const kATUnityAdsRVClickNotification = @"com.anythink.UnityAdsRewardAdClick";
NSString *const kATUnityAdsRVCloseNotification = @"com.anythink.UnityAdsRewardAdClose";
NSString *const kATUnityAdsRVNotificationUserInfoPlacementIDKey = @"placement_id";
NSString *const kATUnityAdsRVNotificationUserInfoErrorKey = @"error";
NSString *const kATUnityAdsRVNotificationUserInfoRewardedFlag = @"reward";

@interface ATUnityAdsRewardedDelegate:NSObject<UnityAdsDelegate, UnityAdsExtendedDelegate>
@end
@implementation ATUnityAdsRewardedDelegate
+(instancetype) sharedDelegate {
    static ATUnityAdsRewardedDelegate *sharedDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[ATUnityAdsRewardedDelegate alloc] init];
    });
    return sharedDelegate;
}

- (void)unityAdsDidError:(NSInteger)error withMessage:(NSString *)message {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsRewardedVideo::unityAdsDidError:%ld withMessage:%@", error, message] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATUnityAdsRVFailedToLoadNotification object:nil userInfo:@{kATUnityAdsRVNotificationUserInfoErrorKey:[NSError errorWithDomain:@"com.anythink.UnityAdsRewardedVideoLoad" code:error userInfo:@{NSLocalizedDescriptionKey:@"anythinkSDK has failed to load rewarded video.", NSLocalizedFailureReasonErrorKey:[message length] > 0 ? message : @"UnityAds SDK has failed to load rewarded video." }]}];
}

- (void)unityAdsPlacementStateChanged:(NSString *)placementId oldState:(NSInteger)oldState newState:(NSInteger)newState {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsRewardedVideo::unityAdsPlacementStateChanged:%@ oldState:%ld newState:%ld", placementId, oldState, newState] type:ATLogTypeExternal];
    if (newState == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kATUnityAdsRVLoadedNotification object:nil userInfo:@{kATUnityAdsRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
    }
}

-(void)unityAdsDidStart:(NSString*)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsRewardedVideo::unityAdsDidStart:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATUnityAdsRVPlayStartNotification object:nil userInfo:@{kATUnityAdsRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

-(void)unityAdsDidFinish:(NSString*)placementId withFinishState:(NSInteger)finishState {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsRewardedVideo::unityAdsDidFinish:%@ withFinishState:%ld", placementId, finishState] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATUnityAdsRVCloseNotification object:nil userInfo:@{kATUnityAdsRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @"",kATUnityAdsRVNotificationUserInfoRewardedFlag:finishState == kATUnityAdsFinishStateCompleted ? @YES : @NO}];
}

- (void)unityAdsReady:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsRewardedVideo::unityAdsReady:%@", placementId] type:ATLogTypeExternal];
}

- (void)unityAdsDidClick:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsRewardedVideo::unityAdsDidClick:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATUnityAdsRVClickNotification object:nil userInfo:@{kATUnityAdsRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

@end

@interface ATUnityAdsRewardedVideoAdapter()
@property(nonatomic, readonly) ATUnityAdsRewardedVideoCustomEvent *customEvent;
@end

static NSString *const kUnityAdsClassName = @"UnityAds";
static NSString *const kPlacementIDKey = @"placement_id";
@implementation ATUnityAdsRewardedVideoAdapter
//+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall *)finalWaterfall {
//    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[kPlacementIDKey]} unitGroup:unitGroup finalWaterfall:finalWaterfall];
//}

+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall *)finalWaterfall {
    ATUnityAdsRewardedVideoCustomEvent *customEvent = [[ATUnityAdsRewardedVideoCustomEvent alloc] initWithInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil] localInfo:nil];
    ATRewardedVideo *ad = [[ATRewardedVideo alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsCustomEventKey:customEvent, kRewardedVideoAssetsUnitIDKey:[customEvent.unitID length] > 0 ? customEvent.unitID : @"", kAdAssetsCustomObjectKey:unitGroup.content[kPlacementIDKey]} unitGroup:unitGroup finalWaterfall:finalWaterfall];
    return ad;
}

//+(BOOL) adReadyForInfo:(NSDictionary*)info {
//    return [NSClassFromString(@"UnityAds") isReady:info[@"placement_id"]];
//}

+(BOOL) adReadyWithCustomObject:(id<UMONShowAdPlacementContent>)customObject info:(NSDictionary*)info {
    return [NSClassFromString(@"UnityAds") isReady:info[@"placement_id"]];
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    if ([[[ATAdManager sharedManager] extraInfoForPlacementID:rewardedVideo.placementModel.placementID requestID:rewardedVideo.requestID] containsObjectForKey:kATAdLoadingExtraUserIDKey]) {
        id playerMetaData = [[NSClassFromString(@"UADSPlayerMetaData") alloc] init];
        [playerMetaData setServerId:[[ATAdManager sharedManager] extraInfoForPlacementID:rewardedVideo.placementModel.placementID requestID:rewardedVideo.requestID][kATAdLoadingExtraUserIDKey]];
        [playerMetaData commit];
    }
    
    ATUnityAdsRewardedVideoCustomEvent *customEvent = (ATUnityAdsRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.rewardedVideo = rewardedVideo;
    customEvent.delegate = delegate;
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSClassFromString(@"UnityAds") show:viewController placementId:rewardedVideo.customEvent.serverInfo[@"placement_id"]];
    });
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameUnityAds]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameUnityAds];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"UnityAds") getVersion] forNetwork:kNetworkNameUnityAds];
            id playerMetaData = [[NSClassFromString(@"UADSMetaData") alloc] init];
            if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameUnityAds]) {
                [playerMetaData set:@"gdpr.consent" value:[ATAPI sharedInstance].networkConsentInfo[kNetworkNameUnityAds]];
            } else {
                BOOL set = NO;
                ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                if (set) { [playerMetaData set:@"gdpr.consent" value:@(!limit)]; }
            }
            [playerMetaData commit];
        }
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"UnityAds") != nil) {
        _customEvent = [[ATUnityAdsRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        if ([NSClassFromString(@"UnityAds") isReady:serverInfo[@"placement_id"]]) {
            [NSClassFromString(@"UnityAds") removeDelegate:[ATUnityAdsRewardedDelegate sharedDelegate]];
            [NSClassFromString(@"UnityAds") addDelegate:[ATUnityAdsRewardedDelegate sharedDelegate]];
            [_customEvent trackRewardedVideoAdLoaded:serverInfo[@"placement_id"] adExtra:nil];
        } else {
            if (![NSClassFromString(@"UnityAds") isInitialized]) {
                [NSClassFromString(@"UnityAds") initialize:serverInfo[@"game_id"]];
                [NSClassFromString(@"UnityAds") addDelegate:[ATUnityAdsRewardedDelegate sharedDelegate]];
            }
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"UnityAds"]}]);
    }
}
@end
