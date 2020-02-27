//
//  ATFlurryBannerAdapter.m
//  AnyThinkFlurryBannerAdapter
//
//  Created by Martin Lau on 2018/10/8.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATFlurryBannerAdapter.h"
#import "ATAPI+Internal.h"
#import "ATFlurryBannerCustomEvent.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
@interface ATFlurryBannerAdapter()
@property(nonatomic, readonly) ATFlurryBannerCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATFlurryAdBanner> banner;
@end

static NSString *const kSpaceKey = @"ad_space";
@implementation ATFlurryBannerAdapter
+(void) showBanner:(ATBanner*)banner inView:(UIView*)view presentingViewController:(UIViewController*)viewController {
    [banner.bannerView displayAdInView:view viewControllerForPresentation:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"Flurry") getFlurryAgentVersion] forNetwork:kNetworkNameFlurry];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameFlurry]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameFlurry];
                if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameFlurry]) {
                    id<ATFlurryConsent> consent = [[NSClassFromString(@"FlurryConsent") alloc] initWithGDPRScope:[[ATAPI sharedInstance].networkConsentInfo[kNetworkNameFlurry][kFlurryConsentGDPRScopeFlagKey] boolValue] andConsentStrings:[ATAPI sharedInstance].networkConsentInfo[kNetworkNameFlurry][kFlurryConsentConsentStringKey]];
                    [NSClassFromString(@"FlurryConsent") updateConsentInformation:consent];
                } else {
                    BOOL set = NO;
                    [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                    if (set && [[ATAPI sharedInstance].consentStrings count] > 0) {
                        id<ATFlurryConsent> consent = [[NSClassFromString(@"FlurryConsent") alloc] initWithGDPRScope:[[ATAPI sharedInstance] inDataProtectionArea] andConsentStrings:[ATAPI sharedInstance].consentStrings];
                        [NSClassFromString(@"FlurryConsent") updateConsentInformation:consent];
                    }
                }
                [NSClassFromString(@"Flurry") startSession:info[@"sdk_key"] withSessionBuilder:[[[NSClassFromString(@"FlurrySessionBuilder") new] withCrashReporting:YES] withLogLevel:ATFlurryLogLevelAll]];
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"FlurryAdBanner")) {
        _customEvent = [[ATFlurryBannerCustomEvent alloc] initWithUnitID:info[kSpaceKey] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)info[kAdapterCustomInfoUnitGroupModelKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_banner = [[NSClassFromString(@"FlurryAdBanner") alloc] initWithSpace:info[kSpaceKey]];
            self->_banner.adDelegate = self->_customEvent;
            [self->_banner fetchAdForFrame:CGRectMake(.0f, .0f, unitGroupModel.adSize.width, unitGroupModel.adSize.height)];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load banner ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Flurry"]}]);
    }
}
@end
