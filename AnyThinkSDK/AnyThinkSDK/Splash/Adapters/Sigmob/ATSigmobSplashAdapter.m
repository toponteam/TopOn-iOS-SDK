//
//  ATSigmobSplashAdapter.m
//  AnyThinkSigmobSplashAdapter
//
//  Created by Martin Lau on 2019/9/9.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATSigmobSplashAdapter.h"
#import "ATSigmobSplashCustomEvent.h"
#import "ATAdLoader.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATSplashManager.h"
#import "ATAdManager+Splash.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Internal.h"
#import "ATAppSettingManager.h"

@interface ATSigmobSplashAdapter()
@property(nonatomic, readonly) ATSigmobSplashCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATWindSplashAd> splashAd;
@end

@implementation ATSigmobSplashAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameSigmob]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameSigmob];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"WindAds") sdkVersion] forNetwork:kNetworkNameSigmob];
            id<ATWindAdOptions> options = [NSClassFromString(@"WindAdOptions") options];
            options.appId = serverInfo[@"app_id"];
            options.apiKey = serverInfo[@"app_key"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSClassFromString(@"WindAds") startWithOptions:options];
            });
        }
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"WindSplashAd") != nil) {
        NSDictionary *extra = localInfo;
        _customEvent = [[ATSigmobSplashCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.delegate = self.delegateToBePassed;
        NSTimeInterval tolerateTimeout = [extra containsObjectForKey:kATSplashExtraTolerateTimeoutKey] ? [extra[kATSplashExtraTolerateTimeoutKey] doubleValue] : [[ATAppSettingManager sharedManager] splashTolerateTimeout];
        NSDate *curDate = [NSDate date];
        NSTimeInterval remainingTime = tolerateTimeout - [curDate timeIntervalSinceDate:extra[kATSplashExtraLoadingStartDateKey]];
        if (remainingTime > 0) {
            _splashAd = [[NSClassFromString(@"WindSplashAd") alloc] initWithPlacementId:serverInfo[@"placement_id"]];
            _splashAd.delegate = _customEvent;
            _splashAd.fetchDelay = remainingTime;
            if (@available(iOS 13.0, *)) {
                UIWindowScene *scene = extra[kATSplashExtraWindowSceneKey];
                _splashAd.windowScene = scene;
            } else {
                // Fallback on earlier versions
            }
            [_splashAd loadAdAndShowWithBottomView:extra[kATSplashExtraContainerViewKey]];
        } else {
            completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadSplashADMsg, NSLocalizedFailureReasonErrorKey:kATSDKSplashADTooLongToLoadPlacementSettingMsg}]);
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadSplashADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Sigmob"]}]);
    }
}
@end
