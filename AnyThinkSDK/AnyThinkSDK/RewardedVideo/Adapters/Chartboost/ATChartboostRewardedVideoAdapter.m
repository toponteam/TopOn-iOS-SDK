//
//  ATChartboostRewardedVideoAdapter.m
//  ATChartboostRewardedVideoAdapter
//
//  Created by Martin Lau on 10/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATChartboostRewardedVideoAdapter.h"
#import "ATChartboostRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import "ATAdManager+RewardedVideo.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"

static NSString *const kChartboostClassName = @"Chartboost";
NSString *const kChartboostRewardedVideoInitializedNotification = @"com.anythink.ChartboostInitializeNotification";
NSString *const kChartboostRewardedVideoLoadedNotification = @"com.anythink.ChartboostLoadedNotification";
NSString *const kChartboostRewardedVideoLoadingFailedNotification = @"com.anythink.ChartboostLoadingFailedNotification";
NSString *const kChartboostRewardedVideoImpressionNotification = @"com.anythink.ChartboostImpressionNotification";
NSString *const kChartboostRewardedVideoClickNotification = @"com.anythink.ChartboostClickNotification";
NSString *const kChartboostRewardedVideoCloseNotification = @"com.anythink.ChartboostCloseNotification";
NSString *const kChartboostRewardedVideoVideoEndNotification = @"com.anythink.ChartboostVideoEndNotification";
NSString *const kChartboostRewardedVideoNotificationUserInfoLocationKey = @"location";
NSString *const kChartboostRewardedVideoNotificationUserInfoErrorKey = @"error";
NSString *const kChartboostRewardedVideoNotificationUserInfoRewardedFlagKey = @"rewarded";
@interface ATChartboostRewardedVideoDelegate:NSObject<ChartboostDelegate>
@end
@implementation ATChartboostRewardedVideoDelegate
+(instancetype) sharedDelegateWithAppID:(NSString*)appID appSignature:(NSString*)appSignature location:(NSString*)location {
    static ATChartboostRewardedVideoDelegate *sharedDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[ATChartboostRewardedVideoDelegate alloc] init];
        [NSClassFromString(kChartboostClassName) startWithAppId:appID appSignature:appSignature delegate:sharedDelegate];
    });
    return sharedDelegate;
}

- (void)didInitialize:(BOOL)status {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didInitialize:%@", @(status)] type:ATLogTypeExternal];
    if (status) { [[NSNotificationCenter defaultCenter] postNotificationName:kChartboostRewardedVideoInitializedNotification object:nil]; }
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kChartboostRewardedVideoImpressionNotification object:nil userInfo:@{kChartboostRewardedVideoNotificationUserInfoLocationKey:location != nil ? location : @""}];
}

- (void)didCacheInterstitial:(NSString*)location {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didCacheInterstitial:%@", location] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChartboostRewardedVideoLoadedNotification object:nil userInfo:@{kChartboostRewardedVideoNotificationUserInfoLocationKey:location != nil ? location : @""}];
}

- (void)didFailToLoadInterstitial:(NSString*)location withError:(NSUInteger)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didFailToLoadInterstitial:%@ withError:%@", location, @(error)] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChartboostRewardedVideoLoadingFailedNotification object:nil userInfo:@{kChartboostRewardedVideoNotificationUserInfoLocationKey:location != nil ? location : @"", kChartboostRewardedVideoNotificationUserInfoErrorKey:[NSError errorWithDomain:@"com.anythink.ChartboostLoadingInterstitial" code:error userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load interstitial ad.", NSLocalizedFailureReasonErrorKey:@"Chartboost has failed to load interstitial ad"}]}];
}

- (void)didFailToRecordClick:(NSString*)location withError:(NSUInteger)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didFailToRecordClick:%@ withError:%@", location, @(error)] type:ATLogTypeExternal];
}

- (void)didDismissInterstitial:(NSString*)location {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didDismissInterstitial:%@", location] type:ATLogTypeExternal];
}

- (void)didCloseInterstitial:(NSString*)location {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didCloseInterstitial:%@", location] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChartboostRewardedVideoCloseNotification object:nil userInfo:@{kChartboostRewardedVideoNotificationUserInfoLocationKey:location != nil ? location : @""}];
}

- (void)didClickInterstitial:(NSString*)location {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didClickInterstitial:%@", location] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChartboostRewardedVideoClickNotification object:nil userInfo:@{kChartboostRewardedVideoNotificationUserInfoLocationKey:location != nil ? location : @""}];
}

- (BOOL)shouldDisplayRewardedVideo:(NSString*)location {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::shouldDisplayRewardedVideo:%@", location] type:ATLogTypeExternal];
    return YES;
}

- (void)didDisplayRewardedVideo:(NSString*)location {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didDisplayRewardedVideo:%@", location] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChartboostRewardedVideoImpressionNotification object:nil userInfo:@{kChartboostRewardedVideoNotificationUserInfoLocationKey:location != nil ? location : @""}];
}

- (void)didCacheRewardedVideo:(NSString*)location {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didCacheRewardedVideo:%@", location] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChartboostRewardedVideoLoadedNotification object:nil userInfo:@{kChartboostRewardedVideoNotificationUserInfoLocationKey:location != nil ? location : @""}];
}

