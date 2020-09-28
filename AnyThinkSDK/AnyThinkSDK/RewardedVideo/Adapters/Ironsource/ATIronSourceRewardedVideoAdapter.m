//
//  ATIronSourceRewardedVideoAdapter.m
//  AnyThinkIronSourceRewardedVideoAdapter
//
//  Created by Martin Lau on 09/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATIronSourceRewardedVideoAdapter.h"
#import "ATIronSourceRewardedVideoCustomEvent.h"
#import "ATAdManager+RewardedVideo.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"

NSString *const kATIronSourceRVNotificationLoaded = @"com.anythink.kATIronSourceRVNotificationLoaded";
NSString *const kATIronSourceRVNotificationLoadFailed = @"com.anythink.kATIronSourceRVNotificationLoadFailed";
NSString *const kATIronSourceRVNotificationShow = @"com.anythink.kATIronSourceRVNotificationShow";
NSString *const kATIronSourceRVNotificationShowFailed = @"kATIronSourceRVNotificationShowFailed";
NSString *const kATIronSourceRVNotificationClick = @"com.anythink.kATIronSourceRVNotificationClick";
NSString *const kATIronSourceRVNotificationReward = @"com.anythink.kATIronSourceRVNotificationReward";
NSString *const kATIronSourceRVNotificationClose = @"com.anythink.kATIronSourceRVNotificationClose";

NSString *const kATIronSourceRVNotificationUserInfoInstanceIDKey = @"instance_id";
NSString *const kATIronSourceRVNotificationUserInfoErrorKey = @"error";
@interface ATIronSrouceRewardedVideoDelegate:NSObject<ISDemandOnlyRewardedVideoDelegate>
@end
static NSString *const kIronSourceClassName = @"IronSource";
@implementation ATIronSrouceRewardedVideoDelegate
+(instancetype) sharedDelegateWithAppKey:(NSString*)appKey {
    static ATIronSrouceRewardedVideoDelegate *sharedDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[ATIronSrouceRewardedVideoDelegate alloc] init];
        [NSClassFromString(kIronSourceClassName) initISDemandOnly:appKey adUnits:@[@"rewardedvideo"]];
    });
    return sharedDelegate;
}

