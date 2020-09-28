//
//  ATSigmobInterstitialRewardedVideoDelegate.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 2020/6/4.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATSigmobInterstitialRewardedVideoDelegate.h"
#import "Utilities.h"
#import "ATAPI.h"

static NSString *const kATSigmobRVDataLoadedNotification = @"com.anythink.SigmobRewardAdDataLoaded";
static NSString *const kATSigmobRVLoadedNotification = @"com.anythink.SigmobRewardAdLoaded";
static NSString *const kATSigmobRVFailedToLoadNotification = @"com.anythink.SigmobRewardAdFailedToLoad";
static NSString *const kATSigmobRVPlayStartNotification = @"com.anythink.SigmobRewardAdPlayStart";
static NSString *const kATSigmobRVPlayEndNotification = @"com.anythink.SigmobRewardAdPlayEnd";
static NSString *const kATSigmobRVClickNotification = @"com.anythink.SigmobRewardAdClick";
static NSString *const kATSigmobRVCloseNotification = @"com.anythink.SigmobRewardAdClose";
static NSString *const kATSigmobRVFailedToPlayNotification = @"com.anythink.SigmobRewardAdFailedToPlay";
static NSString *const kATSigmobRVNotificationUserInfoPlacementIDKey = @"placement_id";
static NSString *const kATSigmobRVNotificationUserInfoErrorKey = @"error";
static NSString *const kATSigmobRVNotificationUserInfoRewardedFlag = @"reward";

//sigmob代理为单例，所以当此代理比激励视频先注册，后续激励视频那边的sigmob回调都会在这边接收，因此需要发通知给激励视频去处理回调。
@implementation ATSigmobInterstitialRewardedVideoDelegate
+(instancetype) sharedDelegate {
    static ATSigmobInterstitialRewardedVideoDelegate *sharedDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[ATSigmobInterstitialRewardedVideoDelegate alloc] init];
    });
    return sharedDelegate;
}

- (void)onVideoAdLoadSuccess:(NSString * _Nullable)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobRewardedVideo::onVideoAdLoadSuccess:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialLoadedNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobRVLoadedNotification object:nil userInfo:@{kATSigmobRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

- (void)onVideoError:(NSError *)error placementId:(NSString * _Nullable)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobRewardedVideo::onVideoError::%@ placementId:%@",error, placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialFailedToLoadNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @"", kATSigmobInterstitialNotificationUserInfoErrorKey:error != nil ? error : [NSError errorWithDomain:@"com.anythink.SigmobRVLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:ATSDKAdLoadFailedErrorMsg, NSLocalizedFailureReasonErrorKey:@"Sigmob has failed to load ad"}]}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobRVFailedToLoadNotification object:nil userInfo:@{kATSigmobRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @"", kATSigmobRVNotificationUserInfoErrorKey:error != nil ? error : [NSError errorWithDomain:@"com.anythink.SigmobRVLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:ATSDKAdLoadFailedErrorMsg, NSLocalizedFailureReasonErrorKey:@"Sigmob has failed to load ad"}]}];
}

- (void)onVideoAdClosedWithInfo:(id<ATWindRewardInfo>)info placementId:(NSString * _Nullable)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobRewardedVideo::onVideoAdClosedWithInfo:%@ placementId:%@", @{@"rewardId":info.rewardId != nil ? info.rewardId : @"", @"rewardName":info.rewardName != nil ? info.rewardName : @"", @"rewardAmount":@(info.rewardAmount), @"isCompeltedView":@(info.isCompeltedView)}, placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialCloseNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobRVCloseNotification object:nil userInfo:@{kATSigmobRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @"", kATSigmobRVNotificationUserInfoRewardedFlag:@(info.isCompeltedView)}];
}

- (void)onVideoAdPlayStart:(NSString * _Nullable)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobRewardedVideo::onVideoAdPlayStart:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialPlayStartNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobRVPlayStartNotification object:nil userInfo:@{kATSigmobRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

- (void)onVideoAdClicked:(NSString * _Nullable)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobRewardedVideo::onVideoAdClicked:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialClickNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobRVClickNotification object:nil userInfo:@{kATSigmobRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
}

- (void)onVideoAdPlayError:(NSError *)error placementId:(NSString * _Nullable)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobRewardedVideo::onVideoAdPlayError:%@ placementId:%@", error, placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialFailedToPlayNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @"", kATSigmobInterstitialNotificationUserInfoErrorKey:error != nil ? error : [NSError errorWithDomain:@"com.anythink.SigmobPlay" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to play ad", NSLocalizedFailureReasonErrorKey:@"Sigmob has failed to play ad"}]}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobRVFailedToPlayNotification object:nil userInfo:@{kATSigmobRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @"", kATSigmobRVNotificationUserInfoErrorKey:error != nil ? error : [NSError errorWithDomain:@"com.anythink.SigmobPlay" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to play ad", NSLocalizedFailureReasonErrorKey:@"Sigmob has failed to play ad"}]}];
}

- (void)onVideoAdPlayEnd:(NSString *)placementId {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobRewardedVideo::onVideoAdPlayEnd:%@", placementId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobInterstitialPlayEndNotification object:nil userInfo:@{kATSigmobInterstitialNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kATSigmobRVPlayEndNotification object:nil userInfo:@{kATSigmobRVNotificationUserInfoPlacementIDKey:placementId != nil ? placementId : @""}];
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
