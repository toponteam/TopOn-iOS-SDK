//
//  ATStartAppSplashAdapter.m
//  AnyThinkStartAppSplashAdapter
//
//  Created by Martin Lau on 2020/6/15.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATStartAppSplashAdapter.h"
#import "ATAPI+Internal.h"
#import "ATAppSettingManager.h"
#import "ATStartAppSplashCustomEvent.h"
#import "ATAdAdapter.h"
#import "ATSplashManager.h"
#import "ATAdManager+Splash.h"
#import "ATAdManager+Internal.h"
#import "Utilities.h"
@interface ATStartAppSplashAdapter()
@property(nonatomic, readonly) ATStartAppSplashCustomEvent *customEvent;
@end
@implementation ATStartAppSplashAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameStartApp]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameStartApp];
            dispatch_async(dispatch_get_main_queue(), ^{
                id<ATSTAStartAppSDK> sdk = [NSClassFromString(@"STAStartAppSDK") sharedInstance];
//                testmode
                sdk.testAdsEnabled = YES;
                BOOL set = NO;
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                if (set) { [sdk setUserConsent:!limit forConsentType:@"pas" withTimestamp:[[NSDate date] timeIntervalSince1970]]; }
                sdk.appID = info[@"app_id"];
            });
        }
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"STAStartAppSDK") != nil) {
        _customEvent = [[ATStartAppSplashCustomEvent alloc] initWithUnitID:@"" customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.delegate = self.delegateToBePassed;
        NSDictionary *extra = info[kAdapterCustomInfoExtraKey];
        NSTimeInterval tolerateTimeout = [extra containsObjectForKey:kATSplashExtraTolerateTimeoutKey] ? [extra[kATSplashExtraTolerateTimeoutKey] doubleValue] : [[ATAppSettingManager sharedManager] splashTolerateTimeout];
        NSDate *curDate = [NSDate date];
        NSTimeInterval remainingTime = tolerateTimeout - [curDate timeIntervalSinceDate:extra[kATSplashExtraLoadingStartDateKey]];
        if (remainingTime > 0) {
            id<ATSTAAdPreferences> adPreference = [NSClassFromString(@"STAAdPreferences") new];
            adPreference.adTag = info[@"ad_tag"];
            id<ATSTASplashPreferences> splashPreference = [NSClassFromString(@"STASplashPreferences") new];
            splashPreference.splashAdDisplayTime = 86400;
            splashPreference.splashMinTime = 5;
            splashPreference.splashMode = 2;
            [[NSClassFromString(@"STAStartAppSDK") sharedInstance] showSplashAdWithDelegate:_customEvent withPreferences:splashPreference];
        } else {
            completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"It took too long to load placement stragety."}]);
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Mintegral"]}]);
    }
}
@end
