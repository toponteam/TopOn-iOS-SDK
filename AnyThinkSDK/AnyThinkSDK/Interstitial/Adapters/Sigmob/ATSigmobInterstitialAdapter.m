//
//  ATSigmobInterstitialAdapter.m
//  AnyThinkSigmobInterstitialAdapter
//
//  Created by Martin Lau on 2019/9/10.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATSigmobInterstitialAdapter.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATAPI+Internal.h"
#import "ATInterstitialManager.h"
#import <objc/runtime.h>
#import "ATAdManager+Interstitial.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATSigmobInterstitialCustomEvent.h"
#import "ATSigmobInterstitialRewardedVideoDelegate.h"
NSString *const kATSigmobInterstitialLoadedNotification = @"com.anythink.SigmobFullScreenAdLoaded";
NSString *const kATSigmobInterstitialFailedToLoadNotification = @"com.anythink.SigmobFullScreenAdFailedToLoad";
NSString *const kATSigmobInterstitialPlayStartNotification = @"com.anythink.SigmobFullScreenAdPlayStart";
NSString *const kATSigmobInterstitialPlayEndNotification = @"com.anythink.SigmobFullScreenAdPlayEnd";
NSString *const kATSigmobInterstitialClickNotification = @"com.anythink.SigmobFullScreenAdClick";
NSString *const kATSigmobInterstitialCloseNotification = @"com.anythink.SigmobFullScreenAdClose";
NSString *const kATSigmobInterstitialFailedToPlayNotification = @"com.anythink.SigmobFullScreenAdFailedToPlay";
NSString *const kATSigmobInterstitialNotificationUserInfoPlacementIDKey = @"placement_id";
NSString *const kATSigmobInterstitialNotificationUserInfoErrorKey = @"error";
NSString *const kATSigmobInterstitialNotificationUserInfoFullScreenedFlag = @"FullScreen";
NSString *const kATSigmobInterstitialDataLoadedNotification = @"com.anythink.SigmobDataLoaded";

@interface ATSigmobInterstitialDelegate:NSObject<WindFullscreenVideoAdDelegate>
@end

@implementation ATSigmobInterstitialDelegate
+(instancetype) sharedDelegate {
    static ATSigmobInterstitialDelegate *sharedDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[ATSigmobInterstitialDelegate alloc] init];
    });
    return sharedDelegate;
}


- (void)onFullscreenVideoAdLoadSuccess:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobFullScreenedVideo::onFullscreenVideoAdLoadSuccess:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialLoadedNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

- (void)onFullscreenVideoAdError:(NSError *)error placementId:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobFullScreenedVideo::onFullscreenVideoAdError::%@ placementId::%@",error, placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialFailedToLoadNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @"", kATSigmobInterstitialNotificationUserInfoErrorKey:error != nil ? error : [NSError errorWithDomain:@"com.anythink.SigmobRVLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load ad", NSLocalizedFailureReasonErrorKey:@"Sigmob has failed to load ad"}]}];
}

- (void)onFullscreenVideoAdClosed:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobFullScreenedVideo::onFullscreenVideoAdClosed:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialCloseNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

- (void)onFullscreenVideoAdPlayStart:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobFullScreenedVideo::onFullscreenVideoAdPlayStart:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialPlayStartNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

- (void)onFullscreenVideoAdClicked:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobFullScreenedVideo::onFullscreenVideoAdClicked:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialClickNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

- (void)onFullscreenVideoAdPlayError:(NSError *)error placementId:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobFullScreenedVideo::onFullscreenVideoAdPlayError:%@ placementId:%@", error, placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialFailedToPlayNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @"", kATSigmobInterstitialNotificationUserInfoErrorKey:error != nil ? error : [NSError errorWithDomain:@"com.anythink.SigmobPlay" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to play ad", NSLocalizedFailureReasonErrorKey:@"Sigmob has failed to play ad"}]}];
}

- (void)onFullscreenVideoAdPlayEnd:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobFullScreenedVideo::onFullscreenVideoAdPlayEnd:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialPlayEndNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

- (void)onFullscreenVideoAdServerDidSuccess:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobFullScreenedVideo::onFullscreenVideoAdServerDidSuccess:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialDataLoadedNotification object:nil userInfo:nil];
}

