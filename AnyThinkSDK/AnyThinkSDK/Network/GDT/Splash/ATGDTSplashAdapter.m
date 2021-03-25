//
//  ATGDTSplashAdapter.m
//  AnyThinkGDTSplashAdapter
//
//  Created by Martin Lau on 2018/12/20.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATGDTSplashAdapter.h"
#import "ATGDTSplashCustomEvent.h"
#import "ATAdLoader.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATSplashManager.h"
#import "ATAdManager+Splash.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Internal.h"
#import "ATAppSettingManager.h"
#import "ATGDTBaseManager.h"
#import "ATSplash.h"
#import "UIView+ATGDTDraggable.h"

@interface ATGDTSplashAdapter()
@property(nonatomic, readonly) ATGDTSplashCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATGDTSplashAd> splashAd;
@end
@implementation ATGDTSplashAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATGDTBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"GDTSplashAd") != nil) {
        NSDictionary *extra = localInfo;
        NSTimeInterval tolerateTimeout = [extra containsObjectForKey:kATSplashExtraTolerateTimeoutKey] ? [extra[kATSplashExtraTolerateTimeoutKey] doubleValue] : [[ATAppSettingManager sharedManager] splashTolerateTimeout];

            _customEvent = [[ATGDTSplashCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
            _customEvent.requestCompletionBlock = completion;
            _customEvent.delegate = self.delegateToBePassed;
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_splashAd = [[NSClassFromString(@"GDTSplashAd") alloc] initWithAppId:serverInfo[@"app_id"] placementId:serverInfo[@"unit_id"]];
                self->_splashAd.delegate = self->_customEvent;
                self->_splashAd.fetchDelay = tolerateTimeout;
                NSDictionary *extra = localInfo;
                self->_customEvent.backgroundImageView = extra[kATSplashExtraBackgroundImageViewKey];
                if ([extra containsObjectForKey:kATSplashExtraBackgroundColorKey]) { self->_splashAd.backgroundColor = extra[kATSplashExtraBackgroundColorKey]; }
                if ([extra containsObjectForKey:kATSplashExtraBackgroundImageKey]) { self->_splashAd.backgroundImage = extra[kATSplashExtraBackgroundImageKey]; }
                if ([extra containsObjectForKey:kATSplashExtraSkipButtonCenterKey]) { self->_splashAd.skipButtonCenter = [extra[kATSplashExtraSkipButtonCenterKey] CGPointValue]; }
                self->_splashAd.needZoomOut = [serverInfo[@"zoomoutad_sw"] integerValue] == 2 ? YES : NO;
                [self->_splashAd loadAd];
            });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadSplashADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"GDT"]}]);
    }
}

+ (void)showSplash:(ATSplash *)splash localInfo:(NSDictionary*)localInfo delegate:(id<ATSplashDelegate>)delegate {
    UIWindow *window = localInfo[kATSplashExtraWindowKey];
    id<ATGDTSplashAd> splashAd = splash.customObject;
    NSDictionary *extra = splash.customEvent.localInfo;
    [splashAd showAdInWindow:window withBottomView:extra[kATSplashExtraContainerViewKey] skipView:extra[kATSplashExtraCustomSkipButtonKey]];
    
    if (splashAd.splashZoomOutView) {
        [window.rootViewController.view addSubview:splashAd.splashZoomOutView];
        splashAd.splashZoomOutView.rootViewController = window.rootViewController;
        splash.customEvent.delegate = delegate;
        //support Drag
        [splashAd.splashZoomOutView supportDrag];
    }
}
@end
