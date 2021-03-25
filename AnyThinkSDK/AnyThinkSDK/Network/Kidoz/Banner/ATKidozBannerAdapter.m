//
//  ATKidozBannerAdapter.m
//  AnyThinkKidozAdapter
//
//  Created by Topon on 12/23/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATKidozBannerAdapter.h"
#import "ATKidozBannerCustomEvent.h"
#import "ATKidozBaseManager.h"
#import "ATAPI+Internal.h"
#import "ATAppSettingManager.h"
#import "ATAdAdapter.h"
#import "Utilities.h"
#import "ATAdManager+Banner.h"

static NSString *const kATKidozSDKBannerInitNotification = @"com.anythink.KidozDelegateInit";
static NSString *const kATKidozBannerInitializationNotification = @"com.anythink.KidozBannerInit";
NSString *const kATKidozBannerLoadedNotification = @"com.anythink.KidozBannerLoaded";
NSString *const kATKidozBannerFailedToLoadNotification = @"com.anythink.KidozBannerFailedToLoad";
NSString *const kATKidozBannerShowNotification = @"com.anythink.KidozBannerShow";
NSString *const kATKidozBannerCloseNotification = @"com.anythink.KidozBannerClose";
NSString *const kATKidozBannerNotificationUserInfoErrorKey = @"error";

static NSString *const kKidozSDKClassName = @"KidozSDK";
@interface ATKidozDelegate_Banner:NSObject<KDZInitDelegate,KDZBannerDelegate>
@property(nonatomic, weak) UIView *kidozBannerView;
@end

@implementation ATKidozDelegate_Banner
+(instancetype) sharedDelegate {
    static ATKidozDelegate_Banner *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATKidozDelegate_Banner alloc] init];
    });
    return sharedManager;
}

-(void)onInitSuccess{
    [ATLogger logMessage:@"KidozBannerDelegate::onInitSuccess" type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATKidozSDKBannerInitNotification object:nil];
}

-(void)onInitError:(NSString *)error{
    [ATLogger logMessage:[NSString stringWithFormat:@"KidozBannerDelegate::KidozSDKFailedToInitializeWithError:%@", error] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATKidozSDKBannerInitNotification object:nil userInfo:@{kATKidozBannerNotificationUserInfoErrorKey:[NSError errorWithDomain:@"com.anythink.KidozBannerInit" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"KidozSDK has failed to init", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"KidozSDK has failed to init with error:%@",error]}]}];
}

-(void)bannerDidInitialize {
    [ATLogger logMessage:@"KidozBannerDelegate::bannerDidInitialize:" type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATKidozBannerInitializationNotification object:nil];
}

-(void)bannerDidClose {
    [ATLogger logMessage:@"KidozBannerDelegate::bannerDidClose:" type:ATLogTypeExternal];
}

-(void)bannerDidOpen {
    [ATLogger logMessage:@"KidozBannerDelegate::bannerDidOpen:" type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATKidozBannerShowNotification object:nil userInfo:nil];
}

-(void)bannerIsReady {
    [ATLogger logMessage:@"KidozBannerDelegate::bannerIsReady:" type:ATLogTypeExternal];
    [[NSClassFromString(kKidozSDKClassName) instance] showBanner];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATKidozBannerLoadedNotification object:nil userInfo:nil];
}

-(void)bannerReturnedWithNoOffers {
    [ATLogger logMessage:@"KidozBannerDelegate::bannerReturnedWithNoOffers:" type:ATLogTypeExternal];
}

-(void)bannerLoadFailed {
    [ATLogger logMessage:@"KidozBannerDelegate::bannerLoadFailed:" type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATKidozBannerFailedToLoadNotification object:nil userInfo:@{kATKidozBannerNotificationUserInfoErrorKey:[NSError errorWithDomain:@"com.anythink.KidozBannerLoad" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"Kidoz has failed to load Banner.", NSLocalizedFailureReasonErrorKey:@"Kidoz Banner is load failed" }]}];
}

-(void)bannerDidReciveError:(NSString*)errorMessage {
    [ATLogger logMessage:[NSString stringWithFormat:@"KidozBannerDelegate::bannerDidReciveError:%@",errorMessage] type:ATLogTypeExternal];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kATKidozBannerFailedToLoadNotification object:nil userInfo:@{kATKidozBannerNotificationUserInfoErrorKey:[NSError errorWithDomain:@"com.anythink.KidozBannerLoad" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"Kidoz has failed to load Banner.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Kidoz Banner is load failed with error:%@",errorMessage]}]}];
}

-(void)bannerLeftApplication {
    [ATLogger logMessage:@"KidozBannerDelegate::bannerLeftApplication:" type:ATLogTypeExternal];
}

@end

@interface ATKidozBannerAdapter()
@property(nonatomic, readonly) ATKidozBannerCustomEvent *customEvent;
@property(nonatomic, readonly) NSDictionary *serverInfo;
@property(nonatomic, readonly) NSDictionary *localInfo;
@end

@implementation ATKidozBannerAdapter

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATKidozBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kKidozSDKClassName) != nil) {
        _serverInfo = serverInfo;
        _localInfo = localInfo;
        _customEvent = [[ATKidozBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        if (![[NSClassFromString(kKidozSDKClassName) instance] isSDKInitialized]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInitNotification:) name:kATKidozSDKBannerInitNotification object:nil];
            [[NSClassFromString(kKidozSDKClassName) instance] initializeWithPublisherID:serverInfo[@"publisher_id"] securityToken:serverInfo[@"security_token"] withDelegate:[ATKidozDelegate_Banner sharedDelegate]];
        } else {
            if ([[NSClassFromString(kKidozSDKClassName) instance] isBannerInitialized]) {
                [self startLoad];
            } else {
                [self startBannerInitialized];
            }
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Kidoz"]}]);
    }
}

-(void) handleInitNotification:(NSNotification*)notification {
    if (notification.userInfo[kATKidozBannerNotificationUserInfoErrorKey] != nil) {
        [_customEvent trackBannerAdLoadFailed:notification.userInfo[kATKidozBannerNotificationUserInfoErrorKey]];
    } else {
        [self startBannerInitialized];
    }
}

-(void) BannerInitNotification:(NSNotification*)notification {
    [self startLoad];
}

-(void) startBannerInitialized {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(BannerInitNotification:) name:kATKidozBannerInitializationNotification object:nil];
        
        CGSize adSize = [self.localInfo[kATAdLoadingExtraBannerAdSizeKey] respondsToSelector:@selector(CGSizeValue)] ? [self.localInfo[kATAdLoadingExtraBannerAdSizeKey] CGSizeValue] : CGSizeMake(320.0f, 50.0f);
        UIView *bannerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,adSize.width,adSize.height)];
        
        [[NSClassFromString(kKidozSDKClassName) instance] initializeBannerWithDelegate:[ATKidozDelegate_Banner sharedDelegate] withView:bannerView];
        [ATKidozDelegate_Banner sharedDelegate].kidozBannerView = bannerView;
    });
}

-(void) startLoad {
    [[NSClassFromString(kKidozSDKClassName) instance] hideBanner];

    self.customEvent.kidozBannerView = [ATKidozDelegate_Banner sharedDelegate].kidozBannerView;
    [[NSClassFromString(kKidozSDKClassName) instance] loadBanner];
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
