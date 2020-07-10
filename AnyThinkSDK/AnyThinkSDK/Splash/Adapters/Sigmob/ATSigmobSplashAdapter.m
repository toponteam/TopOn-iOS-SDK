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
-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameSigmob]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameSigmob];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"WindAds") sdkVersion] forNetwork:kNetworkNameSigmob];
            id<ATWindAdOptions> options = [NSClassFromString(@"WindAdOptions") options];
            options.appId = info[@"app_id"];
            options.apiKey = info[@"app_key"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSClassFromString(@"WindAds") startWithOptions:options];
            });
        }
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"WindSplashAd") != nil) {
        _customEvent = [[ATSigmobSplashCustomEvent alloc] initWithUnitID:info[@"placement_id"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.delegate = self.delegateToBePassed;
        NSDictionary *extra = info[kAdapterCustomInfoExtraKey];
        NSTimeInterval tolerateTimeout = [extra containsObjectForKey:kATSplashExtraTolerateTimeoutKey] ? [extra[kATSplashExtraTolerateTimeoutKey] doubleValue] : [[ATAppSettingManager sharedManager] splashTolerateTimeout];
        NSDate *curDate = [NSDate date];
        NSTimeInterval remainingTime = tolerateTimeout - [curDate timeIntervalSinceDate:extra[kATSplashExtraLoadingStartDateKey]];
        if (remainingTime > 0) {
            _splashAd = [[NSClassFromString(@"WindSplashAd") alloc] initWithPlacementId:info[@"placement_id"]];
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
            completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"It took too long to load placement stragety."}]);
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Sigmob"]}]);
    }
}
@end