- (void)onFullscreenVideoAdServerDidFail:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobFullScreenedVideo::onFullscreenVideoAdServerDidFail:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialFailedToLoadNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @"", kATSigmobInterstitialNotificationUserInfoErrorKey:[NSError errorWithDomain:@"com.anythink.SigmobRVLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load ad", NSLocalizedFailureReasonErrorKey:@"Sigmob has failed to load ad"}]}];
}
@end

@interface ATSigmobInterstitialAdapter()
@property(nonatomic, readonly) ATSigmobInterstitialCustomEvent *customEvent;
@end
@implementation ATSigmobInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    id<ATWindFullscreenVideoAd> sharedFullScreen = [NSClassFromString(@"WindFullscreenVideoAd") sharedInstance];
    return [sharedFullScreen isReady:info[@"placement_id"]];
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    ((ATSigmobInterstitialCustomEvent*)interstitial.customEvent).delegate = delegate;
    
    NSError *error = nil;
    BOOL playSuc = NO;
    if (((ATSigmobInterstitialCustomEvent*)interstitial.customEvent).usesRewardedVideo) {
        id<ATWindRewardedVideoAd> rewardedVideoAd = [NSClassFromString(@"WindRewardedVideoAd") sharedInstance];
        playSuc = [rewardedVideoAd playAd:viewController withPlacementId:interstitial.customEvent.unitID options:nil error:&error];
    } else {
        id<ATWindFullscreenVideoAd> sharedFullScreen = [NSClassFromString(@"WindFullscreenVideoAd") sharedInstance];
        playSuc = [sharedFullScreen playAd:viewController withPlacementId:interstitial.customEvent.unitID options:nil error:&error];
    }
    
    if (!playSuc) { if ([((ATSigmobInterstitialCustomEvent*)interstitial.customEvent).delegate respondsToSelector:@selector(interstitialDidFailToPlayVideoForPlacementID:error:extra:)]) { [((ATSigmobInterstitialCustomEvent*)interstitial.customEvent).delegate interstitialDidFailToPlayVideoForPlacementID:((ATSigmobInterstitialCustomEvent*)interstitial.customEvent).interstitial.placementModel.placementID error:[NSError errorWithDomain:@"com.anythink.SigmobInterstitialVideoPlayingFailure" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to show interstitial", NSLocalizedFailureReasonErrorKey:@"SigmobInterstitialVideo failed to play video"}] extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(((ATSigmobInterstitialCustomEvent*)interstitial.customEvent).interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:((ATSigmobInterstitialCustomEvent*)interstitial.customEvent).interstitial.unitGroup.unitID != nil ? ((ATSigmobInterstitialCustomEvent*)interstitial.customEvent).interstitial.unitGroup.unitID : @""}]; } }
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
            dispatch_async(dispatch_get_main_queue(), ^{ [NSClassFromString(@"WindAds") startWithOptions:options]; });
        }
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    BOOL usesRV = ([info[kAdapterCustomInfoExtraKey] isKindOfClass:[NSDictionary class]] && [info[kAdapterCustomInfoExtraKey][kATInterstitialExtraUsesRewardedVideo] boolValue]) ? [info[kAdapterCustomInfoExtraKey][kATInterstitialExtraUsesRewardedVideo] boolValue] : NO;
    if (NSClassFromString(@"WindAdRequest") != nil && (usesRV ? NSClassFromString(@"WindRewardedVideoAd") != nil : NSClassFromString(@"WindFullscreenVideoAd") != nil)) {
        _customEvent = [[ATSigmobInterstitialCustomEvent alloc] initWithUnitID:info[@"placement_id"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
        id<ATWindAdRequest> request = [NSClassFromString(@"WindAdRequest") request];
        if (usesRV) {
            id<ATWindRewardedVideoAd> sharedRewardedAd = [NSClassFromString(@"WindRewardedVideoAd") sharedInstance];
            if (sharedRewardedAd.delegate == nil) { sharedRewardedAd.delegate = [ATSigmobInterstitialRewardedVideoDelegate sharedDelegate]; }
            [sharedRewardedAd loadRequest:request withPlacementId:info[@"placement_id"]];
        } else {
            id<ATWindFullscreenVideoAd> sharedFullScreen = [NSClassFromString(@"WindFullscreenVideoAd") sharedInstance];
            if (sharedFullScreen.delegate == nil) { sharedFullScreen.delegate = [ATSigmobInterstitialDelegate sharedDelegate]; }
            [sharedFullScreen loadRequest:request withPlacementId:info[@"placement_id"]];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Sigmob"]}]);
    }
}
@end
