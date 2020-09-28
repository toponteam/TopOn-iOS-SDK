//
//  ATUnityAdsInterstitialAdapter.m
//  AnyThinkUnityAdsInterstitialAdapter
//
//  Created by Martin Lau on 2018/12/25.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATUnityAdsInterstitialAdapter.h"
#import "ATUnityAdsInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
#import <objc/runtime.h>
#import "ATAppSettingManager.h"
NSString *const kATUnityAdsInterstitialLoadedNotification = @"com.anythink.UnityAdsFullScreenAdLoaded";
NSString *const kATUnityAdsInterstitialFailedToLoadNotification = @"com.anythink.UnityAdsFullScreenAdFailedToLoad";
NSString *const kATUnityAdsInterstitialPlayStartNotification = @"com.anythink.UnityAdsFullScreenAdPlayStart";
NSString *const kATUnityAdsInterstitialClickNotification = @"com.anythink.UnityAdsFullScreenAdClick";
NSString *const kATUnityAdsInterstitialCloseNotification = @"com.anythink.UnityAdsFullScreenAdClose";
NSString *const kATUnityAdsInterstitialNotificationUserInfoPlacementIDKey = @"placement_id";
NSString *const kATUnityAdsInterstitialNotificationUserInfoErrorKey = @"error";

@interface ATUnityAdsInterstitialDelegate:NSObject<UnityAdsDelegate, UnityAdsExtendedDelegate>
@end
@implementation ATUnityAdsInterstitialDelegate
+(instancetype) sharedDelegate {
    static ATUnityAdsInterstitialDelegate *sharedDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[ATUnityAdsInterstitialDelegate alloc] init];
    });
    return sharedDelegate;
}

- (void)unityAdsDidError:(NSInteger)error withMessage:(NSString *)message {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsInterstitial::unityAdsDidError:%ld withMessage:%@", error, message] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATUnityAdsInterstitialFailedToLoadNotification object:nil userInfo:@{kATUnityAdsInterstitialNotificationUserInfoErrorKey:[NSError errorWithDomain:@"com.anythink.UnityAdsInterstitialLoad" code:error userInfo:@{NSLocalizedDescriptionKey:@"anythinkSDK has failed to load interstitial.", NSLocalizedFailureReasonErrorKey:[message length] > 0 ? message : @"UnityAds SDK has failed to load interstitial." }]}];
}

- (void)unityAdsPlacementStateChanged:(NSString *)placementId oldState:(NSInteger)oldState newState:(NSInteger)newState {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsInterstitial::unityAdsPlacementStateChanged:%@ oldState:%ld newState:%ld", placementId, oldState, newState] type:ATLogTypeExternal];
    if (newState == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kATUnityAdsInterstitialLoadedNotification object:nil userInfo:@{kATUnityAdsInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
    }
}

-(void)unityAdsDidStart:(NSString*)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsInterstitial::unityAdsDidStart:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATUnityAdsInterstitialPlayStartNotification object:nil userInfo:@{kATUnityAdsInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

-(void)unityAdsDidFinish:(NSString*)placementId withFinishState:(NSInteger)finishState {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsInterstitial::unityAdsDidFinish:%@ withFinishState:%ld", placementId, finishState] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATUnityAdsInterstitialCloseNotification object:nil userInfo:@{kATUnityAdsInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

- (void)unityAdsReady:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsInterstitial::unityAdsReady:%@", placementId] type:ATLogTypeExternal];
}

- (void)unityAdsDidClick:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"UnityAdsInterstitial::unityAdsDidClick:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATUnityAdsInterstitialClickNotification object:nil userInfo:@{kATUnityAdsInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

@end

@interface ATUnityAdsInterstitialAdapter()
@property(nonatomic, readonly) ATUnityAdsInterstitialCustomEvent *customEvent;
@end
@implementation ATUnityAdsInterstitialAdapter
+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall*)finalWaterfall {
    ATUnityAdsInterstitialCustomEvent *customEvent = [[ATUnityAdsInterstitialCustomEvent alloc] initWithInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil] localInfo:nil];
    ATInterstitial *ad = [[ATInterstitial alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:@{kInterstitialAssetsCustomEventKey:customEvent, kInterstitialAssetsUnitIDKey:[customEvent.unitID length] > 0 ? customEvent.unitID : @"", kAdAssetsCustomObjectKey:unitGroup.content[@"placement_id"]} unitGroup:unitGroup finalWaterfall:finalWaterfall];
    return ad;
}

+(BOOL) adReadyForInfo:(NSDictionary*)info {
    return [NSClassFromString(@"UnityAds") isReady:info[@"placement_id"]];
}

+(BOOL) adReadyWithCustomObject:(id<UMONShowAdPlacementContent>)customObject info:(NSDictionary*)info {
    return [NSClassFromString(@"UnityAds") isReady:info[@"placement_id"]];
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSClassFromString(@"UnityAds") show:viewController placementId:interstitial.customEvent.serverInfo[@"placement_id"]];
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
                if (set) {
                    /*
                     value: 1 Personalize, 0 Nonpersonalized
                     */
                    [playerMetaData set:@"gdpr.consent" value:@(!limit)];
                }
            }
            [playerMetaData commit];
        }
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"UnityAds") != nil) {
        _customEvent = [[ATUnityAdsInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        if ([NSClassFromString(@"UnityAds") isReady:serverInfo[@"placement_id"]]) {
            [NSClassFromString(@"UnityAds") removeDelegate:[ATUnityAdsInterstitialDelegate sharedDelegate]];
            [NSClassFromString(@"UnityAds") addDelegate:[ATUnityAdsInterstitialDelegate sharedDelegate]];
            [_customEvent trackInterstitialAdLoaded:serverInfo[@"placement_id"] adExtra:nil];
        } else {
            if (![NSClassFromString(@"UnityAds") isInitialized]) {
                [NSClassFromString(@"UnityAds") initialize:serverInfo[@"game_id"]];
                [NSClassFromString(@"UnityAds") addDelegate:[ATUnityAdsInterstitialDelegate sharedDelegate]];
            }
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"UnityAds"]}]);
    }
}
@end
