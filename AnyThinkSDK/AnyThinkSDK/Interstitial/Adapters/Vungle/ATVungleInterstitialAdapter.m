//
//  ATVungleInterstitialAdapter.m
//  AnyThinkVungleInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/9.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATVungleInterstitialAdapter.h"
#import "ATVungleInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAppSettingManager.h"

static NSString *const kVungleInterstitialInitializationNotification = @"com.anythink.VungleDelegateInit";
NSString *const kVungleInterstitialLoadNotification = @"com.anythink.VungleDelegateLoaded";
NSString *const kVungleInterstitialShowNotification = @"com.anythink.VungleDelegateShown";
NSString *const kVungleInterstitialCloseNotification = @"com.anythink.VungleDelegateClose";
NSString *const kVungleInterstitialNotificationUserInfoPlacementIDKey = @"placement_id";
NSString *const kVungleInterstitialNotificationUserInfoErrorKey = @"error";
NSString *const kVungleInterstitialNotificationUserInfoVideoCompletedFlagKey = @"video_completed";
NSString *const kVungleInterstitialNotificationUserInfoClickFlagKey = @"clicked";
@interface ATVungleDelegate_Interstitial:NSObject<ATVungleSDKDelegate>
@end
@implementation ATVungleDelegate_Interstitial
+(instancetype) sharedDelegate {
    static ATVungleDelegate_Interstitial *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATVungleDelegate_Interstitial alloc] init];
    });
    return sharedManager;
}

- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(nullable NSString *)placementID error:(nullable NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"VungleDelegate::vungleAdPlayabilityUpdate:%@ placementID:%@ error:%@", isAdPlayable ? @"YES" : @"NO", placementID, error] type:ATLogTypeExternal];
    if (isAdPlayable) {
        NSMutableDictionary *userInfo = NSMutableDictionary.dictionary;
        if (placementID != nil) { userInfo[kVungleInterstitialNotificationUserInfoPlacementIDKey] = placementID; }
        if (error != nil) { userInfo[kVungleInterstitialNotificationUserInfoErrorKey] = error; }
        [[NSNotificationCenter defaultCenter] postNotificationName:kVungleInterstitialLoadNotification object:nil userInfo:userInfo];
    }
}

- (void)vungleWillShowAdForPlacementID:(nullable NSString *)placementID {
    [ATLogger logMessage:[NSString stringWithFormat:@"VungleDelegate::vungleWillShowAdForPlacementID:%@", placementID] type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = NSMutableDictionary.dictionary;
    if (placementID != nil) { userInfo[kVungleInterstitialNotificationUserInfoPlacementIDKey] = placementID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kVungleInterstitialShowNotification object:nil userInfo:userInfo];
}

- (void)vungleWillCloseAdWithViewInfo:(nonnull id<ATVungleViewInfo>)info placementID:(nonnull NSString *)placementID {
    [ATLogger logMessage:[NSString stringWithFormat:@"VungleDelegate::vungleWillCloseAdWithViewInfo: placementID:%@", placementID] type:ATLogTypeExternal];
}

- (void)vungleDidCloseAdWithViewInfo:(nonnull id<ATVungleViewInfo>)info placementID:(nonnull NSString *)placementID {
    [ATLogger logMessage:[NSString stringWithFormat:@"VungleDelegate::vungleDidCloseAdWithViewInfo:placementID:%@", placementID] type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:info.completedView, kVungleInterstitialNotificationUserInfoVideoCompletedFlagKey, info.didDownload, kVungleInterstitialNotificationUserInfoClickFlagKey, nil];
    if (placementID != nil) { userInfo[kVungleInterstitialNotificationUserInfoPlacementIDKey] = placementID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kVungleInterstitialCloseNotification object:nil userInfo:userInfo];
}

- (void)vungleSDKDidInitialize {
    [ATLogger logMessage:@"VungleDelegate::vungleSDKDidInitialize" type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kVungleInterstitialInitializationNotification object:nil];
}

- (void)vungleSDKFailedToInitializeWithError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"VungleDelegate::vungleSDKFailedToInitializeWithError:%@", error] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kVungleInterstitialInitializationNotification object:nil userInfo:@{kVungleInterstitialNotificationUserInfoErrorKey:error != nil ? error : [NSError errorWithDomain:@"com.anythink.VungleInterstitialInit" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"VungleSDK has failed to init", NSLocalizedFailureReasonErrorKey:@"VungleSDK has failed to init"}]}];
}
@end

@interface ATVungleInterstitialAdapter()
@property(nonatomic, readonly) ATVungleInterstitialCustomEvent *customEvent;
@property(nonatomic, readonly) NSString *placementID;
@end

static NSString *const kPlacementIDKey = @"placement_id";
static NSString *const kVungleSDKClassName = @"VungleSDK";
@implementation ATVungleInterstitialAdapter
-(ATNativeADSourceType) adSourceType {
    return ATNativeADSourceTypeVideo;
}

+(BOOL) adReadyWithCustomObject:(NSString*)customObject info:(NSDictionary*)info {
    return [((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]) isAdCachedForPlacementID:customObject];
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    NSError *error = nil;
    [((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]) playAd:viewController options:nil placementID:interstitial.customObject error:&error];
    if (error != nil) [(ATVungleInterstitialCustomEvent*)interstitial.customEvent handlerPlayError:error];
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
                    [((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]) updateConsentStatus:[[ATAPI sharedInstance].networkConsentInfo[kNetworkNameVungle] integerValue] consentMessageVersion:@"6.4.6"];
                } else {
                    BOOL set = NO;
                    BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                    if (set) {
                        /*
                        ConsentStatus: 1 Personalized, 2 Nonpersonalized
                        */
                        [((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]) updateConsentStatus:limit ? 2 : 1 consentMessageVersion:@"6.4.6"];
                    }
                }
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kVungleSDKClassName) != nil) {
        _customEvent = [[ATVungleInterstitialCustomEvent alloc] initWithUnitID:info[kPlacementIDKey] customInfo:info adapter:self];
        _customEvent.requestCompletionBlock = completion;
        if (!((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]).isInitialized) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInitNotification:) name:kVungleInterstitialInitializationNotification object:nil];
            NSError *error = nil;
            ((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]).delegate = [ATVungleDelegate_Interstitial sharedDelegate];
            [((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]) startWithAppId:info[@"app_id"] error:&error];
            if (error != nil) { [_customEvent handleLoadingFailure:error]; }
        } else {
            [self startLoad];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Vungle"]}]);
    }
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) handleInitNotification:(NSNotification*)notification {
    if (notification.userInfo[kVungleInterstitialNotificationUserInfoErrorKey] != nil) {
        [_customEvent handleLoadingFailure:notification.userInfo[kVungleInterstitialNotificationUserInfoErrorKey]];
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
