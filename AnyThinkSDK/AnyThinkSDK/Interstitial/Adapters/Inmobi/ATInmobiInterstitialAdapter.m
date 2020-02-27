//
//  ATInmobiInterstitialAdapter.m
//  AnyThinkInmobiInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/8.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATInmobiInterstitialAdapter.h"
#import "ATInmobiInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATAPI+Internal.h"
#import "ATAppSettingManager.h"
@interface ATInmobiInterstitialAdapter()
@property(nonatomic, readonly) ATInmobiInterstitialCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATIMInterstitial> interstitial;
@end

static NSString *const kUnitIDKey = @"unit_id";
@implementation ATInmobiInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return customObject != nil;
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    [((id<ATIMInterstitial>)interstitial.customObject) showFromViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"IMSdk") getVersion] forNetwork:kNetworkNameInmobi];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameInmobi]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameInmobi];
                [NSClassFromString(@"IMSdk") initWithAccountID:info[@"app_id"]];
                if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameInmobi]) {
                    [NSClassFromString(@"IMSdk") updateGDPRConsent:@{@"gdpr_consent_available":[ATAPI sharedInstance].networkConsentInfo[kNetworkNameInmobi][kInmobiConsentStringKey], @"gdpr":[ATAPI sharedInstance].networkConsentInfo[kNetworkNameInmobi][kInmobiGDPRStringKey]}];
                } else {
                    BOOL set = NO;
                    BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                    if (set) {
                        /**
                        GDPRConsent: @@"false" Nonpersonalized, @"true" Personalized
                        */
                        [NSClassFromString(@"IMSdk") updateGDPRConsent:@{@"gdpr_consent_available":limit ? @"false" : @"true", @"gdpr":[[ATAPI sharedInstance] inDataProtectionArea] ? @"1" : @"0"}];
                    }
                }
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    info = [NSMutableDictionary dictionaryWithDictionary:info];
    if (NSClassFromString(@"IMInterstitial") != nil) {
        _customEvent = [[ATInmobiInterstitialCustomEvent alloc] initWithUnitID:info[kUnitIDKey] customInfo:info];
        _customEvent.requestNumber = [info[@"request_num"] longValue];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
        id<ATIMInterstitial> interstitial = (id<ATIMInterstitial>)[[NSClassFromString(@"IMInterstitial") alloc] initWithPlacementId:[info[kUnitIDKey] integerValue]  delegate:_customEvent];
        _interstitial = interstitial;
        _customEvent.interstitial = interstitial;
        for (NSInteger i = 0; i < [info[@"request_num"] integerValue]; i++) [interstitial load];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Inmobi"]}]);
    }
}
@end
