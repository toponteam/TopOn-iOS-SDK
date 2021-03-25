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
#import "ATPangleBaseManager.h"
#import "ATSplashAdapter.h"
#import "ATSplash.h"

@interface ATTTSplashAdapter()
@property(nonatomic, readonly) ATTTSplashCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATBUSplashAdView> splashView;
@end

@implementation ATTTSplashAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATPangleBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    NSDictionary *extra = localInfo;
    NSTimeInterval tolerateTimeout = [extra containsObjectForKey:kATSplashExtraTolerateTimeoutKey] ? [extra[kATSplashExtraTolerateTimeoutKey] doubleValue] :[[ATAppSettingManager sharedManager] splashTolerateTimeout];
    
    if (NSClassFromString(@"BUSplashAdView") != nil) {
        _customEvent = [[ATTTSplashCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.delegate = self.delegateToBePassed;
        _customEvent.expireDate = [[NSDate date] dateByAddingTimeInterval:tolerateTimeout];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIView *containerView = extra[kATSplashExtraContainerViewKey];
            self->_customEvent.containerView = containerView;
            containerView.frame = CGRectMake(CGRectGetMidX([UIScreen mainScreen].bounds) - CGRectGetMidX(containerView.bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetHeight(containerView.bounds), CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
            if ([serverInfo[@"personalized_template"]integerValue] == 1) {
                self->_splashView = [[NSClassFromString(@"BUNativeExpressSplashView") alloc] initWithSlotID:serverInfo[@"slot_id"] adSize:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetHeight(containerView.bounds)) rootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
            } else {
                self->_splashView = [[NSClassFromString(@"BUSplashAdView") alloc] initWithSlotID:serverInfo[@"slot_id"] frame:CGRectMake(.0f, .0f, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetHeight(containerView.bounds))];
                self->_splashView.needSplashZoomOutAd = [serverInfo[kATSplashExtraZoomOutKey] intValue] == 2;
                self->_splashView.zoomOutView.delegate = self->_customEvent;
                self->_splashView.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            }
            self->_splashView.tolerateTimeout = tolerateTimeout;
            if (extra[kATSplashExtraHideSkipButtonFlagKey]) { self->_splashView.hideSkipButton = [extra[kATSplashExtraHideSkipButtonFlagKey] boolValue]; }
            self->_splashView.delegate = self->_customEvent;
            self->_customEvent.ttSplashView = (UIView*)self->_splashView;
            self->_customEvent.containerView = containerView;
            [self->_splashView loadAdData];
        });
        
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadSplashADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"TT"]}]);
    }
}

+ (void)showSplash:(ATSplash *)splash localInfo:(NSDictionary *)localInfo delegate:(id<ATSplashDelegate>)delegate {
    UIWindow *window = localInfo[kATSplashExtraWindowKey];
    id<ATBUSplashAdView> splashView = splash.customObject;
    splashView.rootViewController = window.rootViewController;
    
    ATTTSplashCustomEvent *customEvent = (ATTTSplashCustomEvent *)splashView.delegate;
    customEvent.backgroundImageView = localInfo[kATSplashExtraBackgroundImageViewKey];
    [window addSubview:customEvent.containerView];
    [window addSubview:customEvent.ttSplashView];
    [customEvent trackSplashAdShow];
}

@end