- (void)rewardedVideoDidLoad:(NSString *)instanceId {
    [ATLogger logMessage:[NSString stringWithFormat:@"IronSrouceRewardedVideo::rewardedVideoDidLoad:%@", instanceId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATIronSourceRVNotificationLoaded object:nil userInfo:@{kATIronSourceRVNotificationUserInfoInstanceIDKey:instanceId != nil ? instanceId : @""}];
}

- (void)rewardedVideoDidFailToLoadWithError:(NSError *)error instanceId:(NSString *)instanceId {
    [ATLogger logMessage:[NSString stringWithFormat:@"IronSrouceRewardedVideo::rewardedVideoDidFailToLoadWithError:%@ instanceId:%@", error, instanceId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATIronSourceRVNotificationLoadFailed object:nil userInfo:@{kATIronSourceRVNotificationUserInfoInstanceIDKey:instanceId != nil ? instanceId : @"", kATIronSourceRVNotificationUserInfoErrorKey:error != nil ? error : [NSError errorWithDomain:@"com.anythink.IronSrouceRewardedVideoLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load rewarded video ad", NSLocalizedFailureReasonErrorKey:@"IronSource has failed to load rewarded video ad."}]}];
}

- (void)rewardedVideoDidFailToShowWithError:(NSError *)error instanceId:(NSString *)instanceId {
    [ATLogger logMessage:[NSString stringWithFormat:@"IronSrouceRewardedVideo::rewardedVideoDidFailToShowWithError:%@ instanceId:%@", error, instanceId]  type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATIronSourceRVNotificationShowFailed object:nil userInfo:@{kATIronSourceRVNotificationUserInfoInstanceIDKey:instanceId != nil ? instanceId : @"", kATIronSourceRVNotificationUserInfoErrorKey:error != nil ? error : [NSError errorWithDomain:@"com.anythink.IronSrouceRewardedVideoShow" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to show rewarded video ad", NSLocalizedFailureReasonErrorKey:@"IronSource has failed to show rewarded video ad."}]}];
}

- (void)rewardedVideoDidOpen:(NSString *)instanceId {
    [ATLogger logMessage:[NSString stringWithFormat:@"IronSrouceRewardedVideo::rewardedVideoDidOpen:%@", instanceId]  type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATIronSourceRVNotificationShow object:nil userInfo:@{kATIronSourceRVNotificationUserInfoInstanceIDKey:instanceId != nil ? instanceId : @""}];
}

- (void)rewardedVideoDidClose:(NSString *)instanceId {
    [ATLogger logMessage:[NSString stringWithFormat:@"IronSrouceRewardedVideo::rewardedVideoDidClose:%@", instanceId]  type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATIronSourceRVNotificationClose object:nil userInfo:@{kATIronSourceRVNotificationUserInfoInstanceIDKey:instanceId != nil ? instanceId : @""}];
}

- (void)rewardedVideoAdRewarded:(NSString *)instanceId { 
    [ATLogger logMessage:[NSString stringWithFormat:@"IronSrouceRewardedVideo::rewardedVideoAdRewarded:%@", instanceId]  type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATIronSourceRVNotificationReward object:nil userInfo:@{kATIronSourceRVNotificationUserInfoInstanceIDKey:instanceId != nil ? instanceId : @""}];
}


- (void)rewardedVideoDidClick:(NSString *)instanceId { 
    [ATLogger logMessage:[NSString stringWithFormat:@"IronSrouceRewardedVideo::rewardedVideoDidClick:%@", instanceId]  type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATIronSourceRVNotificationClick object:nil userInfo:@{kATIronSourceRVNotificationUserInfoInstanceIDKey:instanceId != nil ? instanceId : @""}];
}
@end

@interface ATIronSourceRewardedVideoAdapter()
@property(nonatomic, readonly) ATIronSourceRewardedVideoCustomEvent *customEvent;
@end

static NSString *const kUnitIDKey = @"unit_id";
static NSString *const kPlacementNameKey = @"placement_name";
@implementation ATIronSourceRewardedVideoAdapter
//+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall *)finalWaterfall {
//    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[kPlacementNameKey]} unitGroup:unitGroup finalWaterfall:finalWaterfall];
//}

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return [NSClassFromString(kIronSourceClassName) hasISDemandOnlyRewardedVideo:customObject];
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATIronSourceRewardedVideoCustomEvent *customEvent = (ATIronSourceRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.delegate = delegate;
    [NSClassFromString(kIronSourceClassName) showISDemandOnlyRewardedVideo:viewController instanceId:customEvent.unitID];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameIronSource]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameIronSource];
                [[ATAPI sharedInstance] setVersion:[NSClassFromString(kIronSourceClassName) sdkVersion] forNetwork:kNetworkNameIronSource];
                if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameIronSource]) {
                    [NSClassFromString(kIronSourceClassName) setConsent:[[ATAPI sharedInstance].networkConsentInfo[kNetworkNameIronSource] boolValue]];
                } else {
                    BOOL set = NO;
                    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                    BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                    if (set) { [NSClassFromString(kIronSourceClassName) setConsent:!limit]; }
                }
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kIronSourceClassName) != nil) {
        _customEvent = [[ATIronSourceRewardedVideoCustomEvent alloc] initWithUnitID:serverInfo[@"instance_id"] serverInfo:serverInfo localInfo:localInfo];
        _customEvent.requestNumber = [serverInfo[@"request_num"] integerValue];
        _customEvent.requestCompletionBlock = completion;
        [NSClassFromString(kIronSourceClassName) setISDemandOnlyRewardedVideoDelegate:[ATIronSrouceRewardedVideoDelegate sharedDelegateWithAppKey:serverInfo[@"app_key"]]];
        [NSClassFromString(kIronSourceClassName) loadISDemandOnlyRewardedVideo:serverInfo[@"instance_id"]];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, kIronSourceClassName]}]);
    }
    
}
@end
