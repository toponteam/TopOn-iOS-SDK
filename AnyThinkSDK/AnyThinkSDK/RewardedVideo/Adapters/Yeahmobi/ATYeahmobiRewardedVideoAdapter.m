//
//  ATYeahmobiRewardedVideoAdapter.m
//  AnyThinkYeahmobiRewardedVideoAdapter
//
//  Created by Martin Lau on 2018/10/17.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATYeahmobiRewardedVideoAdapter.h"
#import "ATYeahmobiRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import <objc/runtime.h>
#import "ATAdManager+RewardedVideo.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
@interface ATYeahmobiRewardedVideoAdapter()
@property(nonatomic, readonly) ATYeahmobiRewardedVideoCustomEvent *customEvent;
@end
@implementation ATYeahmobiRewardedVideoAdapter
+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup {
    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[@"slot_id"]} unitGroup:unitGroup];
}

+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup {
    ATYeahmobiRewardedVideoCustomEvent *customEvent = [[ATYeahmobiRewardedVideoCustomEvent alloc] initWithUnitID:unitGroup.content[@"slot_id"] customInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil]];
    ATRewardedVideo *ad = [[ATRewardedVideo alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:[customEvent.unitID length] > 0 ? customEvent.unitID : @"", kRewardedVideoAssetsCustomEventKey:customEvent, kAdAssetsCustomObjectKey:[customEvent.unitID length] > 0 ? customEvent.unitID : @""} unitGroup:unitGroup];
    return ad;
}

+(BOOL) adReadyForInfo:(NSDictionary*)info {
    return [[NSClassFromString(@"CTService") shareManager] checkRewardVideoIsReady];
}

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return [[NSClassFromString(@"CTService") shareManager] checkRewardVideoIsReady];
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATYeahmobiRewardedVideoCustomEvent *customEvent = (ATYeahmobiRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.rewardedVideo = rewardedVideo;
    customEvent.delegate = delegate;
    [[NSClassFromString(@"CTService") shareManager] showRewardVideoWithPresentingViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameYeahmobi]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameYeahmobi];
                [[ATAPI sharedInstance] setVersion:[[NSClassFromString(@"CTService") shareManager] getSDKVersion] forNetwork:kNetworkNameYeahmobi];
                [[NSClassFromString(@"CTService") shareManager] loadRequestGetCTSDKConfigBySlot_id:info[@"slot_id"]];
                
                if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameYeahmobi]) {
                    if ([[ATAPI sharedInstance].networkConsentInfo isKindOfClass:[NSDictionary class]] && [[ATAPI sharedInstance].networkConsentInfo[kYeahmobiGDPRConsentTypeKey] isKindOfClass:[NSString class]] && [[ATAPI sharedInstance].networkConsentInfo[kYeahmobiGDPRConsentValueKey] isKindOfClass:[NSString class]]) {
                        [[NSClassFromString(@"CTService") shareManager] uploadConsentValue:[ATAPI sharedInstance].networkConsentInfo[kYeahmobiGDPRConsentValueKey] consentType:[ATAPI sharedInstance].networkConsentInfo[kYeahmobiGDPRConsentTypeKey] complete:^(BOOL status){}];
                    }
                } else {
                    BOOL set = NO;
                    BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                    if (set) { [[NSClassFromString(@"CTService") shareManager] uploadConsentValue:limit ? @"no" : @"yes" consentType:@"GDPR" complete:^(BOOL status){}]; }
                }
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"CTService")) {
        _customEvent = [[ATYeahmobiRewardedVideoCustomEvent alloc] initWithUnitID:info[@"slot_id"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        if ([[[ATAdManager sharedManager] extraInfoForPlacementID:((ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey]).placementID requestID:info[kAdapterCustomInfoRequestIDKey]] containsObjectForKey:kATAdLoadingExtraUserIDKey]) {
            [[NSClassFromString(@"CTService") shareManager] setCustomParameters:[[ATAdManager sharedManager] extraInfoForPlacementID:((ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey]).placementID requestID:info[kAdapterCustomInfoRequestIDKey]][kATAdLoadingExtraUserIDKey]];
        }
        [[NSClassFromString(@"CTService") shareManager] loadRewardVideoWithSlotId:info[@"slot_id"] delegate:_customEvent];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Yeahmobi"]}]);
    }
}
@end
