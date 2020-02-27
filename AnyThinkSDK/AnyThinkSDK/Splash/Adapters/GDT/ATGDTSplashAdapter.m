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

@interface ATGDTSplashAdapter()
@property(nonatomic, readonly) ATGDTSplashCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATGDTSplashAd> splashAd;
@end
@implementation ATGDTSplashAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameGDT]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameGDT];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"GDTSDKConfig") sdkVersion] forNetwork:kNetworkNameGDT];
        }
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"GDTSplashAd") != nil) {
        NSDictionary *extra = info[kAdapterCustomInfoExtraKey];
        NSTimeInterval tolerateTimeout = [extra containsObjectForKey:kATSplashExtraTolerateTimeoutKey] ? [extra[kATSplashExtraTolerateTimeoutKey] doubleValue] : [[ATAppSettingManager sharedManager] splashTolerateTimeout];
        NSDate *curDate = [NSDate date];
        NSTimeInterval remainingTime = tolerateTimeout - [curDate timeIntervalSinceDate:extra[kATSplashExtraLoadingStartDateKey]];
        if (remainingTime > 0) {
            _customEvent = [[ATGDTSplashCustomEvent alloc] initWithUnitID:info[@"unit_id"] customInfo:info];
            _customEvent.requestCompletionBlock = completion;
            _customEvent.delegate = self.delegateToBePassed;
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_splashAd = [[NSClassFromString(@"GDTSplashAd") alloc] initWithAppId:info[@"app_id"] placementId:info[@"unit_id"]];
                self->_splashAd.delegate = self->_customEvent;
                self->_splashAd.fetchDelay = remainingTime;
                NSDictionary *extra = info[kAdapterCustomInfoExtraKey];
                self->_customEvent.backgroundImageView = extra[kATSplashExtraBackgroundImageViewKey];
                if ([extra containsObjectForKey:kATSplashExtraBackgroundColorKey]) { self->_splashAd.backgroundColor = extra[kATSplashExtraBackgroundColorKey]; }
                if ([extra containsObjectForKey:kATSplashExtraBackgroundImageKey]) { self->_splashAd.backgroundImage = extra[kATSplashExtraBackgroundImageKey]; }
                if ([extra containsObjectForKey:kATSplashExtraSkipButtonCenterKey]) { self->_splashAd.skipButtonCenter = [extra[kATSplashExtraSkipButtonCenterKey] CGPointValue]; }
                [self->_splashAd loadAdAndShowInWindow:extra[kATSplashExtraWindowKey] withBottomView:extra[kATSplashExtraContainerViewKey] skipView:extra[kATSplashExtraCustomSkipButtonKey]];
            });
        } else {
            completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"It took too long to load placement stragety."}]);
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"GDT"]}]);
    }
}
@end
