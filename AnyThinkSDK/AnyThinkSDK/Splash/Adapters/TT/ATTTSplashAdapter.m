//
//  ATTTSplashAdapter.m
//  AnyThinkTTSplashAdapter
//
//  Created by Martin Lau on 2018/12/21.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATTTSplashAdapter.h"
#import "ATTTSplashCustomEvent.h"
#import "ATAdLoader.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATSplashManager.h"
#import "ATAdManager+Splash.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Internal.h"
#import "ATAppSettingManager.h"

@interface ATTTSplashAdapter()
@property(nonatomic, readonly) ATTTSplashCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATBUSplashAdView> splashView;
@end

@implementation ATTTSplashAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameTT]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameTT];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"BUAdSDKManager") SDKVersion] forNetwork:kNetworkNameTT];
            [NSClassFromString(@"BUAdSDKManager") setAppID:serverInfo[@"app_id"]];
        }
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    NSDictionary *extra = localInfo;
    NSTimeInterval tolerateTimeout = [extra containsObjectForKey:kATSplashExtraTolerateTimeoutKey] ? [extra[kATSplashExtraTolerateTimeoutKey] doubleValue] :[[ATAppSettingManager sharedManager] splashTolerateTimeout];
    NSDate *curDate = [NSDate date];
    NSTimeInterval remainingTime = tolerateTimeout - [curDate timeIntervalSinceDate:extra[kATSplashExtraLoadingStartDateKey]];
    if (remainingTime > 0) {
        if (NSClassFromString(@"BUSplashAdView") != nil) {
            _customEvent = [[ATTTSplashCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
            _customEvent.requestCompletionBlock = completion;
            _customEvent.delegate = self.delegateToBePassed;
            _customEvent.expireDate = [curDate dateByAddingTimeInterval:remainingTime];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIWindow *window = extra[kATSplashExtraWindowKey];
                UIView *containerView = extra[kATSplashExtraContainerViewKey];
                self->_customEvent.containerView = containerView;
                containerView.frame = CGRectMake(CGRectGetMidX([UIScreen mainScreen].bounds) - CGRectGetMidX(containerView.bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetHeight(containerView.bounds), CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
                if ([serverInfo[@"personalized_template"]integerValue] == 1) {
                    self->_splashView = [[NSClassFromString(@"BUNativeExpressSplashView") alloc] initWithSlotID:serverInfo[@"slot_id"] adSize:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds)) rootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
                } else {
                    self->_splashView = [[NSClassFromString(@"BUSplashAdView") alloc] initWithSlotID:serverInfo[@"slot_id"] frame:CGRectMake(.0f, .0f, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetHeight(containerView.bounds))];
                    self->_splashView.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                }
                self->_splashView.tolerateTimeout = remainingTime;
                if (extra[kATSplashExtraHideSkipButtonFlagKey]) { self->_splashView.hideSkipButton = [extra[kATSplashExtraHideSkipButtonFlagKey] boolValue]; }
                self->_splashView.delegate = self->_customEvent;
                self->_customEvent.ttSplashView = (UIView*)self->_splashView;
                self->_customEvent.window = window;
                self->_customEvent.containerView = containerView;
                self->_customEvent.backgroundImageView = extra[kATSplashExtraBackgroundImageViewKey];
                [self->_splashView loadAdData];
            });
        } else {
            completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadSplashADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"TT"]}]);
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadSplashADMsg, NSLocalizedFailureReasonErrorKey:kATSDKSplashADTooLongToLoadPlacementSettingMsg}]);
    }
}
@end
