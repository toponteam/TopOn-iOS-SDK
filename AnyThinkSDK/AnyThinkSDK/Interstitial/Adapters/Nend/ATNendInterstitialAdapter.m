//
//  ATNendInterstitialAdapter.m
//  AnyThinkNendInterstitialAdapter
//
//  Created by Martin Lau on 2019/4/18.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATNendInterstitialAdapter.h"
#import "ATNendInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
#import <objc/runtime.h>
#import "ATAdAdapter.h"
#import "ATAdManager+Interstitial.h"

NSString *const kATNendInterstitialLoadedNotification = @"com.anythink.NendInterstitialLoadedNotificatino";
NSString *const kATNendInterstitialClickNotification = @"com.anythink.NendInterstitialClickNotification";
NSString *const kATNendInterstitialNotificationUserInfoSpotIDKey = @"sopt_id";
NSString *const kATNendInterstitialNotificationUserInfoClickTypeKey = @"click_type";
NSString *const kATNendInterstitialNotificationUserInfoStatusKey = @"status";
@interface ATNendInterstitialDelegate:NSObject<NADInterstitialDelegate>
@end
@implementation ATNendInterstitialDelegate
+(instancetype) sharedInstance {
    static ATNendInterstitialDelegate *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ATNendInterstitialDelegate alloc] init];
    });
    return sharedInstance;
}

- (void)didFinishLoadInterstitialAdWithStatus:(NSInteger)status spotId:(NSString *)spotId {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:@(status) forKey:kATNendInterstitialNotificationUserInfoStatusKey];
    if (spotId != nil) { userInfo[kATNendInterstitialNotificationUserInfoSpotIDKey] = spotId; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kATNendInterstitialLoadedNotification object:nil userInfo:userInfo];
}

- (void)didClickWithType:(NSInteger)type spotId:(NSString *)spotId {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:@(type) forKey:kATNendInterstitialNotificationUserInfoClickTypeKey];
    if (spotId != nil) { userInfo[kATNendInterstitialNotificationUserInfoSpotIDKey] = spotId; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kATNendInterstitialClickNotification object:nil userInfo:userInfo];
}
@end

@interface ATNendInterstitialAdapter()
@property(nonatomic, readonly) ATNendInterstitialCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATNADInterstitialVideo> interstitialVideo;
@property(nonatomic, readonly) id<ATNADFullBoardLoader> fullBoardLoader;
@end

static NSString *const kInterstitialClassName = @"NADInterstitial";
static NSString *const kInterstitialVideoClassName = @"NADInterstitialVideo";
static NSString *const kFullscreenInterstitialClassName = @"NADFullBoard";
static NSString *const kFullscreenInterstitialLoaderClassName = @"NADFullBoardLoader";
@implementation ATNendInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    if ([info[@"is_video"] integerValue] == 0) {
        return YES;
    } else if ([info[@"is_video"] integerValue] == 1) {
        return [((id<ATNADInterstitialVideo>)customObject) isReady];
    } else if ([info[@"is_video"] integerValue] == 2) {
        return YES;
    } else {
        return NO;
    }
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    if ([interstitial.unitGroup.content[@"is_video"] integerValue] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger result = [[NSClassFromString(kInterstitialClassName) sharedInstance] showAdFromViewController:viewController spotId:interstitial.customEvent.unitID];
            if (result == 0) {
                [((ATNendInterstitialCustomEvent*)interstitial.customEvent) handleShowSuccess];
            } else {
                [((ATNendInterstitialCustomEvent*)interstitial.customEvent) handleShowFailure:result];
            }
        });
    } else if ([interstitial.unitGroup.content[@"is_video"] integerValue] == 1) {
        [((id<ATNADInterstitialVideo>)interstitial.customObject) showAdFromViewController:viewController];
    } else if ([interstitial.unitGroup.content[@"is_video"] integerValue] == 2) {
        ((id<ATNADFullBoard>)interstitial.customObject).delegate = (ATNendInterstitialCustomEvent*)interstitial.customEvent;
        [((id<ATNADFullBoard>)interstitial.customObject) showFromViewController:viewController];
    }
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameNend]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameNend];
            [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameNend];
        }
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kInterstitialClassName) != nil && NSClassFromString(kInterstitialVideoClassName) != nil && NSClassFromString(kFullscreenInterstitialClassName) != nil && NSClassFromString(kFullscreenInterstitialLoaderClassName) != nil) {
        _customEvent = [[ATNendInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        NSDictionary *extra = localInfo;
        if ([serverInfo[@"is_video"] integerValue] == 0) {
            if (((id<ATNADInterstitial>)[NSClassFromString(kInterstitialClassName) sharedInstance]).delegate == nil) { ((id<ATNADInterstitial>)[NSClassFromString(kInterstitialClassName) sharedInstance]).delegate = [ATNendInterstitialDelegate sharedInstance]; }
            [[NSClassFromString(kInterstitialClassName) sharedInstance] loadAdWithApiKey:serverInfo[@"api_key"] spotId:serverInfo[@"spot_id"]];
        } else if ([serverInfo[@"is_video"] integerValue] == 1) {
            _interstitialVideo = [[NSClassFromString(kInterstitialVideoClassName) alloc] initWithSpotId:serverInfo[@"spot_id"] apiKey:serverInfo[@"api_key"]];
            _interstitialVideo.delegate = _customEvent;
            if ([extra isKindOfClass:[NSDictionary class]]) {
                if ([extra[kATInterstitialExtraMediationNameKey] isKindOfClass:[NSString class]]) { _interstitialVideo.mediationName = extra[kATInterstitialExtraMediationNameKey]; }
                if ([extra[kATInterstitialExtraUserIDKey] isKindOfClass:[NSString class]]) { _interstitialVideo.userId = extra[kATInterstitialExtraUserIDKey]; }
                if ([extra[kATInterstitialExtraUserFeatureKey] isKindOfClass:[NSClassFromString(@"NADUserFeature") class]]) { _interstitialVideo.userFeature = extra[kATInterstitialExtraUserFeatureKey]; }
                if ([extra[kATInterstitialExtraLocationEnabledFlagKey] respondsToSelector:@selector(boolValue)]) { _interstitialVideo.isLocationEnabled = [extra[kATInterstitialExtraLocationEnabledFlagKey] boolValue]; }
                if ([extra[kATInterstitialExtraMuteStartPlayingFlagKey] respondsToSelector:@selector(boolValue)]) { _interstitialVideo.isMuteStartPlaying = [extra[kATInterstitialExtraMuteStartPlayingFlagKey] boolValue]; }
                if ([extra[kATInterstitialExtraFallbackFullboardBackgroundColorKey] isKindOfClass:[UIColor class]]) { _interstitialVideo.fallbackFullboardBackgroundColor = extra[kATInterstitialExtraFallbackFullboardBackgroundColorKey]; }
            }
            [_interstitialVideo addFallbackFullboardWithSpotId:serverInfo[@"spot_id"] apiKey:serverInfo[@"api_key"]];
            [_interstitialVideo loadAd];
        } else if ([serverInfo[@"is_video"] integerValue] == 2) {
            _fullBoardLoader = [[NSClassFromString(kFullscreenInterstitialLoaderClassName) alloc] initWithSpotId:serverInfo[@"spot_id"] apiKey:serverInfo[@"api_key"]];
            __weak typeof(self) weakSelf = self;
            [_fullBoardLoader loadAdWithCompletionHandler:^(id<ATNADFullBoard> ad, NSInteger error) {
                [weakSelf.customEvent completeFullBoardLoad:ad errorCode:error];
            }];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Nend"]}]);
    }
}
@end
