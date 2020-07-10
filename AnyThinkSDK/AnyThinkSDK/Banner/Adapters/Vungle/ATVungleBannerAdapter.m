//
//  ATVungleBannerAdapter.m
//  AnyThinkVungleBannerAdapter
//
//  Created by Martin Lau on 2020/6/9.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATVungleBannerAdapter.h"
#import "ATAPI+Internal.h"
#import "ATAppSettingManager.h"
#import "ATAdAdapter.h"
#import "ATVungleBannerCustomEvent.h"
#import "Utilities.h"

static NSString *const kVungleSDKInitializationNotification = @"com.anythink.VungleDelegateInit";
static NSString *const kVungleLoadNotification = @"com.anythink.VungleDelegateLoaded";
static NSString *const kVungleShowNotification = @"com.anythink.VungleDelegateShown";
static NSString *const kVungleCloseNotification = @"com.anythink.VungleDelegateClose";
static NSString *const kVungleNotificationUserInfoPlacementIDKey = @"placement_id";
static NSString *const kVungleNotificationUserInfoErrorKey = @"error";
static NSString *const kVungleNotificationUserInfoVideoCompletedFlagKey = @"video_completed";
static NSString *const kVungleNotificationUserInfoClickFlagKey = @"clicked";
@interface ATVungleDelegate_Banner:NSObject<ATVungleSDKDelegate>
@end
@implementation ATVungleDelegate_Banner
+(instancetype) sharedDelegate {
    static ATVungleDelegate_Banner *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ sharedManager = [[ATVungleDelegate_Banner alloc] init]; });
    return sharedManager;
}

- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(nullable NSString *)placementID error:(nullable NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"VungleDelegate::vungleAdPlayabilityUpdate:%@ placementID:%@ error:%@", isAdPlayable ? @"YES" : @"NO", placementID, error] type:ATLogTypeExternal];
    if (isAdPlayable) {
        NSMutableDictionary *userInfo = NSMutableDictionary.dictionary;
        if (placementID != nil) { userInfo[kVungleNotificationUserInfoPlacementIDKey] = placementID; }
        if (error != nil) { userInfo[kVungleNotificationUserInfoErrorKey] = error; }
        [[NSNotificationCenter defaultCenter] postNotificationName:kVungleLoadNotification object:nil userInfo:userInfo];
    }
}

- (void)vungleWillShowAdForPlacementID:(nullable NSString *)placementID {
    [ATLogger logMessage:[NSString stringWithFormat:@"VungleDelegate::vungleWillShowAdForPlacementID:%@", placementID] type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = NSMutableDictionary.dictionary;
    if (placementID != nil) { userInfo[kVungleNotificationUserInfoPlacementIDKey] = placementID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kVungleShowNotification object:nil userInfo:userInfo];
}

- (void)vungleWillCloseAdWithViewInfo:(nonnull id<ATVungleViewInfo>)info placementID:(nonnull NSString *)placementID { [ATLogger logMessage:[NSString stringWithFormat:@"VungleDelegate::vungleWillCloseAdWithViewInfo: placementID:%@", placementID] type:ATLogTypeExternal]; }

- (void)vungleDidCloseAdWithViewInfo:(nonnull id<ATVungleViewInfo>)info placementID:(nonnull NSString *)placementID {
    [ATLogger logMessage:[NSString stringWithFormat:@"VungleDelegate::vungleDidCloseAdWithViewInfo:placementID:%@", placementID] type:ATLogTypeExternal];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:info.completedView, kVungleNotificationUserInfoVideoCompletedFlagKey, info.didDownload, kVungleNotificationUserInfoClickFlagKey, nil];
    if (placementID != nil) { userInfo[kVungleNotificationUserInfoPlacementIDKey] = placementID; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kVungleCloseNotification object:nil userInfo:userInfo];
}

