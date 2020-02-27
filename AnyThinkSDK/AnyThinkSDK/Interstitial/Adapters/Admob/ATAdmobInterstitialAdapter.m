//
//  ATAdmobInterstitialAdapter.m
//  AnyThinkAdmobInterstitialAdapter
//
//  Created by Martin Lau on 25/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdmobInterstitialAdapter.h"
#import "ATAdmobInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAppSettingManager.h"

@interface ATAdmobInterstitialAdapter()
@property(nonatomic, readonly) ATAdmobInterstitialCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATGADInterstitial> interstitial;
@end
@implementation ATAdmobInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return ((id<ATGADInterstitial>)customObject).isReady;
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    id<ATGADInterstitial> admobInterstitial = interstitial.customObject;
    interstitial.customEvent.delegate = delegate;
    [admobInterstitial presentFromRootViewController:viewController];
}

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
                        /**
                        HasUserConsent: 0 Nonpersonalized, 1 Personalized
                        */
                        if (set) { consentInfo.consentStatus = limit ? ATPACConsentStatusNonPersonalized : ATPACConsentStatusPersonalized; }
                    }
                }
            });
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"GADInterstitial") != nil && NSClassFromString(@"GADRequest") != nil) {
        _customEvent = [[ATAdmobInterstitialCustomEvent alloc] initWithUnitID:info[@"unit_id"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        _interstitial = [[NSClassFromString(@"GADInterstitial") alloc] initWithAdUnitID:info[@"unit_id"]];
        _interstitial.delegate = _customEvent;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_interstitial loadRequest:[NSClassFromString(@"GADRequest") request]];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Admob"]}]);
    }
}
@end
