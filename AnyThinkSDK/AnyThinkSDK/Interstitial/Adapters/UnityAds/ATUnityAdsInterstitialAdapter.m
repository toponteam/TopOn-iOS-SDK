//
//  ATUnityAdsInterstitialAdapter.m
//  AnyThinkUnityAdsInterstitialAdapter
//
//  Created by Martin Lau on 2018/12/25.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATUnityAdsInterstitialAdapter.h"
#import "ATUnityAdsInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
#import <objc/runtime.h>
#import "ATAppSettingManager.h"

NSString *const kUnityMonetizationInitFlagKey = @"unity_monetization_init_flag";
@interface ATUnityAdsInterstitialAdapter()
@property(nonatomic, readonly) ATUnityAdsInterstitialCustomEvent *customEvent;
@end
@implementation ATUnityAdsInterstitialAdapter
+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup {
    ATUnityAdsInterstitialCustomEvent *customEvent = [[ATUnityAdsInterstitialCustomEvent alloc] initWithUnitID:unitGroup.content[@"placement_id"] customInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil]];
    id<UMONShowAdPlacementContent> placementContent = [[NSClassFromString(@"UMONShowAdPlacementContent") alloc] initWithPlacementId:unitGroup.content[@"placement_id"] withParams:nil];
    ATInterstitial *ad = [[ATInterstitial alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:@{kInterstitialAssetsCustomEventKey:customEvent, kInterstitialAssetsUnitIDKey:[customEvent.unitID length] > 0 ? customEvent.unitID : @"", kAdAssetsCustomObjectKey:placementContent} unitGroup:unitGroup];
    return ad;
}

+(BOOL) adReadyForInfo:(NSDictionary*)info {
    return [NSClassFromString(@"UnityMonetization") isReady:info[@"placement_id"]];
}

+(BOOL) adReadyWithCustomObject:(id<UMONShowAdPlacementContent>)customObject info:(NSDictionary*)info {
    return [NSClassFromString(@"UnityMonetization") isReady:info[@"placement_id"]];
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    dispatch_async(dispatch_get_main_queue(), ^{
        [interstitial.customObject show:viewController withDelegate:(ATUnityAdsInterstitialCustomEvent*)interstitial.customEvent];
    });
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameUnityAds]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameUnityAds];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"UnityAds") getVersion] forNetwork:kNetworkNameUnityAds];
            id playerMetaData = [[NSClassFromString(@"UADSMetaData") alloc] init];
            if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameUnityAds]) {
                [playerMetaData set:@"gdpr.consent" value:[ATAPI sharedInstance].networkConsentInfo[kNetworkNameUnityAds]];
            } else {
                BOOL set = NO;
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                if (set) {
                    /*
                     value: 1 Personalize, 0 Nonpersonalized
                     */
                    [playerMetaData set:@"gdpr.consent" value:@(!limit)];
                }
            }
            [playerMetaData commit];
        }
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"UnityMonetization") != nil) {
        _customEvent = [[ATUnityAdsInterstitialCustomEvent alloc] initWithUnitID:info[@"placement_id"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        if ([NSClassFromString(@"UnityMonetization") isReady:info[@"placement_id"]]) {
            id<UMONShowAdPlacementContent> placementContent = [[NSClassFromString(@"UMONShowAdPlacementContent") alloc] initWithPlacementId:info[@"placement_id"] withParams:nil];
            [_customEvent handleAssets:@{kInterstitialAssetsCustomEventKey:_customEvent, kInterstitialAssetsUnitIDKey:[_customEvent.unitID length] > 0 ? _customEvent.unitID : @"", kAdAssetsCustomObjectKey:placementContent}];
        } else {
            [NSClassFromString(@"UnityMonetization") initialize:info[@"game_id"] delegate:_customEvent];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"UnityAds"]}]);
    }
}
@end
