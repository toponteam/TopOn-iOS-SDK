//
//  ATVungleRewardedVideoAdapter.m
//  AnyThinkVungleRewardedVideoAdapter
//
//  Created by Martin Lau on 11/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATVungleRewardedVideoAdapter.h"
#import "ATVungleRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import "ATLogger.h"
#import "Utilities.h"
#import "ATAdManager+RewardedVideo.h"
#import "ATAppSettingManager.h"
static NSString *const kVungleRewardedVideoInitializationNotification = @"com.anythink.VungleDelegateInit";
NSString *const kVungleRewardedVideoLoadNotification = @"com.anythink.VungleDelegateLoaded";
NSString *const kVungleRewardedVideoShowNotification = @"com.anythink.VungleDelegateShown";
NSString *const kVungleRewardedVideoCloseNotification = @"com.anythink.VungleDelegateClose";
NSString *const kVungleRewardedVideoNotificationUserInfoPlacementIDKey = @"placement_id";
NSString *const kVungleRewardedVideoNotificationUserInfoErrorKey = @"error";
NSString *const kVungleRewardedVideoNotificationUserInfoVideoCompletedFlagKey = @"video_completed";
NSString *const kVungleRewardedVideoNotificationUserInfoClickFlagKey = @"clicked";
@interface ATVungleDelegate_RewardedVideo:NSObject<ATVungleSDKDelegate>
@end
@implementation ATVungleDelegate_RewardedVideo
+(instancetype) sharedDelegate {
    static ATVungleDelegate_RewardedVideo *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATVungleDelegate_RewardedVideo alloc] init];
    });
    return sharedManager;
}

- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(nullable NSString *)placementID error:(nullable NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"VungleDelegate::vungleAdPlayabilityUpdate:%@ placementID:%@ error:%@", isAdPlayable ? @"YES" : @"NO", placementID, error] type:ATLogTypeExternal];
    if (isAdPlayable) {
        NSMutableDictionary *userInfo = NSMutableDictionary.dictionary;
        if (placementID != nil) { userInfo[kVungleRewardedVideoNotificationUserInfoPlacementIDKey] = placementID; }
        if (error != nil) { userInfo[kVungleRewardedVideoNotificationUserInfoErrorKey] = error; }
        [[NSNotificationCenter defaultCenter] postNotificationName:kVungleRewardedVideoLoadNotification object:nil userInfo:userInfo];
    }
}

- (void)vungleWillShowAdForPlacementID:(nullable NSString *)placementID {
    [ATLogger logMessage:[NSString stringWithFormat:@"VungleDelegate::vungleWillShowAdForPlacementID:%@", placementID] type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = NSMutableDictionary.dictionary;
    if (placementID != nil) { userInfo[kVungleRewardedVideoNotificationUserInfoPlacementIDKey] = placementID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kVungleRewardedVideoShowNotification object:nil userInfo:userInfo];
}

- (void)vungleWillCloseAdWithViewInfo:(nonnull id<ATVungleViewInfo>)info placementID:(nonnull NSString *)placementID {
    [ATLogger logMessage:[NSString stringWithFormat:@"VungleDelegate::vungleWillCloseAdWithViewInfo: placementID:%@", placementID] type:ATLogTypeExternal];
}

- (void)vungleDidCloseAdWithViewInfo:(nonnull id<ATVungleViewInfo>)info placementID:(nonnull NSString *)placementID {
    [ATLogger logMessage:[NSString stringWithFormat:@"VungleDelegate::vungleDidCloseAdWithViewInfo:placementID:%@", placementID] type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:info.completedView, kVungleRewardedVideoNotificationUserInfoVideoCompletedFlagKey, info.didDownload, kVungleRewardedVideoNotificationUserInfoClickFlagKey, nil];
    if (placementID != nil) { userInfo[kVungleRewardedVideoNotificationUserInfoPlacementIDKey] = placementID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kVungleRewardedVideoCloseNotification object:nil userInfo:userInfo];
}

- (void)vungleSDKDidInitialize {
    [ATLogger logMessage:@"VungleDelegate::vungleSDKDidInitialize" type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kVungleRewardedVideoInitializationNotification object:nil];
}

- (void)vungleSDKFailedToInitializeWithError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"VungleDelegate::vungleSDKFailedToInitializeWithError:%@", error] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kVungleRewardedVideoInitializationNotification object:nil userInfo:@{kVungleRewardedVideoNotificationUserInfoErrorKey:error != nil ? error : [NSError errorWithDomain:@"com.anythink.VungleInterstitialInit" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"VungleSDK has failed to init", NSLocalizedFailureReasonErrorKey:@"VungleSDK has failed to init"}]}];
}
@end