- (void)didFailToLoadRewardedVideo:(NSString*)location withError:(NSUInteger)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didFailToLoadRewardedVideo:%@ withError:%@", location, @(error)] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChartboostRewardedVideoLoadingFailedNotification object:nil userInfo:@{kChartboostRewardedVideoNotificationUserInfoLocationKey:location != nil ? location : @"", kChartboostRewardedVideoNotificationUserInfoErrorKey:[NSError errorWithDomain:@"com.anythink.ChartboostLoadingRewardedVideo" code:error userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load rewarded video ad.", NSLocalizedFailureReasonErrorKey:@"Chartboost has failed to load rewarded videoad"}]}];
}

- (void)didDismissRewardedVideo:(NSString*)location {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didDismissRewardedVideo:%@", location] type:ATLogTypeExternal];
}

- (void)didCloseRewardedVideo:(NSString*)location {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didCloseRewardedVideo:%@", location] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChartboostRewardedVideoCloseNotification object:nil userInfo:@{kChartboostRewardedVideoNotificationUserInfoLocationKey:location != nil ? location : @""}];
}

- (void)didClickRewardedVideo:(NSString*)location {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didClickRewardedVideo:%@", location] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChartboostRewardedVideoClickNotification object:nil userInfo:@{kChartboostRewardedVideoNotificationUserInfoLocationKey:location != nil ? location : @""}];
}

- (void)didCompleteRewardedVideo:(NSString*)location withReward:(int)reward {
    [ATLogger logMessage:[NSString stringWithFormat:@"Charstboost::didCompleteRewardedVideo:%@ withReward:%@", location, @(reward)] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChartboostRewardedVideoVideoEndNotification object:nil userInfo:@{kChartboostRewardedVideoNotificationUserInfoLocationKey:location != nil ? location : @"", kChartboostRewardedVideoNotificationUserInfoRewardedFlagKey:@(reward > 0)}];
}
@end

@interface ATChartboostRewardedVideoAdapter()
@property(nonatomic, readonly) ATChartboostRewardedVideoCustomEvent *customEvent;
@property(nonatomic, readonly) NSString *location;
@end

static NSString *const kUnitIDKey = @"unit_id";
static NSString *const kLocationKey = @"location";
@implementation ATChartboostRewardedVideoAdapter
+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup {
    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[kLocationKey]} unitGroup:unitGroup];
}

+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup {
    ATChartboostRewardedVideoCustomEvent *customEvent = [[ATChartboostRewardedVideoCustomEvent alloc] initWithUnitID:unitGroup.content[kLocationKey] customInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil]];
    [[NSNotificationCenter defaultCenter] removeObserver:customEvent name:kChartboostRewardedVideoLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:customEvent name:kChartboostRewardedVideoLoadingFailedNotification object:nil];
    ATRewardedVideo *ad = [[ATRewardedVideo alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:customEvent.unitID, kAdAssetsCustomObjectKey:customEvent.unitID, kRewardedVideoAssetsCustomEventKey:customEvent} unitGroup:unitGroup];
    return ad;
}

+(BOOL) adReadyForInfo:(NSDictionary*)info {
    return [NSClassFromString(kChartboostClassName) hasRewardedVideo:info[kLocationKey]];
}

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return [NSClassFromString(kChartboostClassName) hasRewardedVideo:info[kLocationKey]];
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    rewardedVideo.customEvent.delegate = delegate;
    [NSClassFromString(kChartboostClassName) showRewardedVideo:rewardedVideo.unitGroup.content[kLocationKey]];
}

-(void) handleInitNotification:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSClassFromString(kChartboostClassName) cacheRewardedVideo:_location];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) { _location = info[kLocationKey]; }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kChartboostClassName)) {
        _customEvent = [[ATChartboostRewardedVideoCustomEvent alloc] initWithUnitID:info[kLocationKey] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameChartboost]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameChartboost];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(kChartboostClassName) getSDKVersion] forNetwork:kNetworkNameChartboost];
            if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameChartboost]) {
                [NSClassFromString(kChartboostClassName) restrictDataCollection:[[ATAPI sharedInstance].networkConsentInfo[kNetworkNameChartboost] boolValue]];
            } else {
                BOOL set = NO;
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                if (set) { [NSClassFromString(kChartboostClassName) restrictDataCollection:limit]; }
            }
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInitNotification:) name:kChartboostRewardedVideoInitializedNotification object:nil];
            [ATChartboostRewardedVideoDelegate sharedDelegateWithAppID:info[@"app_id"] appSignature:info[@"app_signature"] location:info[kLocationKey]];
        } else {
            if ([NSClassFromString(kChartboostClassName) hasRewardedVideo:_location]) {
                [_customEvent handleAssets:@{kRewardedVideoAssetsUnitIDKey:_customEvent.unitID, kAdAssetsCustomObjectKey:_customEvent.unitID, kRewardedVideoAssetsCustomEventKey:_customEvent}];
            } else {
                [NSClassFromString(kChartboostClassName) cacheRewardedVideo:_location];
            }
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, kChartboostClassName]}]);
    }
}
@end
