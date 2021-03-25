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
#import "ATSigmobBaseManager.h"

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

@interface ATSigmobInterstitialDelegate:NSObject<WindInterstitialAdDelegate>
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

- (void)onSMInterstitialAdLoadSuccess:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"WindInterstitialAd::onSMInterstitialAdLoadSuccess:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialLoadedNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

- (void)onSMInterstitialAdError:(NSError *)error placementId:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"WindInterstitialAd::onSMInterstitialAdError::%@ placementId::%@",error, placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialFailedToLoadNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @"", kATSigmobInterstitialNotificationUserInfoErrorKey:error != nil ? error : [NSError errorWithDomain:@"com.anythink.SigmobRVLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:ATSDKAdLoadFailedErrorMsg, NSLocalizedFailureReasonErrorKey:@"Sigmob has failed to load ad"}]}];
}

- (void)onSMInterstitialAdClosed:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"WindInterstitialAd::onSMInterstitialAdClosed:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialCloseNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

- (void)onSMInterstitialAdPlayStart:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"WindInterstitialAd::onSMInterstitialAdPlayStart:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialPlayStartNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

- (void)onSMInterstitialAdClicked:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"WindInterstitialAd::onSMInterstitialAdClicked:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialClickNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

- (void)onSMInterstitialAdPlayError:(NSError *)error placementId:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"WindInterstitialAd::onSMInterstitialAdPlayError:%@ placementId:%@", error, placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialFailedToPlayNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @"", kATSigmobInterstitialNotificationUserInfoErrorKey:error != nil ? error : [NSError errorWithDomain:@"com.anythink.SigmobPlay" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to play ad", NSLocalizedFailureReasonErrorKey:@"Sigmob has failed to play ad"}]}];
}

- (void)onSMInterstitialAdPlayEnd:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"WindInterstitialAd::onSMInterstitialAdPlayEnd:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialPlayEndNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

- (void)onSMInterstitialAdServerDidSuccess:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"WindInterstitialAd::onSMInterstitialAdServerDidSuccess:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialDataLoadedNotification object:nil userInfo:nil];
}

- (void)onSMInterstitialAdServerDidFail:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"WindInterstitialAd::onSMInterstitialAdServerDidFail:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialFailedToLoadNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @"", kATSigmobInterstitialNotificationUserInfoErrorKey:[NSError errorWithDomain:@"com.anythink.SigmobRVLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:ATSDKAdLoadFailedErrorMsg, NSLocalizedFailureReasonErrorKey:@"Sigmob has failed to load ad"}]}];
}
@end

@interface ATSigmobInterstitialAdapter()
@property(nonatomic, readonly) ATSigmobInterstitialCustomEvent *customEvent;
@end
@implementation ATSigmobInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    if (((ATSigmobInterstitialCustomEvent*)customObject).usesRewardedVideo) {
          id<ATWindRewardedVideoAd> sharedRewardedAd = [NSClassFromString(@"WindRewardedVideoAd") sharedInstance];
          return [sharedRewardedAd isReady:info[@"placement_id"]];
    } else {
         id<ATWindInterstitialAd> sharedFullScreen = [NSClassFromString(@"WindInterstitialAd") sharedInstance];
        return [sharedFullScreen isReady:info[@"placement_id"]];
    }
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    ((ATSigmobInterstitialCustomEvent*)interstitial.customEvent).delegate = delegate;
    
    NSError *error = nil;
    BOOL playSuc = NO;
    if (((ATSigmobInterstitialCustomEvent*)interstitial.customEvent).usesRewardedVideo) {
        id<ATWindRewardedVideoAd> rewardedVideoAd = [NSClassFromString(@"WindRewardedVideoAd") sharedInstance];
        playSuc = [rewardedVideoAd playAd:viewController withPlacementId:interstitial.customEvent.unitID options:nil error:&error];
    } else {
        id<ATWindInterstitialAd> sharedFullScreen = [NSClassFromString(@"WindInterstitialAd") sharedInstance];
        playSuc = [sharedFullScreen playAd:viewController withPlacementId:interstitial.customEvent.unitID options:nil error:&error];
    }
    
    if (!playSuc) { if ([((ATSigmobInterstitialCustomEvent*)interstitial.customEvent).delegate respondsToSelector:@selector(interstitialDidFailToPlayVideoForPlacementID:error:extra:)]) { [((ATSigmobInterstitialCustomEvent*)interstitial.customEvent).delegate interstitialDidFailToPlayVideoForPlacementID:((ATSigmobInterstitialCustomEvent*)interstitial.customEvent).interstitial.placementModel.placementID error:[NSError errorWithDomain:@"com.anythink.SigmobInterstitialVideoPlayingFailure" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to show interstitial", NSLocalizedFailureReasonErrorKey:@"SigmobInterstitialVideo failed to play video"}] extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(((ATSigmobInterstitialCustomEvent*)interstitial.customEvent).interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:((ATSigmobInterstitialCustomEvent*)interstitial.customEvent).interstitial.unitGroup.unitID != nil ? ((ATSigmobInterstitialCustomEvent*)interstitial.customEvent).interstitial.unitGroup.unitID : @""}]; } }
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATSigmobBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    BOOL usesRV = ([localInfo isKindOfClass:[NSDictionary class]] && [localInfo[kATInterstitialExtraUsesRewardedVideo] boolValue]) ? [localInfo[kATInterstitialExtraUsesRewardedVideo] boolValue] : NO;
    if (NSClassFromString(@"WindAdRequest") != nil && (usesRV ? NSClassFromString(@"WindRewardedVideoAd") != nil : NSClassFromString(@"WindInterstitialAd") != nil)) {
        _customEvent = [[ATSigmobInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
        id<ATWindAdRequest> request = [NSClassFromString(@"WindAdRequest") request];
        if (usesRV) {
            id<ATWindRewardedVideoAd> sharedRewardedAd = [NSClassFromString(@"WindRewardedVideoAd") sharedInstance];
            if (sharedRewardedAd.delegate == nil) { sharedRewardedAd.delegate = [ATSigmobInterstitialRewardedVideoDelegate sharedDelegate]; }
            [sharedRewardedAd loadRequest:request withPlacementId:serverInfo[@"placement_id"]];
        } else {
            id<ATWindInterstitialAd> sharedFullScreen = [NSClassFromString(@"WindInterstitialAd") sharedInstance];
            if (sharedFullScreen.delegate == nil) { sharedFullScreen.delegate = [ATSigmobInterstitialDelegate sharedDelegate]; }
            [sharedFullScreen loadRequest:request withPlacementId:serverInfo[@"placement_id"]];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Sigmob"]}]);
    }
}

@end
