//
//  ATKidozRewardedVideoAdapter.m
//  AnyThinkKidozAdapter
//
//  Created by Topon on 12/23/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATKidozRewardedVideoAdapter.h"
#import "ATKidozRewardedVideoCustomEvent.h"
#import "ATKidozBaseManager.h"
#import "ATAPI+Internal.h"
#import "ATAdAdapter.h"
#import "Utilities.h"

static NSString *const kATKidozSDKRewardedVideoInitNotification = @"com.anythink.KidozDelegateInit";
static NSString *const kATKidozRewardedVideoInitializationNotification = @"com.anythink.KidozRewardedVideoInit";
NSString *const kATKidozRewardedVideoLoadedNotification = @"com.anythink.KidozRewardedVideoLoaded";
NSString *const kATKidozRewardedVideoFailedToLoadNotification = @"com.anythink.KidozRewardedVideoFailedToLoad";
NSString *const kATKidozRewardedVideoShowNotification = @"com.anythink.KidozRewardedVideoShow";
NSString *const kATKidozRewardedVideoCloseNotification = @"com.anythink.KidozRewardedVideoClose";
NSString *const kATKidozRewardedVideoRewardNotification = @"com.anythink.KidozRewardedVideoReward";
NSString *const kATKidozRewardedVideoNotificationUserInfoErrorKey = @"error";

@interface ATKidozDelegate_RewardedVideo:NSObject<KDZInitDelegate,KDZRewardedDelegate>
@end
@implementation ATKidozDelegate_RewardedVideo
+(instancetype) sharedDelegate {
    static ATKidozDelegate_RewardedVideo *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATKidozDelegate_RewardedVideo alloc] init];
    });
    return sharedManager;
}

-(void)onInitSuccess{
    [ATLogger logMessage:@"KidozRewardedVideoDelegate::onInitSuccess" type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATKidozSDKRewardedVideoInitNotification object:nil];
}

-(void)onInitError:(NSString *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"KidozRewardedVideoDelegate::KidozSDKFailedToInitializeWithError:%@", error] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATKidozSDKRewardedVideoInitNotification object:nil userInfo:@{kATKidozRewardedVideoNotificationUserInfoErrorKey:[NSError errorWithDomain:@"com.anythink.KidozInterstitialInit" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"KidozSDK has failed to init", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"KidozSDK has failed to init with error:%@",error]}]}];
}

-(void)rewardedDidInitialize {
    [ATLogger logMessage:@"KidozRewardedVideoDelegate::rewardedDidInitialize:" type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATKidozRewardedVideoInitializationNotification object:nil];
}

-(void)rewardedDidClose {
    [ATLogger logMessage:@"KidozRewardedVideoDelegate::rewardedDidClose:" type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATKidozRewardedVideoCloseNotification object:nil userInfo:nil];
}

-(void)rewardedDidOpen {
    [ATLogger logMessage:@"KidozRewardedVideoDelegate::rewardedDidOpen:" type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATKidozRewardedVideoShowNotification object:nil userInfo:nil];
}

-(void)rewardedIsReady {
    [ATLogger logMessage:@"KidozRewardedVideoDelegate::rewardedIsReady:" type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATKidozRewardedVideoLoadedNotification object:nil userInfo:nil];
}

-(void)rewardedReturnedWithNoOffers {
    [ATLogger logMessage:@"KidozRewardedVideoDelegate::rewardedReturnedWithNoOffers:" type:ATLogTypeExternal];
}

-(void)rewardedDidPause {
    [ATLogger logMessage:@"KidozRewardedVideoDelegate::rewardedDidPause:" type:ATLogTypeExternal];
}

-(void)rewardedDidResume {
    [ATLogger logMessage:@"KidozRewardedVideoDelegate::rewardedDidResume:" type:ATLogTypeExternal];
}

