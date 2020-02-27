//
//  ATAdmobBannerAdapter.m
//  AnyThinkAdmobBannerAdapter
//
//  Created by Martin Lau on 18/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdmobBannerAdapter.h"
#import "ATAdmobBannerCustomEvent.h"
#import "ATAPI+Internal.h"
#import "ATBannerManager.h"
#import "ATAdManager+Banner.h"
#import <objc/runtime.h>
#import "Utilities.h"
#import "ATAppSettingManager.h"

@interface ATAdmobBannerAdapter()
@property(nonatomic, readonly) ATAdmobBannerCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATGADBannerView> bannerView;
@end
@implementation ATAdmobBannerAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"GADRequest") sdkVersion] forNetwork:kNetworkNameAdmob];
                if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameAdmob]) {
                    [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameAdmob];
                    id<ATPACConsentInformation> consentInfo = [NSClassFromString(@"PACConsentInformation") sharedInstance];
                    if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameAdmob]) {
                        consentInfo.consentStatus = [[ATAPI sharedInstance].networkConsentInfo[kNetworkNameAdmob][kAdmobConsentStatusKey] integerValue];
                        consentInfo.tagForUnderAgeOfConsent = [[ATAPI sharedInstance].networkConsentInfo[kNetworkNameAdmob][kAdmobUnderAgeKey] boolValue];
                    } else {
                        BOOL set = NO;
                        BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                        if (set) { consentInfo.consentStatus = limit ? ATPACConsentStatusNonPersonalized : ATPACConsentStatusPersonalized; }
                    }
                }
            });
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"GADBannerView") != nil && NSClassFromString(@"GADRequest") != nil) {
        _customEvent = [[ATAdmobBannerCustomEvent alloc] initWithUnitID:info[@"unit_id"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        CGSize unitGroupSize = ((ATUnitGroupModel*)info[kAdapterCustomInfoUnitGroupModelKey]).adSize;
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_bannerView = [[NSClassFromString(@"GADBannerView") alloc] initWithAdSize:(GADAdSize){CGSizeMake(unitGroupSize.width, unitGroupSize.height), 0}];
            self->_bannerView.adUnitID = info[@"unit_id"];
            self->_bannerView.delegate = self->_customEvent;
            self->_bannerView.adSizeDelegate = self->_customEvent;
            self->_bannerView.rootViewController = [ATBannerCustomEvent rootViewControllerWithPlacementID:((ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey]).placementID requestID:info[kAdapterCustomInfoRequestIDKey]];
            [self->_bannerView loadRequest:[NSClassFromString(@"GADRequest") request]];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load banner.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Admob"]}]);
    }
}
@end
