//
//  ATSigmobRewardedVideoAdapter.m
//  AnyThinkSigmobRewardedVideoAdapter
//
//  Created by Martin Lau on 2019/9/9.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATSigmobRewardedVideoAdapter.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATAPI+Internal.h"
#import "ATRewardedVideoManager.h"
#import <objc/runtime.h>
#import "ATAdManager+RewardedVideo.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATSigmobRewardedVideoCustomEvent.h"

NSString *const kATSigmobRVDataLoadedNotification = @"com.anythink.SigmobRewardAdDataLoaded";
NSString *const kATSigmobRVLoadedNotification = @"com.anythink.SigmobRewardAdLoaded";
NSString *const kATSigmobRVFailedToLoadNotification = @"com.anythink.SigmobRewardAdFailedToLoad";
NSString *const kATSigmobRVPlayStartNotification = @"com.anythink.SigmobRewardAdPlayStart";
NSString *const kATSigmobRVPlayEndNotification = @"com.anythink.SigmobRewardAdPlayEnd";
NSString *const kATSigmobRVClickNotification = @"com.anythink.SigmobRewardAdClick";
NSString *const kATSigmobRVCloseNotification = @"com.anythink.SigmobRewardAdClose";
NSString *const kATSigmobRVFailedToPlayNotification = @"com.anythink.SigmobRewardAdFailedToPlay";
NSString *const kATSigmobRVNotificationUserInfoPlacementIDKey = @"placement_id";
NSString *const kATSigmobRVNotificationUserInfoErrorKey = @"error";
NSString *const kATSigmobRVNotificationUserInfoRewardedFlag = @"reward";

@interface ATSigmobRVDelegate:NSObject<WindRewardedVideoAdDelegate>
@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);
@end

@implementation ATSigmobRVDelegate
+(instancetype) sharedDelegate {
    static ATSigmobRVDelegate *sharedDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[ATSigmobRVDelegate alloc] init];
    });
    return sharedDelegate;
}

- (void)onVideoAdLoadSuccess:(NSString * _Nullable)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobRewardedVideo::onVideoAdLoadSuccess:%@", placementId] type:ATLogTypeExternal];
    if (self.metaDataDidLoadedBlock != nil) { self.metaDataDidLoadedBlock();}
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobRVLoadedNotification object:nil userInfo:@{kATSigmobRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

- (void)onVideoError:(NSError *)error placementId:(NSString * _Nullable)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobRewardedVideo::onVideoError::%@ placementId:%@",error, placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobRVFailedToLoadNotification object:nil userInfo:@{kATSigmobRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @"", kATSigmobRVNotificationUserInfoErrorKey:error != nil ? error : [NSError errorWithDomain:@"com.anythink.SigmobRVLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load ad", NSLocalizedFailureReasonErrorKey:@"Sigmob has failed to load ad"}]}];
}

- (void)onVideoAdClosedWithInfo:(id<ATWindRewardInfo>)info placementId:(NSString * _Nullable)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobRewardedVideo::onVideoAdClosedWithInfo:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobRVCloseNotification object:nil userInfo:@{kATSigmobRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @"", kATSigmobRVNotificationUserInfoRewardedFlag:@(info.isCompeltedView)}];
}

- (void)onVideoAdPlayStart:(NSString * _Nullable)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobRewardedVideo::onVideoAdPlayStart:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobRVPlayStartNotification object:nil userInfo:@{kATSigmobRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

- (void)onVideoAdClicked:(NSString * _Nullable)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobRewardedVideo::onVideoAdClicked:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobRVClickNotification object:nil userInfo:@{kATSigmobRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

- (void)onVideoAdPlayError:(NSError *)error placementId:(NSString * _Nullable)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobRewardedVideo::onVideoAdPlayError:%@ placementId:%@", error, placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobRVFailedToPlayNotification object:nil userInfo:@{kATSigmobRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @"", kATSigmobRVNotificationUserInfoErrorKey:error != nil ? error : [NSError errorWithDomain:@"com.anythink.SigmobPlay" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to play ad", NSLocalizedFailureReasonErrorKey:@"Sigmob has failed to play ad"}]}];
}

