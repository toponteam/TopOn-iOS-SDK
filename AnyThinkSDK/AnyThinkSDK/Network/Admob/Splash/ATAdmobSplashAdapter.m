//
//  ATAdmobSplashAdapter.m
//  AnyThinkAdmobSplashAdapter
//
//  Created by Topon on 9/30/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATAdmobSplashAdapter.h"
#import "ATAPI+Internal.h"
#import "ATSplashManager.h"
#import "ATAdManager+Splash.h"
#import "Utilities.h"
#import "ATAppSettingManager.h"
#import "ATAdmobSplashCustomEvent.h"
#import "ATAdManager+Internal.h"
#import "ATAdmobBaseManager.h"
#import "ATSplash.h"

@interface ATAdmobSplashAdapter ()
@property(nonatomic, readonly) ATAdmobSplashCustomEvent *customEvent;
@end

@implementation ATAdmobSplashAdapter

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATAdmobBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"GADAppOpenAd") != nil && NSClassFromString(@"GADRequest") != nil) {
        _customEvent = [[ATAdmobSplashCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.delegate = self.delegateToBePassed;
        //orientation to do 3 & 4, api not return
        [NSClassFromString(@"GADAppOpenAd") loadWithAdUnitID:serverInfo[@"unit_id"]
                                                     request:[NSClassFromString(@"GADRequest") request]
                                                 orientation:[@{@1:@(UIInterfaceOrientationPortrait), @2:@(UIInterfaceOrientationLandscapeLeft),@3:@(UIInterfaceOrientationPortraitUpsideDown),@4:@(UIInterfaceOrientationLandscapeRight)}[@([serverInfo[@"orientation"] integerValue])] integerValue]
                                           completionHandler:^(id<ATGADAppOpenAd> appOpenAd, NSError *_Nullable error) {
            if (error) {
                [self.customEvent trackSplashAdLoadFailed:error];
            }else {
                [self->_customEvent trackSplashAdLoaded:appOpenAd adExtra:nil];
            }
        }];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadSplashADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Admob"]}]);
    }
}

+ (void)showSplash:(ATSplash *)splash localInfo:(NSDictionary*)localInfo delegate:(id<ATSplashDelegate>)delegate {
    UIWindow *window = localInfo[kATSplashExtraWindowKey];
    id<ATGADAppOpenAd> appOpenAd = splash.customObject;
    appOpenAd.fullScreenContentDelegate = (id<GADFullScreenContentDelegate>)splash.customEvent;
    [appOpenAd presentFromRootViewController:window.rootViewController];
    [splash.customEvent trackSplashAdShow];
}

@end
