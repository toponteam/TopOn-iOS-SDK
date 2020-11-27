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

@interface ATAdmobSplashAdapter ()
@property(nonatomic, readonly) ATAdmobSplashCustomEvent *customEvent;
@end

@implementation ATAdmobSplashAdapter

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[ATAPI sharedInstance] setVersion:[[NSClassFromString(@"GADMobileAds") sharedInstance] sdkVersion] forNetwork:kNetworkNameAdmob];
                if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameAdmob]) {
                    [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameAdmob];
                    id<ATPACConsentInformation> consentInfo = [NSClassFromString(@"PACConsentInformation") sharedInstance];
                    if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameAdmob]) {
                        consentInfo.consentStatus = [[ATAPI sharedInstance].networkConsentInfo[kNetworkNameAdmob][kAdmobConsentStatusKey] integerValue];
                        consentInfo.tagForUnderAgeOfConsent = [[ATAPI sharedInstance].networkConsentInfo[kNetworkNameAdmob][kAdmobUnderAgeKey] boolValue];
                    } else {
                        BOOL set = NO;
                        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                        BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                        if (set) { consentInfo.consentStatus = limit ? ATPACConsentStatusNonPersonalized : ATPACConsentStatusPersonalized; }
                    }
                }
            });
        });
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    NSTimeInterval tolerateTimeout = [localInfo containsObjectForKey:kATSplashExtraTolerateTimeoutKey] ? [localInfo[kATSplashExtraTolerateTimeoutKey] doubleValue] : [[ATAppSettingManager sharedManager] splashTolerateTimeout];
    NSDate *curDate = [NSDate date];
    NSTimeInterval remainingTime = tolerateTimeout - [curDate timeIntervalSinceDate:localInfo[kATSplashExtraLoadingStartDateKey]];
    if (remainingTime > 0) {
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
                    if ([[NSDate date] timeIntervalSinceDate:[curDate dateByAddingTimeInterval:remainingTime]] > 0) {
                        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadSplashADMsg, NSLocalizedFailureReasonErrorKey:@"It took too long for Admob to load splash."}];
                        [self.customEvent trackSplashAdLoadFailed:error];
                    } else {
                        [self->_customEvent trackSplashAdLoaded:appOpenAd];
                        UIWindow *window = localInfo[kATSplashExtraWindowKey];
                        appOpenAd.fullScreenContentDelegate = self->_customEvent;
                        [appOpenAd presentFromRootViewController:window.rootViewController];
                    }
                }
            }];
        } else {
            completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadSplashADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Admob"]}]);
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadSplashADMsg, NSLocalizedFailureReasonErrorKey:kATSDKSplashADTooLongToLoadPlacementSettingMsg}]);
    }
}

@end
