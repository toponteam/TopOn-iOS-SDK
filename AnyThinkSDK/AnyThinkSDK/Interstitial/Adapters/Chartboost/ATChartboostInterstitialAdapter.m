//
//  ATChartboostInterstitialAdapter.m
//  AnyThinkChartboostInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/9.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATChartboostInterstitialAdapter.h"
#import "ATChartboostInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
static NSString *const kChartboostClassName = @"Chartboost";
static NSString *const kLocationKey = @"location";

NSString *const kChartboostInterstitialInitializedNotification = @"com.anythink.ChartboostInitializeNotification";
NSString *const kChartboostInterstitialLoadedNotification = @"com.anythink.ChartboostLoadedNotification";
NSString *const kChartboostInterstitialLoadingFailedNotification = @"com.anythink.ChartboostLoadingFailedNotification";
NSString *const kChartboostInterstitialImpressionNotification = @"com.anythink.ChartboostImpressionNotification";
NSString *const kChartboostInterstitialClickNotification = @"com.anythink.ChartboostClickNotification";
NSString *const kChartboostInterstitialCloseNotification = @"com.anythink.ChartboostCloseNotification";
NSString *const kChartboostInterstitialVideoEndNotification = @"com.anythink.ChartboostVideoEndNotification";
NSString *const kChartboostInterstitialNotificationUserInfoLocationKey = @"location";
NSString *const kChartboostInterstitialNotificationUserInfoErrorKey = @"error";
NSString *const kChartboostInterstitialNotificationUserInfoRewardedFlagKey = @"rewarded";
@interface ATChartboostInterstitialDelegate:NSObject<ChartboostDelegate>
@end
@implementation ATChartboostInterstitialDelegate
+(instancetype) sharedDelegateWithAppID:(NSString*)appID appSignature:(NSString*)appSignature location:(NSString*)location {
    static ATChartboostInterstitialDelegate *sharedDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[ATChartboostInterstitialDelegate alloc] init];
        [NSClassFromString(kChartboostClassName) startWithAppId:appID appSignature:appSignature delegate:sharedDelegate];
    });
    return sharedDelegate;
}

- (void)didInitialize:(BOOL)status {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didInitialize:%@", @(status)] type:ATLogTypeExternal];
    if (status) { [[NSNotificationCenter defaultCenter] postNotificationName:kChartboostInterstitialInitializedNotification object:nil]; }
}

- (BOOL)shouldRequestInterstitial:(NSString*)location {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::shouldRequestInterstitial:%@", location] type:ATLogTypeExternal];
    return YES;
}

- (BOOL)shouldDisplayInterstitial:(NSString*)location {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::shouldDisplayInterstitial:%@", location] type:ATLogTypeExternal];
    return YES;
}

- (void)didDisplayInterstitial:(NSString*)location {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didDisplayInterstitial:%@", location] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChartboostInterstitialImpressionNotification object:nil userInfo:@{kChartboostInterstitialNotificationUserInfoLocationKey:location != nil ? location : @""}];
}

- (void)didCacheInterstitial:(NSString*)location {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didCacheInterstitial:%@", location] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChartboostInterstitialLoadedNotification object:nil userInfo:@{kChartboostInterstitialNotificationUserInfoLocationKey:location != nil ? location : @""}];
}

- (void)didFailToLoadInterstitial:(NSString*)location withError:(NSUInteger)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didFailToLoadInterstitial:%@ withError:%@", location, @(error)] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChartboostInterstitialLoadingFailedNotification object:nil userInfo:@{kChartboostInterstitialNotificationUserInfoLocationKey:location != nil ? location : @"", kChartboostInterstitialNotificationUserInfoErrorKey:[NSError errorWithDomain:@"com.anythink.ChartboostLoadingInterstitial" code:error userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load interstitial ad.", NSLocalizedFailureReasonErrorKey:@"Chartboost has failed to load interstitial ad"}]}];
}

- (void)didFailToRecordClick:(NSString*)location withError:(NSUInteger)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didFailToRecordClick:%@ withError:%@", location, @(error)] type:ATLogTypeExternal];
}

- (void)didDismissInterstitial:(NSString*)location {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didDismissInterstitial:%@", location] type:ATLogTypeExternal];
}

- (void)didCloseInterstitial:(NSString*)location {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didCloseInterstitial:%@", location] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChartboostInterstitialCloseNotification object:nil userInfo:@{kChartboostInterstitialNotificationUserInfoLocationKey:location != nil ? location : @""}];
}

- (void)didClickInterstitial:(NSString*)location {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didClickInterstitial:%@", location] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChartboostInterstitialClickNotification object:nil userInfo:@{kChartboostInterstitialNotificationUserInfoLocationKey:location != nil ? location : @""}];
}

- (BOOL)shouldDisplayRewardedVideo:(NSString*)location {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::shouldDisplayRewardedVideo:%@", location] type:ATLogTypeExternal];
    return YES;
}

- (void)didDisplayRewardedVideo:(NSString*)location {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didDisplayRewardedVideo:%@", location] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChartboostInterstitialImpressionNotification object:nil userInfo:@{kChartboostInterstitialNotificationUserInfoLocationKey:location != nil ? location : @""}];
}

