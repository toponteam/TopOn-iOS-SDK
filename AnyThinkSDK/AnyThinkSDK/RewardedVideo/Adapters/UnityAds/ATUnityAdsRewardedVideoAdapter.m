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

@interface ATUnityAdsRewardedVideoAdapter()
@property(nonatomic, readonly) ATUnityAdsRewardedVideoCustomEvent *customEvent;
@end

static NSString *const kUnityAdsClassName = @"UnityAds";
static NSString *const kPlacementIDKey = @"placement_id";
@implementation ATUnityAdsRewardedVideoAdapter
+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup {
    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[kPlacementIDKey]} unitGroup:unitGroup];
}

+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup {
    ATUnityAdsRewardedVideoCustomEvent *customEvent = [[ATUnityAdsRewardedVideoCustomEvent alloc] initWithUnitID:unitGroup.content[kPlacementIDKey] customInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil]];
    id<UMONShowAdPlacementContent> placementContent = [[NSClassFromString(@"UMONShowAdPlacementContent") alloc] initWithPlacementId:unitGroup.content[kPlacementIDKey] withParams:nil];
    ATRewardedVideo *ad = [[ATRewardedVideo alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsCustomEventKey:customEvent, kRewardedVideoAssetsUnitIDKey:[customEvent.unitID length] > 0 ? customEvent.unitID : @"", kAdAssetsCustomObjectKey:placementContent} unitGroup:unitGroup];
    return ad;
}

+(BOOL) adReadyForInfo:(NSDictionary*)info {
    return [NSClassFromString(@"UnityMonetization") isReady:info[@"placement_id"]];
}

+(BOOL) adReadyWithCustomObject:(id<UMONShowAdPlacementContent>)customObject info:(NSDictionary*)info {
    return [NSClassFromString(@"UnityMonetization") isReady:info[@"placement_id"]];
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
        [rewardedVideo.customObject show:viewController withDelegate:(ATUnityAdsRewardedVideoCustomEvent*)rewardedVideo.customEvent];
    });
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
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
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                if (set) { [playerMetaData set:@"gdpr.consent" value:@(!limit)]; }
            }
            [playerMetaData commit];
        }
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"UnityMonetization") != nil) {
        _customEvent = [[ATUnityAdsRewardedVideoCustomEvent alloc] initWithUnitID:info[@"placement_id"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        if ([NSClassFromString(@"UnityMonetization") isReady:info[@"placement_id"]]) {
            id<UMONShowAdPlacementContent> placementContent = [[NSClassFromString(@"UMONShowAdPlacementContent") alloc] initWithPlacementId:info[@"placement_id"] withParams:nil];
            [_customEvent handleAssets:@{kRewardedVideoAssetsCustomEventKey:_customEvent, kRewardedVideoAssetsUnitIDKey:[_customEvent.unitID length] > 0 ? _customEvent.unitID : @"", kAdAssetsCustomObjectKey:placementContent}];
        } else {
            [NSClassFromString(@"UnityMonetization") initialize:info[@"game_id"] delegate:_customEvent];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"UnityAds"]}]);
    }
}
@end