- (void)onVideoAdPlayEnd:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobRewardedVideo::onVideoAdPlayEnd:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobRVPlayEndNotification object:nil userInfo:@{kATSigmobRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

- (void)onVideoAdServerDidSuccess:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobRewardedVideo::onVideoAdServerDidSuccess:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobRVDataLoadedNotification object:nil userInfo:nil];
}

- (void)onVideoAdServerDidFail:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobRewardedVideo::onVideoAdServerDidFail:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobRVFailedToLoadNotification object:nil userInfo:@{kATSigmobRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @"", kATSigmobRVNotificationUserInfoErrorKey:[NSError errorWithDomain:@"com.anythink.SigmobRVLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load ad", NSLocalizedFailureReasonErrorKey:@"Sigmob has failed to load ad"}]}];
}
@end

@interface ATSigmobRewardedVideoAdapter()
@property(nonatomic, readonly) ATSigmobRewardedVideoCustomEvent *customEvent;
@end
@implementation ATSigmobRewardedVideoAdapter
+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup {
    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[@"spot_id"]} unitGroup:unitGroup];
}

+(BOOL) adReadyWithCustomObject:(ATSigmobRewardedVideoCustomEvent*)customObject info:(NSDictionary*)info {
    id<ATWindRewardedVideoAd> sharedRewardedAd = [NSClassFromString(@"WindRewardedVideoAd") sharedInstance];
    return [sharedRewardedAd isReady:info[@"placement_id"]];
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ((ATSigmobRewardedVideoCustomEvent*)rewardedVideo.customEvent).delegate = delegate;
    id<ATWindRewardedVideoAd> sharedRewardedAd = [NSClassFromString(@"WindRewardedVideoAd") sharedInstance];
    NSError *error = nil;
    if (![sharedRewardedAd playAd:viewController withPlacementId:rewardedVideo.customEvent.unitID options:nil error:&error]) {

        if ([((ATSigmobRewardedVideoCustomEvent*)rewardedVideo.customEvent).delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForPlacementID:error:extra:)]) {
            [((ATSigmobRewardedVideoCustomEvent*)rewardedVideo.customEvent).delegate rewardedVideoDidFailToPlayForPlacementID:rewardedVideo.placementModel.placementID error:error extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:rewardedVideo.unitGroup.unitID != nil ? rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(rewardedVideo.priority),kATRewardedVideoCallbackExtraPrice:@(rewardedVideo.unitGroup.headerBidding ? rewardedVideo.unitGroup.bidPrice:rewardedVideo.unitGroup.price)}];
        }
    }
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameSigmob]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameSigmob];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"WindAds") sdkVersion] forNetwork:kNetworkNameSigmob];
            id<ATWindAdOptions> options = [NSClassFromString(@"WindAdOptions") options];
            options.appId = info[@"app_id"];
            options.apiKey = info[@"app_key"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSClassFromString(@"WindAds") startWithOptions:options];
            });
        }
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"WindAdRequest") != nil && NSClassFromString(@"WindRewardedVideoAd") != nil) {
        _customEvent = [[ATSigmobRewardedVideoCustomEvent alloc] initWithUnitID:info[@"placement_id"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
        id<ATWindAdRequest> request = [NSClassFromString(@"WindAdRequest") request];
        if ([[[ATAdManager sharedManager] extraInfoForPlacementID:((ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey]).placementID requestID:info[kAdapterCustomInfoRequestIDKey]] containsObjectForKey:kATAdLoadingExtraUserIDKey]) {
            request.userId = [[ATAdManager sharedManager] extraInfoForPlacementID:((ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey]).placementID requestID:info[kAdapterCustomInfoRequestIDKey]][kATAdLoadingExtraUserIDKey];
        }
        id<ATWindRewardedVideoAd> sharedRewardedAd = [NSClassFromString(@"WindRewardedVideoAd") sharedInstance];
        if (sharedRewardedAd.delegate == nil) { sharedRewardedAd.delegate = [ATSigmobRVDelegate sharedDelegate]; }
        [sharedRewardedAd loadRequest:request withPlacementId:info[@"placement_id"]];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Sigmob"]}]);
    }
}
@end
