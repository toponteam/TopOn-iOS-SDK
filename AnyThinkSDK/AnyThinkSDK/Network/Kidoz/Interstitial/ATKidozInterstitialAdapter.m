//
//  ATKidozInterstitialAdapter.m
//  AnyThinkKidozAdapter
//
//  Created by Topon on 12/23/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATKidozInterstitialAdapter.h"
#import "ATKidozInterstitialCustomEvent.h"
#import "ATKidozBaseManager.h"
#import "ATAPI+Internal.h"
#import "ATAdAdapter.h"
#import "Utilities.h"

static NSString *const kATKidozSDKInterstitialInitNotification = @"com.anythink.KidozDelegateInit";
static NSString *const kATKidozInterstitialInitializationNotification = @"com.anythink.KidozInterstitialInit";
NSString *const kATKidozInterstitialLoadedNotification = @"com.anythink.KidozInterstitialLoaded";
NSString *const kATKidozInterstitialFailedToLoadNotification = @"com.anythink.KidozInterstitialFailedToLoad";
NSString *const kATKidozInterstitialShowNotification = @"com.anythink.KidozInterstitialShow";
NSString *const kATKidozInterstitialCloseNotification = @"com.anythink.KidozInterstitialClose";
NSString *const kATKidozInterstitialNotificationUserInfoErrorKey = @"error";

@interface ATKidozDelegate_Interstitial:NSObject<KDZInitDelegate,KDZInterstitialDelegate>
@end
@implementation ATKidozDelegate_Interstitial
+(instancetype) sharedDelegate {
    static ATKidozDelegate_Interstitial *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATKidozDelegate_Interstitial alloc] init];
    });
    return sharedManager;
}

-(void)onInitSuccess{
    [ATLogger logMessage:@"KidozInterstitialDelegate::onInitSuccess" type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATKidozSDKInterstitialInitNotification object:nil];
}

-(void)onInitError:(NSString *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"KidozInterstitialDelegate::KidozSDKFailedToInitializeWithError:%@", error] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATKidozSDKInterstitialInitNotification object:nil userInfo:@{kATKidozInterstitialNotificationUserInfoErrorKey:[NSError errorWithDomain:@"com.anythink.KidozInterstitialInit" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"KidozSDK has failed to init", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"KidozSDK has failed to init with error:%@",error]}]}];
}

-(void)interstitialDidInitialize {
    [ATLogger logMessage:@"KidozInterstitialDelegate::interstitialDidInitialize:" type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATKidozInterstitialInitializationNotification object:nil];
}

-(void)interstitialDidClose {
    [ATLogger logMessage:@"KidozInterstitialDelegate::interstitialDidClose:" type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATKidozInterstitialCloseNotification object:nil userInfo:nil];
}

-(void)interstitialDidOpen {
    [ATLogger logMessage:@"KidozInterstitialDelegate::interstitialDidOpen:" type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATKidozInterstitialShowNotification object:nil userInfo:nil];
}

-(void)interstitialIsReady {
    [ATLogger logMessage:@"KidozInterstitialDelegate::interstitialIsReady:" type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATKidozInterstitialLoadedNotification object:nil userInfo:nil];
}

-(void)interstitialReturnedWithNoOffers {
    [ATLogger logMessage:@"KidozInterstitialDelegate::interstitialReturnedWithNoOffers:" type:ATLogTypeExternal];
}

-(void)interstitialDidPause {
    [ATLogger logMessage:@"KidozInterstitialDelegate::interstitialDidPause:" type:ATLogTypeExternal];
}

-(void)interstitialDidResume {
    [ATLogger logMessage:@"KidozInterstitialDelegate::interstitialDidResume:" type:ATLogTypeExternal];
}

-(void)interstitialLoadFailed {
    [ATLogger logMessage:@"KidozInterstitialDelegate::interstitialLoadFailed:" type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATKidozInterstitialFailedToLoadNotification object:nil userInfo:@{kATKidozInterstitialNotificationUserInfoErrorKey:[NSError errorWithDomain:@"com.anythink.KidozInterstitialLoad" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"Kidoz has failed to load interstitial.", NSLocalizedFailureReasonErrorKey:@"Kidoz interstitial is load failed" }]}];
}

-(void)interstitialDidReciveError:(NSString*)errorMessage {
    [ATLogger logMessage:[NSString stringWithFormat:@"KidozInterstitialDelegate::interstitialDidReciveError:%@",errorMessage] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATKidozInterstitialFailedToLoadNotification object:nil userInfo:@{kATKidozInterstitialNotificationUserInfoErrorKey:[NSError errorWithDomain:@"com.anythink.KidozInterstitialLoad" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"Kidoz has failed to load interstitial.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Kidoz interstitial is load failed with error:%@",errorMessage]}]}];
}

-(void)interstitialLeftApplication {
    [ATLogger logMessage:@"KidozInterstitialDelegate::interstitialLeftApplication:" type:ATLogTypeExternal];
}

@end

@interface ATKidozInterstitialAdapter()
@property(nonatomic, readonly) ATKidozInterstitialCustomEvent *customEvent;
@end

static NSString *const kKidozSDKClassName = @"KidozSDK";
@implementation ATKidozInterstitialAdapter

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return [[NSClassFromString(kKidozSDKClassName) instance] isInterstitialReady];
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    [[NSClassFromString(kKidozSDKClassName) instance] showInterstitial];
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
        _customEvent = [[ATKidozInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        if (![[NSClassFromString(kKidozSDKClassName) instance] isSDKInitialized]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInitNotification:) name:kATKidozSDKInterstitialInitNotification object:nil];
            [[NSClassFromString(kKidozSDKClassName) instance] initializeWithPublisherID:serverInfo[@"publisher_id"] securityToken:serverInfo[@"security_token"] withDelegate:[ATKidozDelegate_Interstitial sharedDelegate]];
        } else {
            if ([[NSClassFromString(kKidozSDKClassName) instance] isInterstitialInitialized]) {
                [self startLoad];
            } else {
                [self startInterstitialInitialized];
            }
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Kidoz"]}]);
    }
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) handleInitNotification:(NSNotification*)notification {
    if (notification.userInfo[kATKidozInterstitialNotificationUserInfoErrorKey] != nil) {
        [_customEvent trackInterstitialAdLoadFailed:notification.userInfo[kATKidozInterstitialNotificationUserInfoErrorKey]];
    } else {
        [self startInterstitialInitialized];
    }
}

-(void) InterstitialInitNotification:(NSNotification*)notification {
    [self startLoad];
}

-(void) startInterstitialInitialized {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(InterstitialInitNotification:) name:kATKidozInterstitialInitializationNotification object:nil];
        [[NSClassFromString(kKidozSDKClassName) instance] initializeInterstitialWithDelegate:[ATKidozDelegate_Interstitial sharedDelegate]];
    });
}

- (void)startLoad {
    [[NSClassFromString(kKidozSDKClassName) instance] loadInterstitial];
}

@end
 
