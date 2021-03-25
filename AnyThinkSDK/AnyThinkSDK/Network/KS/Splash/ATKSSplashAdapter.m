//
//  ATKSSplashAdapter.m
//  AnyThinkKuaiShouAdapter
//
//  Created by Topon on 11/20/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATKSSplashAdapter.h"
#import "ATKSSplashCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATSplashManager.h"
#import "ATAdManager+Splash.h"
#import "ATAppSettingManager.h"
#import "ATAdAdapter.h"
#import "ATKSBaseManager.h"
#import "ATSplash.h"

@interface ATKSSplashAdapter ()
@property(nonatomic, readonly) ATKSSplashCustomEvent *customEvent;
@end

@implementation ATKSSplashAdapter

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATKSBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    NSDictionary *extra = localInfo;
    NSTimeInterval tolerateTimeout = [extra containsObjectForKey:kATSplashExtraTolerateTimeoutKey] ? [extra[kATSplashExtraTolerateTimeoutKey] doubleValue] :[[ATAppSettingManager sharedManager] splashTolerateTimeout];
   
    if (NSClassFromString(@"KSAdSplashManager") != nil) {
        _customEvent = [[ATKSSplashCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.delegate = self.delegateToBePassed;
        
        [NSClassFromString(@"KSAdSplashManager") setPosId:serverInfo[@"position_id"]];
        [NSClassFromString(@"KSAdSplashManager") setInteractDelegate:_customEvent];
        [NSClassFromString(@"KSAdSplashManager") loadSplash];
        
        [NSClassFromString(@"KSAdSplashManager") checkSplashWithTimeout:tolerateTimeout  completion:^(id<ATKSAdSplashViewController> splashViewController) {
            if (splashViewController) {
                [self->_customEvent trackSplashAdLoaded:splashViewController adExtra:nil];
                
            }else {
                NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadSplashADMsg, NSLocalizedFailureReasonErrorKey:@"It check KS splash fail, No ads to display, splashViewController is nil."}];
                [self->_customEvent trackSplashAdLoadFailed:error];
            }
        }];
       
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadSplashADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"KS"]}]);
    }
}

+ (void)showSplash:(ATSplash *)splash localInfo:(NSDictionary*)localInfo delegate:(id<ATSplashDelegate>)delegate {
    UIWindow *window = localInfo[kATSplashExtraWindowKey];
    id<ATKSAdSplashViewController> splashViewController = splash.customObject;
    ATKSSplashCustomEvent *customEvent = (ATKSSplashCustomEvent *)splash.customEvent;
    customEvent.window = window;
    splashViewController.showDirection = [customEvent.localInfo[kATSplashExtraShowDirectionKey] boolValue] == YES ? KSAdShowDirection_Horizontal : KSAdShowDirection_Vertical;
    [customEvent.window.rootViewController presentViewController:(UIViewController *)splashViewController animated:YES completion:nil];
}

@end
