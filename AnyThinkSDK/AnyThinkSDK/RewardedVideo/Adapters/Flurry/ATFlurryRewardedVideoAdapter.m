//
//  ATFlurryRewardedVideoAdapter.m
//  AnyThinkFlurryRewardedVideoAdapter
//
//  Created by Martin Lau on 09/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATFlurryRewardedVideoAdapter.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import "ATFlurryRewardedVideoCustomEvent.h"
#import <objc/runtime.h>
#import "ATAdManager+RewardedVideo.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"

NSString *const kFlurryRVAssetsCustomEventKey = @"flurry_custom_event";
@interface ATFlurryRewardedVideoAdapter()
@property(nonatomic, readonly) ATFlurryRewardedVideoCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATFlurryAdInterstitial> interstitial;
@end
static NSString *const kSpaceKey = @"ad_space";
@implementation ATFlurryRewardedVideoAdapter
+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup {
    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[kSpaceKey]} unitGroup:unitGroup];
}

+(BOOL) adReadyWithCustomObject:(id<ATFlurryAdInterstitial>)customObject info:(NSDictionary*)info {
    return customObject.ready;
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ((ATFlurryRewardedVideoCustomEvent*)objc_getAssociatedObject(rewardedVideo.customObject, (__bridge_retained void*)kFlurryRVAssetsCustomEventKey)).delegate = delegate;
    ((ATFlurryRewardedVideoCustomEvent*)objc_getAssociatedObject(rewardedVideo.customObject, (__bridge_retained void*)kFlurryRVAssetsCustomEventKey)).rewardedVideo = rewardedVideo;
    dispatch_async(dispatch_get_main_queue(), ^{
        [((id<ATFlurryAdInterstitial>)(rewardedVideo.customObject)) presentWithViewController:viewController];
    });
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
                [NSClassFromString(@"Flurry") setUserID:[[ATAdManager sharedManager] extraInfoForPlacementID:((ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey]).placementID requestID:info[kAdapterCustomInfoRequestIDKey]][kATAdLoadingExtraUserIDKey]];
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"FlurryAdInterstitial")) {
        _customEvent = [[ATFlurryRewardedVideoCustomEvent alloc] initWithUnitID:info[kSpaceKey] customInfo:info];
        _customEvent.requestNumber = [info[@"request_num"] longValue];
        _customEvent.requestCompletionBlock = completion;
        _interstitial = [[NSClassFromString(@"FlurryAdInterstitial") alloc] initWithSpace:info[kSpaceKey]];
        _interstitial.adDelegate = _customEvent;
        for (NSInteger i = 0; i < [info[@"request_num"] integerValue]; i++) [_interstitial fetchAd];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Flurry"]}]);
    }
}
@end