- (void)didCacheRewardedVideo:(NSString*)location {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didCacheRewardedVideo:%@", location] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChartboostInterstitialLoadedNotification object:nil userInfo:@{kChartboostInterstitialNotificationUserInfoLocationKey:location != nil ? location : @""}];
}

- (void)didFailToLoadRewardedVideo:(NSString*)location withError:(NSUInteger)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didFailToLoadRewardedVideo:%@ withError:%@", location, @(error)] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChartboostInterstitialLoadingFailedNotification object:nil userInfo:@{kChartboostInterstitialNotificationUserInfoLocationKey:location != nil ? location : @"", kChartboostInterstitialNotificationUserInfoErrorKey:[NSError errorWithDomain:@"com.anythink.ChartboostLoadingRewardedVideo" code:error userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load rewarded video ad.", NSLocalizedFailureReasonErrorKey:@"Chartboost has failed to load rewarded videoad"}]}];
}

- (void)didDismissRewardedVideo:(NSString*)location {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didDismissRewardedVideo:%@", location] type:ATLogTypeExternal];
}

- (void)didCloseRewardedVideo:(NSString*)location {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didCloseRewardedVideo:%@", location] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChartboostInterstitialCloseNotification object:nil userInfo:@{kChartboostInterstitialNotificationUserInfoLocationKey:location != nil ? location : @""}];
}

- (void)didClickRewardedVideo:(NSString*)location {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didClickRewardedVideo:%@", location] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChartboostInterstitialClickNotification object:nil userInfo:@{kChartboostInterstitialNotificationUserInfoLocationKey:location != nil ? location : @""}];
}

- (void)didCompleteRewardedVideo:(NSString*)location withReward:(int)reward {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didCompleteRewardedVideo:%@ withReward:%@", location, @(reward)] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChartboostInterstitialVideoEndNotification object:nil userInfo:@{kChartboostInterstitialNotificationUserInfoLocationKey:location != nil ? location : @"", kChartboostInterstitialNotificationUserInfoRewardedFlagKey:@(reward > 0)}];
}
@end

@interface ATChartboostInterstitialAdapter()
@property(nonatomic, readonly) ATChartboostInterstitialCustomEvent *customEvent;
@property(nonatomic, readonly) NSDictionary *info;
@end
@implementation ATChartboostInterstitialAdapter
+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup {
    ATChartboostInterstitialCustomEvent *customEvent = [[ATChartboostInterstitialCustomEvent alloc] initWithUnitID:unitGroup.content[kLocationKey] customInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil]];
    ATInterstitial *ad = [[ATInterstitial alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:@{kInterstitialAssetsUnitIDKey:customEvent.unitID != nil ? customEvent.unitID : @"", kInterstitialAssetsCustomEventKey:customEvent, kAdAssetsCustomObjectKey:customEvent.unitID != nil ? customEvent.unitID : @""} unitGroup:unitGroup];
    return ad;
}

+(BOOL) adReadyForInfo:(NSDictionary*)info {
    return [NSClassFromString(kChartboostClassName) hasInterstitial:info[kLocationKey]];
}

//For Chartboost, location is saved as its custom object
+(BOOL) adReadyWithCustomObject:(NSString*)customObject info:(NSDictionary*)info {
    return [NSClassFromString(kChartboostClassName) hasInterstitial:customObject];
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    [NSClassFromString(kChartboostClassName) showInterstitial:interstitial.customObject];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) { _info = info; }
    return self;
}

-(void) handleInitNotification:(NSNotification*)notification {
    [NSClassFromString(kChartboostClassName) cacheInterstitial:_info[kLocationKey]];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kChartboostClassName) != nil) {
        _customEvent = [[ATChartboostInterstitialCustomEvent alloc] initWithUnitID:info[kLocationKey] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameChartboost]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameChartboost];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(kChartboostClassName) getSDKVersion] forNetwork:kNetworkNameChartboost];
            if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameChartboost]) {
                [NSClassFromString(kChartboostClassName) restrictDataCollection:[[ATAPI sharedInstance].networkConsentInfo[kNetworkNameChartboost] boolValue]];
            } else {
                BOOL set = NO;
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                if (set) {
                    /*
                    restrict: 0 Personalized, 1 Nonpersonalized
                    */
                    [NSClassFromString(kChartboostClassName) restrictDataCollection:limit];
                }
            }
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInitNotification:) name:kChartboostInterstitialInitializedNotification object:nil];
            [ATChartboostInterstitialDelegate sharedDelegateWithAppID:info[@"app_id"] appSignature:info[@"app_signature"] location:info[kLocationKey]];
        } else {
            if ([NSClassFromString(kChartboostClassName) hasInterstitial:info[kLocationKey]]) {
                [_customEvent handleAssets:@{kInterstitialAssetsCustomEventKey:_customEvent, kInterstitialAssetsUnitIDKey:[_customEvent.unitID length] > 0 ? _customEvent.unitID : @"", kAdAssetsCustomObjectKey:info[kLocationKey] != nil ? info[kLocationKey] : @""}];
            } else {
                [NSClassFromString(kChartboostClassName) cacheInterstitial:info[kLocationKey]];
            }
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, kChartboostClassName]}]);
    }
}
@end