@interface ATVungleRewardedVideoAdapter()
@property(nonatomic, readonly) NSString *placementID;
@property(nonatomic, readonly) ATVungleRewardedVideoCustomEvent *customEvent;
@end

static NSString *const kPlacementIDKey = @"placement_id";
static NSString *const kVungleSDKClassName = @"VungleSDK";
static NSString *const kOptionsUserKey = @"user";
@implementation ATVungleRewardedVideoAdapter
+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup {
    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[kPlacementIDKey]} unitGroup:unitGroup];
}

+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup {
    return nil;
}

+(BOOL) adReadyForInfo:(NSDictionary*)info {
    return [((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]) isAdCachedForPlacementID:info[kPlacementIDKey]];
}

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return [((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]) isAdCachedForPlacementID:customObject];
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATVungleRewardedVideoCustomEvent *customEvent = (ATVungleRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.delegate = delegate;
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    if ([rewardedVideo.unitGroup.content containsObjectForKey:kATAdLoadingExtraUserDataKeywordKey])
        options[kOptionsUserKey] = rewardedVideo.unitGroup.content[kATAdLoadingExtraUserDataKeywordKey];
    NSError *error = nil;
    [((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]) playAd:viewController options:[options count] > 0 ? options : nil placementID:rewardedVideo.customObject error:&error];
    if (error != nil) [customEvent handlerPlayError:error];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        _placementID = info[kPlacementIDKey];
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameVungle];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameVungle]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameVungle];
                if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameVungle]) {
                    [((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]) updateConsentStatus:[[ATAPI sharedInstance].networkConsentInfo[kNetworkNameVungle] integerValue] consentMessageVersion:@"6.3.2"];
                } else {
                    BOOL set = NO;
                    BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                    if (set) { [((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]) updateConsentStatus:limit ? 2 : 1 consentMessageVersion:@"6.4.6"]; }
                }
            }
        });
    }
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kVungleSDKClassName) != nil) {
        _customEvent = [[ATVungleRewardedVideoCustomEvent alloc] initWithUnitID:info[kPlacementIDKey] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        if (!((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]).isInitialized) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInitNotification:) name:kVungleRewardedVideoInitializationNotification object:nil];
            NSError *error = nil;
            ((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]).delegate = [ATVungleDelegate_RewardedVideo sharedDelegate];
            [((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]) startWithAppId:info[@"app_id"] error:&error];
            if (error != nil) { [_customEvent handleLoadingFailure:error]; }
        } else {
            [self startLoad];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Vungle"]}]);
    }
}

-(void) handleInitNotification:(NSNotification*)notification {
    if (notification.userInfo[kVungleRewardedVideoNotificationUserInfoErrorKey] != nil) {
        [_customEvent handleLoadingFailure:notification.userInfo[kVungleRewardedVideoNotificationUserInfoErrorKey]];
    } else {
        [self startLoad];
    }
}

-(void) startLoad {
    NSError *error = nil;
    [((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]) loadPlacementWithID:_placementID error:&error];
    if (error != nil) [_customEvent handleLoadingFailure:error];
}
@end
