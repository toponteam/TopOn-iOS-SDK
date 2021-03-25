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
#import "ATSigmobBaseManager.h"

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

static NSString *const kATSigmobInterstitialLoadedNotification = @"com.anythink.SigmobFullScreenAdLoaded";
static NSString *const kATSigmobInterstitialFailedToLoadNotification = @"com.anythink.SigmobFullScreenAdFailedToLoad";
static NSString *const kATSigmobInterstitialPlayStartNotification = @"com.anythink.SigmobFullScreenAdPlayStart";
static NSString *const kATSigmobInterstitialPlayEndNotification = @"com.anythink.SigmobFullScreenAdPlayEnd";
static NSString *const kATSigmobInterstitialClickNotification = @"com.anythink.SigmobFullScreenAdClick";
static NSString *const kATSigmobInterstitialCloseNotification = @"com.anythink.SigmobFullScreenAdClose";
static NSString *const kATSigmobInterstitialFailedToPlayNotification = @"com.anythink.SigmobFullScreenAdFailedToPlay";
static NSString *const kATSigmobInterstitialNotificationUserInfoPlacementIDKey = @"placement_id";
static NSString *const kATSigmobInterstitialNotificationUserInfoErrorKey = @"error";
static NSString *const kATSigmobInterstitialNotificationUserInfoFullScreenedFlag = @"FullScreen";
static NSString *const kATSigmobInterstitialDataLoadedNotification = @"com.anythink.SigmobDataLoaded";

//sigmob代理为单例，所以当此代理比插屏激励视频先注册，后续插屏那边的sigmob激励视频回调都会在这边接收，因此需要发通知给插屏激励视频去处理回调。
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialLoadedNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

- (void)onVideoError:(NSError *)error placementId:(NSString * _Nullable)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobRewardedVideo::onVideoError::%@ placementId:%@", error, placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobRVFailedToLoadNotification object:nil userInfo:@{kATSigmobRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @"", kATSigmobRVNotificationUserInfoErrorKey:error != nil ? error : [NSError errorWithDomain:@"com.anythink.SigmobRVLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:ATSDKAdLoadFailedErrorMsg, NSLocalizedFailureReasonErrorKey:@"Sigmob has failed to load ad"}]}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialFailedToLoadNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @"", kATSigmobInterstitialNotificationUserInfoErrorKey:error != nil ? error : [NSError errorWithDomain:@"com.anythink.SigmobRVLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:ATSDKAdLoadFailedErrorMsg, NSLocalizedFailureReasonErrorKey:@"Sigmob has failed to load ad"}]}];
}

- (void)onVideoAdClosedWithInfo:(id<ATWindRewardInfo>)info placementId:(NSString * _Nullable)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobRewardedVideo::onVideoAdClosedWithInfo:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobRVCloseNotification object:nil userInfo:@{kATSigmobRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @"", kATSigmobRVNotificationUserInfoRewardedFlag:@(info.isCompeltedView)}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialCloseNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

- (void)onVideoAdPlayStart:(NSString * _Nullable)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobRewardedVideo::onVideoAdPlayStart:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobRVPlayStartNotification object:nil userInfo:@{kATSigmobRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialPlayStartNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

- (void)onVideoAdClicked:(NSString * _Nullable)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobRewardedVideo::onVideoAdClicked:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobRVClickNotification object:nil userInfo:@{kATSigmobRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialClickNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

- (void)onVideoAdPlayError:(NSError *)error placementId:(NSString * _Nullable)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobRewardedVideo::onVideoAdPlayError:%@ placementId:%@", error, placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobRVFailedToPlayNotification object:nil userInfo:@{kATSigmobRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @"", kATSigmobRVNotificationUserInfoErrorKey:error != nil ? error : [NSError errorWithDomain:@"com.anythink.SigmobPlay" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to play ad", NSLocalizedFailureReasonErrorKey:@"Sigmob has failed to play ad"}]}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialFailedToPlayNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @"", kATSigmobInterstitialNotificationUserInfoErrorKey:error != nil ? error : [NSError errorWithDomain:@"com.anythink.SigmobPlay" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to play ad", NSLocalizedFailureReasonErrorKey:@"Sigmob has failed to play ad"}]}];
}

- (void)onVideoAdPlayEnd:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobRewardedVideo::onVideoAdPlayEnd:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobRVPlayEndNotification object:nil userInfo:@{kATSigmobRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialPlayEndNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

- (void)onVideoAdServerDidSuccess:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobRewardedVideo::onVideoAdServerDidSuccess:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobRVDataLoadedNotification object:nil userInfo:nil];
}

- (void)onVideoAdServerDidFail:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobRewardedVideo::onVideoAdServerDidFail:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobRVFailedToLoadNotification object:nil userInfo:@{kATSigmobRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @"", kATSigmobRVNotificationUserInfoErrorKey:[NSError errorWithDomain:@"com.anythink.SigmobRVLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:ATSDKAdLoadFailedErrorMsg, NSLocalizedFailureReasonErrorKey:@"Sigmob has failed to load ad"}]}];
}
@end

@interface ATSigmobRewardedVideoAdapter()
@property(nonatomic, readonly) ATSigmobRewardedVideoCustomEvent *customEvent;
@end
@implementation ATSigmobRewardedVideoAdapter

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
            [((ATSigmobRewardedVideoCustomEvent*)rewardedVideo.customEvent).delegate rewardedVideoDidFailToPlayForPlacementID:rewardedVideo.placementModel.placementID error:error extra:@{kATRewardedVideoCallbackExtraAdsourceIDKey:rewardedVideo.unitGroup.unitID != nil ? rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(rewardedVideo.priority),kATRewardedVideoCallbackExtraPrice:rewardedVideo.unitGroup.headerBidding ? rewardedVideo.unitGroup.bidPrice:rewardedVideo.unitGroup.price}];
        }
    }
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATSigmobBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"WindAdRequest") != nil && NSClassFromString(@"WindRewardedVideoAd") != nil) {
        _customEvent = [[ATSigmobRewardedVideoCustomEvent alloc] initWithUnitID:serverInfo[@"placement_id"] serverInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
        id<ATWindAdRequest> request = [NSClassFromString(@"WindAdRequest") request];
        if ([[[ATAdManager sharedManager] extraInfoForPlacementID:((ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey]).placementID requestID:serverInfo[kAdapterCustomInfoRequestIDKey]] containsObjectForKey:kATAdLoadingExtraUserIDKey]) {
            request.userId = [[ATAdManager sharedManager] extraInfoForPlacementID:((ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey]).placementID requestID:serverInfo[kAdapterCustomInfoRequestIDKey]][kATAdLoadingExtraUserIDKey];
        }
        id<ATWindRewardedVideoAd> sharedRewardedAd = [NSClassFromString(@"WindRewardedVideoAd") sharedInstance];
        if (sharedRewardedAd.delegate == nil) { sharedRewardedAd.delegate = [ATSigmobRVDelegate sharedDelegate]; }
        [sharedRewardedAd loadRequest:request withPlacementId:serverInfo[@"placement_id"]];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Sigmob"]}]);
    }
}
@end