-(void)rewardedLoadFailed {
    [ATLogger logMessage:@"KidozRewardedVideoDelegate::rewardedLoadFailed:" type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATKidozRewardedVideoFailedToLoadNotification object:nil userInfo:@{kATKidozRewardedVideoNotificationUserInfoErrorKey:[NSError errorWithDomain:@"com.anythink.KidozRewardedVideoLoad" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"Kidoz has failed to load rewardedVideo.", NSLocalizedFailureReasonErrorKey:@"Kidoz rewardedVideo is load failed" }]}];
}

-(void)rewardedDidReciveError:(NSString*)errorMessage {
    [ATLogger logMessage:[NSString stringWithFormat:@"KidozRewardedVideoDelegate::rewardedDidReciveError:%@",errorMessage] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATKidozRewardedVideoFailedToLoadNotification object:nil userInfo:@{kATKidozRewardedVideoNotificationUserInfoErrorKey:[NSError errorWithDomain:@"com.anythink.KidozRewardedVideoLoad" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"Kidoz has failed to load rewardedVideo.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Kidoz rewardedVideo is load failed with error:%@",errorMessage]}]}];
}

-(void)rewardReceived {
    [ATLogger logMessage:@"KidozRewardedVideoDelegate::rewardReceived:" type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATKidozRewardedVideoRewardNotification object:nil userInfo:nil];
}

-(void)rewardedStarted {
    [ATLogger logMessage:@"KidozRewardedVideoDelegate::rewardedStarted:" type:ATLogTypeExternal];
}

-(void)rewardedLeftApplication {
    [ATLogger logMessage:@"KidozRewardedVideoDelegate::rewardedLeftApplication:" type:ATLogTypeExternal];
}

@end

@interface ATKidozRewardedVideoAdapter()
@property(nonatomic, readonly) ATKidozRewardedVideoCustomEvent *customEvent;
@end

static NSString *const kKidozSDKClassName = @"KidozSDK";
@implementation ATKidozRewardedVideoAdapter

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return [[NSClassFromString(kKidozSDKClassName) instance] isRewardedReady];
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    rewardedVideo.customEvent.delegate = delegate;
    [[NSClassFromString(kKidozSDKClassName) instance] showRewarded];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATKidozBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kKidozSDKClassName) != nil) {
        _customEvent = [[ATKidozRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        if (![[NSClassFromString(kKidozSDKClassName) instance] isSDKInitialized]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInitNotification:) name:kATKidozSDKRewardedVideoInitNotification object:nil];
            [[NSClassFromString(kKidozSDKClassName) instance] initializeWithPublisherID:serverInfo[@"publisher_id"] securityToken:serverInfo[@"security_token"] withDelegate:[ATKidozDelegate_RewardedVideo sharedDelegate]];
        } else {
            if ([[NSClassFromString(kKidozSDKClassName) instance] isRewardedInitialized]) {
                [self startLoad];
            } else {
                [self startRewardedVideoInitialized];
            }
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Kidoz"]}]);
    }
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) handleInitNotification:(NSNotification*)notification {
    if (notification.userInfo[kATKidozRewardedVideoNotificationUserInfoErrorKey] != nil) {
        [_customEvent trackRewardedVideoAdLoadFailed:notification.userInfo[kATKidozRewardedVideoNotificationUserInfoErrorKey]];
    } else {
        [self startRewardedVideoInitialized];
    }
}

-(void) RewardedVideoInitNotification:(NSNotification*)notification {
    [self startLoad];
}

-(void) startRewardedVideoInitialized {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RewardedVideoInitNotification:) name:kATKidozRewardedVideoInitializationNotification object:nil];
        [[NSClassFromString(kKidozSDKClassName) instance] initializeRewardedWithDelegate:[ATKidozDelegate_RewardedVideo sharedDelegate]];
    });
}

- (void)startLoad {
    [[NSClassFromString(kKidozSDKClassName) instance] loadRewarded];
}

@end
