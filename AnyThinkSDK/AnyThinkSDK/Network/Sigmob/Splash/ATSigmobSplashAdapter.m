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
#import "ATSigmobBaseManager.h"
#import "ATSplash.h"

@interface ATSigmobSplashAdapter()
@property(nonatomic, readonly) ATSigmobSplashCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATWindSplashAd> splashAd;
@end

@implementation ATSigmobSplashAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATSigmobBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"WindSplashAd") != nil) {
        _customEvent = [[ATSigmobSplashCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.delegate = self.delegateToBePassed;
        NSTimeInterval tolerateTimeout = [localInfo containsObjectForKey:kATSplashExtraTolerateTimeoutKey] ? [localInfo[kATSplashExtraTolerateTimeoutKey] doubleValue] : [[ATAppSettingManager sharedManager] splashTolerateTimeout];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIView *containerView = localInfo[kATSplashExtraContainerViewKey];
            containerView.frame = CGRectMake(CGRectGetMidX([UIScreen mainScreen].bounds) - CGRectGetMidX(containerView.bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetHeight(containerView.bounds), CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
            
            NSDictionary *extra = @{
                @"AdSize":NSStringFromCGSize(CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetHeight(containerView.bounds))),
                @"rootViewController":[UIApplication sharedApplication].keyWindow.rootViewController};
            self->_splashAd = [[NSClassFromString(@"WindSplashAd") alloc] initWithPlacementId:serverInfo[@"placement_id"] extra:extra];
            self->_splashAd.delegate = self->_customEvent;
            self->_splashAd.fetchDelay = tolerateTimeout;
            [self->_splashAd loadAd];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadSplashADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Sigmob"]}]);
    }
}

+ (void)showSplash:(ATSplash *)splash localInfo:(NSDictionary *)localInfo delegate:(id<ATSplashDelegate>)delegate {
    id<ATWindSplashAd> splashAd = splash.customObject;
    ATSigmobSplashCustomEvent *customEvent = (ATSigmobSplashCustomEvent *)splashAd.delegate;
    UIWindow *window = localInfo[kATSplashExtraWindowKey];
    [splashAd showAdInWindow:window withBottomView:customEvent.localInfo[kATSplashExtraContainerViewKey]];
    [customEvent trackSplashAdShow];
}

@end
