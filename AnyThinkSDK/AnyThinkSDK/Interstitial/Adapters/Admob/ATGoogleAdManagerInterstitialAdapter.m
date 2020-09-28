//
//  ATGoogleAdManagerInterstitialAdapter.m
//  AnyThinkAdmobInterstitialAdapter
//
//  Created by stephen on 7/27/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATGoogleAdManagerInterstitialAdapter.h"
#import "ATGoogleAdManagerInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAppSettingManager.h"

@interface ATGoogleAdManagerInterstitialAdapter()
@property(nonatomic, readonly) ATGoogleAdManagerInterstitialCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATDFPInterstitial> interstitial;
@end
@implementation ATGoogleAdManagerInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return ((id<ATDFPInterstitial>)customObject).isReady;
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    id<ATDFPInterstitial> admobInterstitial = interstitial.customObject;
    interstitial.customEvent.delegate = delegate;
    [admobInterstitial presentFromRootViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[ATAPI sharedInstance] setVersion:[[NSClassFromString(@"GADMobileAds") sharedInstance] sdkVersion] forNetwork:kNetworkNameGoogleAdManager];
                if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameGoogleAdManager]) {
                    [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameGoogleAdManager];
//                    id<ATPACConsentInformation> consentInfo = [NSClassFromString(@"PACConsentInformation") sharedInstance];
//                    if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameGoogleAdManager]) {
//                        consentInfo.consentStatus = [[ATAPI sharedInstance].networkConsentInfo[kNetworkNameGoogleAdManager][kGoogleAdManagerConsentStatusKey] integerValue];
//                        consentInfo.tagForUnderAgeOfConsent = [[ATAPI sharedInstance].networkConsentInfo[kNetworkNameGoogleAdManager][kGoogleAdManagerUnderAgeKey] boolValue];
//                    } else {
//                        BOOL set = NO;
//                        BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
//                        /**
//                        HasUserConsent: 0 Nonpersonalized, 1 Personalized
//                        */
//                        if (set) { consentInfo.consentStatus = limit ? ATPACConsentStatusNonPersonalized : ATPACConsentStatusPersonalized; }
//                    }
                }
            });
        });
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"DFPInterstitial") != nil && NSClassFromString(@"DFPRequest") != nil) {
        _customEvent = [[ATGoogleAdManagerInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        _interstitial = [[NSClassFromString(@"DFPInterstitial") alloc] initWithAdUnitID:serverInfo[@"unit_id"]];
        _interstitial.delegate = _customEvent;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_interstitial loadRequest:[NSClassFromString(@"DFPRequest") request]];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"GoogleAdManager"]}]);
    }
}
@end
