//
//  ATBaiduSplashAdapter.m
//  AnyThinkBaiduSplashAdapter
//
//  Created by Martin Lau on 2018/12/21.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATBaiduSplashAdapter.h"
#import "ATBaiduSplashCustomEvent.h"
#import "ATAdLoader.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATSplashManager.h"
#import "ATAdManager+Splash.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Internal.h"
#import "ATBaiduBaseManager.h"
#import "ATSplash.h"

@interface ATBaiduSplashAdapter()
@property(nonatomic, readonly) ATBaiduSplashCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATBaiduMobAdSplash> splash;
@end

@implementation ATBaiduSplashAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATBaiduBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    NSDictionary *extra = localInfo;
    if (NSClassFromString(@"BaiduMobAdSplash") != nil) {
        _customEvent = [[ATBaiduSplashCustomEvent alloc] initWithPublisherID:serverInfo[@"app_id"] unitID:serverInfo[kATSplashExtraPlacementIDKey] != nil ? serverInfo[kATSplashExtraPlacementIDKey] : extra[kATSplashExtraPlacementIDKey] serverInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.delegate = self.delegateToBePassed;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_splash = [[NSClassFromString(@"BaiduMobAdSplash") alloc] init];
            self->_splash.delegate = self->_customEvent;
            self->_splash.AdUnitTag = serverInfo[@"ad_place_id"];
            UIView *containerView = extra[kATSplashExtraContainerViewKey];
            containerView.frame = CGRectMake(CGRectGetMidX([UIScreen mainScreen].bounds) - CGRectGetMidX(containerView.bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetHeight(containerView.bounds), CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
            self->_customEvent.containerView = containerView;
            
            if ([extra containsObjectForKey:kATSplashExtraCanClickFlagKey]) { self->_splash.canSplashClick = [extra[kATSplashExtraCanClickFlagKey] boolValue]; }
            self->_splash.adSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - CGRectGetHeight(containerView.bounds));
            [self->_splash load];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadSplashADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Baidu"]}]);
    }
}

+ (void)showSplash:(ATSplash *)splash localInfo:(NSDictionary*)localInfo delegate:(id<ATSplashDelegate>)delegate{
    UIWindow *window = localInfo[kATSplashExtraWindowKey];
    
    id<ATBaiduMobAdSplash> splashAd = splash.customObject;
    ATBaiduSplashCustomEvent *customEvent = (ATBaiduSplashCustomEvent *)splash.customEvent;
    if (customEvent.splashView == nil || customEvent.splashView.superview == nil) {
        UIView *splashView = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetHeight(customEvent.containerView.bounds))];
        customEvent.window = window;
        customEvent.splashView = splashView;
        [window addSubview:customEvent.splashView];
        [splashAd showInContainerView:customEvent.splashView];
    }
}

@end
