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
#import "ATMintegralBaseManager.h"
#import "ATSplash.h"

@interface ATMintegralSplashAdapter()
@property(nonatomic, readonly) ATMintegralSplashCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATMTGSplashAD> splashAd;
@end
@implementation ATMintegralSplashAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATMintegralBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"MTGSplashAD") != nil) {
        NSDictionary *extra = localInfo;
        _customEvent = [[ATMintegralSplashCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.delegate = self.delegateToBePassed;
        NSTimeInterval tolerateTimeout = [extra containsObjectForKey:kATSplashExtraTolerateTimeoutKey] ? [extra[kATSplashExtraTolerateTimeoutKey] doubleValue] : [[ATAppSettingManager sharedManager] splashTolerateTimeout];
        UIView *containerView = [extra[kATSplashExtraContainerViewKey] isKindOfClass:[UIView class]] ? extra[kATSplashExtraContainerViewKey] : nil;

        dispatch_async(dispatch_get_main_queue(), ^{
            self->_customEvent.containerView = containerView;
            self->_customEvent.timeRemaining = tolerateTimeout;
            self->_customEvent.loadStartingDate = [NSDate date];
            self->_splashAd = [[NSClassFromString(@"MTGSplashAD") alloc] initWithPlacementID:serverInfo[@"placement_id"] unitID:serverInfo[@"unitid"] countdown:[serverInfo[@"countdown"] integerValue] allowSkip:[serverInfo[@"allows_skip"] boolValue] customViewSize:containerView.bounds.size preferredOrientation:[serverInfo[@"orientation"] integerValue]];
            self->_splashAd.delegate = self->_customEvent;
            [self->_splashAd preload];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadSplashADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Mintegral"]}]);
    }
}

+(NSString*) adsourceRemoteKeyWithContent:(NSDictionary*)content unitGroupModel:(ATUnitGroupModel *)unitGroupModel {
    return content[@"unitid"];
}

+ (void)showSplash:(ATSplash *)splash localInfo:(NSDictionary*)localInfo delegate:(id<ATSplashDelegate>)delegate {
    UIWindow *window = localInfo[kATSplashExtraWindowKey];
    id<ATMTGSplashAD> splashAD = splash.customObject;
    ATMintegralSplashCustomEvent *customEvent = (ATMintegralSplashCustomEvent *)splash.customEvent;
    [splashAD showInKeyWindow:window customView:customEvent.containerView];
}

@end