- (void)vungleSDKDidInitialize {
    [ATLogger logMessage:@"VungleDelegate::vungleSDKDidInitialize" type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kVungleSDKInitializationNotification object:nil];
}

- (void)vungleSDKFailedToInitializeWithError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"VungleDelegate::vungleSDKFailedToInitializeWithError:%@", error] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kVungleSDKInitializationNotification object:nil userInfo:@{kVungleNotificationUserInfoErrorKey:error != nil ? error : [NSError errorWithDomain:@"com.anythink.VungleInterstitialInit" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"VungleSDK has failed to init", NSLocalizedFailureReasonErrorKey:@"VungleSDK has failed to init"}]}];
}
@end

@interface ATVungleBannerAdapter()
@property(nonatomic, readonly) ATVungleBannerCustomEvent *customEvent;
@property(nonatomic, readonly) NSDictionary *info;
@end

static NSString *const kPlacementIDKey = @"placement_id";
static NSString *const kVungleSDKClassName = @"VungleSDK";
@implementation ATVungleBannerAdapter
+(void) showBanner:(ATBanner*)banner inView:(UIView*)view presentingViewController:(UIViewController*)viewController {
    NSError *error = nil;
    CGSize size = [@{@0:[NSValue valueWithCGSize:CGSizeMake(300.0f, 250.0f)], @2:[NSValue valueWithCGSize:CGSizeMake(320.0f, 50.0f)], @3:[NSValue valueWithCGSize:CGSizeMake(300.0f, 50.0f)], @4:[NSValue valueWithCGSize:CGSizeMake(728.0f, 90.0f)]}[@([banner.unitGroup.content[@"size_type"] integerValue])] CGSizeValue];
    UIView *renderingView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(view.bounds) - size.width / 2.0f, CGRectGetMidY(view.bounds) - size.height / 2.0f, size.width, size.height)];
    [view addSubview:renderingView];
    if (![((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]) addAdViewToView:renderingView withOptions:@{} placementID:banner.unitGroup.content[kPlacementIDKey] error:&error]) { [ATLogger logError:[NSString stringWithFormat:@"VungleBanner::AnyThinkSDK has failed to show banner for Vungle; error:%@", error] type:ATLogTypeExternal]; }
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameVungle];
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameVungle]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameVungle];
            BOOL set = NO;
            BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
            if (set) { [((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]) updateConsentStatus:limit ? 2 : 1 consentMessageVersion:@"6.5.4"]; }
        }
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kVungleSDKClassName) != nil) {
        _info = info;
        _customEvent = [[ATVungleBannerCustomEvent alloc] initWithUnitID:info[kPlacementIDKey] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        if (!((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]).isInitialized) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInitNotification:) name:kVungleSDKInitializationNotification object:nil];
            NSError *error = nil;
            ((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]).delegate = [ATVungleDelegate_Banner sharedDelegate];
            [((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]) startWithAppId:info[@"app_id"] error:&error];
            if (error != nil) { [_customEvent handleLoadingFailure:error]; }
        } else {
            [self startLoad];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Vungle"]}]);
    }
}

-(void) dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self]; }

-(void) handleInitNotification:(NSNotification*)notification {
    if (notification.userInfo[kVungleNotificationUserInfoErrorKey] != nil) {
        [_customEvent handleLoadingFailure:notification.userInfo[kVungleNotificationUserInfoErrorKey]];
    } else {
        [self startLoad];
    }
}

-(void) startLoad {
    NSError *error = nil;
    if ([_info[@"unit_type"] integerValue] == 0) {
        [((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]) loadPlacementWithID:_info[kPlacementIDKey] withSize:[_info[@"size_type"] integerValue] error:&error];
    } else {
        [((id<ATVungleSDK>)[NSClassFromString(kVungleSDKClassName) sharedSDK]) loadPlacementWithID:_info[kPlacementIDKey] error:&error];
    }
    
    if (error != nil) [_customEvent handleLoadingFailure:error];
}
@end
