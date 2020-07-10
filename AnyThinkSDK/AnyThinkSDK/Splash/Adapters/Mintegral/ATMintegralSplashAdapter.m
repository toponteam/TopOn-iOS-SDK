//
//  ATMintegralSplashAdapter.m
//  AnyThinkMintegralSplashAdapter
//
//  Created by Martin Lau on 2020/6/9.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATMintegralSplashAdapter.h"
#import "ATMintegralSplashCustomEvent.h"
#import "ATAdLoader.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATSplashManager.h"
#import "ATAdManager+Splash.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Internal.h"
#import "ATAppSettingManager.h"
@interface ATMintegralSplashAdapter()
@property(nonatomic, readonly) ATMintegralSplashCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATMTGSplashAD> splashAd;
@end
@implementation ATMintegralSplashAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"MTGSDK") sdkVersion] forNetwork:kNetworkNameMintegral];
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMintegral]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMintegral];
            void(^blk)(void) = ^{
                BOOL set = NO;
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                if (set) { ((id<ATMTGSDK>)[NSClassFromString(@"MTGSDK") sharedInstance]).consentStatus = !limit; }
                [[NSClassFromString(@"MTGSDK") sharedInstance] setAppID:info[@"appid"] ApiKey:info[@"appkey"]];
            };
            if ([NSThread currentThread].isMainThread) blk();
            else dispatch_sync(dispatch_get_main_queue(), blk);
        }
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"MTGSplashAD") != nil) {
        _customEvent = [[ATMintegralSplashCustomEvent alloc] initWithUnitID:info[@"unitid"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.delegate = self.delegateToBePassed;
        NSDictionary *extra = info[kAdapterCustomInfoExtraKey];
        NSTimeInterval tolerateTimeout = [extra containsObjectForKey:kATSplashExtraTolerateTimeoutKey] ? [extra[kATSplashExtraTolerateTimeoutKey] doubleValue] : [[ATAppSettingManager sharedManager] splashTolerateTimeout];
        NSDate *curDate = [NSDate date];
        NSTimeInterval remainingTime = tolerateTimeout - [curDate timeIntervalSinceDate:extra[kATSplashExtraLoadingStartDateKey]];
        UIView *containerView = [extra[kATSplashExtraContainerViewKey] isKindOfClass:[UIView class]] ? extra[kATSplashExtraContainerViewKey] : nil;
        if (remainingTime > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_customEvent.window = extra[kATSplashExtraWindowKey];
                self->_customEvent.containerView = containerView;
                self->_customEvent.timeRemaining = remainingTime;
                self->_customEvent.loadStartingDate = [NSDate date];
                self->_splashAd = [[NSClassFromString(@"MTGSplashAD") alloc] initWithPlacementID:info[@"placement_id"] unitID:info[@"unitid"] countdown:[info[@"countdown"] integerValue] allowSkip:[info[@"allows_skip"] boolValue] customViewSize:containerView.bounds.size preferredOrientation:[info[@"orientation"] integerValue]];
                self->_splashAd.delegate = self->_customEvent;
                [self->_splashAd preload];
            });
        } else {
            completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"It took too long to load placement stragety."}]);
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Mintegral"]}]);
    }
}
@end
