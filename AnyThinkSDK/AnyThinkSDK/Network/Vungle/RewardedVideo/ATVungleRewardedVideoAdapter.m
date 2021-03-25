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
NSString *const kVungleRewardedVideoClickNotification = @"com.anythink.VungleDelegateClick";
NSString *const kVungleRewardedVideoRewardNotification = @"com.anythink.VungleDelegateReward";
NSString *const kVungleRewardedVideoCloseNotification = @"com.anythink.VungleDelegateClose";
NSString *const kVungleRewardedVideoNotificationUserInfoPlacementIDKey = @"placement_id";
NSString *const kVungleRewardedVideoNotificationUserInfoErrorKey = @"error";
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

- (void)vungleTrackClickForPlacementID:(nullable NSString *)placementID {
    [ATLogger logMessage:[NSString stringWithFormat:@"VungleDelegate::vungleTrackClickForPlacementID:%@", placementID] type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = NSMutableDictionary.dictionary;
    if (placementID != nil) { userInfo[kVungleRewardedVideoNotificationUserInfoPlacementIDKey] = placementID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kVungleRewardedVideoClickNotification object:nil userInfo:userInfo];
}

- (void)vungleRewardUserForPlacementID:(nullable NSString *)placementID {
    [ATLogger logMessage:[NSString stringWithFormat:@"VungleDelegate::vungleRewardUserForPlacementID:%@", placementID] type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = NSMutableDictionary.dictionary;
    if (placementID != nil) { userInfo[kVungleRewardedVideoNotificationUserInfoPlacementIDKey] = placementID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kVungleRewardedVideoRewardNotification object:nil userInfo:userInfo];
}

- (void)vungleDidShowAdForPlacementID:(nullable NSString *)placementID {
    [ATLogger logMessage:[NSString stringWithFormat:@"VungleDelegate::vungleDidShowAdForPlacementID:%@", placementID] type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = NSMutableDictionary.dictionary;
    if (placementID != nil) { userInfo[kVungleRewardedVideoNotificationUserInfoPlacementIDKey] = placementID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kVungleRewardedVideoShowNotification object:nil userInfo:userInfo];
}


- (void)vungleDidCloseAdForPlacementID:(nonnull NSString *)placementID {
    [ATLogger logMessage:[NSString stringWithFormat:@"VungleDelegate::vungleDidCloseAdWithViewInfo:placementID:%@", placementID] type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = NSMutableDictionary.dictionary;
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

+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall*)finalWaterfall {
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
    [customEvent registerNotification];
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    if (customEvent.localInfo[kATAdLoadingExtraUserIDKey] != nil) {
        options[kOptionsUserKey] = customEvent.localInfo[kATAdLoadingExtraUserIDKey];
    }
    NSError *error = nil;
    [((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]) playAd:viewController options:[options count] > 0 ? options : nil placementID:rewardedVideo.customObject error:&error];
    if (error != nil) [customEvent handlerPlayError:error];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        _placementID = serverInfo[kPlacementIDKey];
        [ATVungleBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kVungleSDKClassName) != nil) {
        _customEvent = [[ATVungleRewardedVideoCustomEvent alloc] initWithUnitID:serverInfo[kPlacementIDKey] serverInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        if (!((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]).isInitialized) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInitNotification:) name:kVungleRewardedVideoInitializationNotification object:nil];
            NSError *error = nil;
            ((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]).delegate = [ATVungleDelegate_RewardedVideo sharedDelegate];
            [((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]) startWithAppId:serverInfo[@"app_id"] error:&error];
            if (error != nil) { [_customEvent trackRewardedVideoAdLoadFailed:error]; }
        } else {
            [self startLoad];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Vungle"]}]);
    }
}

-(void) handleInitNotification:(NSNotification*)notification {
    if (notification.userInfo[kVungleRewardedVideoNotificationUserInfoErrorKey] != nil) {
        [_customEvent trackRewardedVideoAdLoadFailed:notification.userInfo[kVungleRewardedVideoNotificationUserInfoErrorKey]];
    } else {
        [self startLoad];
    }
}

-(void) startLoad {
    NSError *error = nil;
    [((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]) loadPlacementWithID:_placementID error:&error];
    if (error != nil) [_customEvent trackRewardedVideoAdLoadFailed:error];
}
@end
