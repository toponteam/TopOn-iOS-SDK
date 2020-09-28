//
//  ATGoogleAdManagerRewardedVideoAdapter.m
//  AnyThinkAdmobRewardedVideoAdapter
//
//  Created by stephen on 7/27/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATGoogleAdManagerRewardedVideoAdapter.h"
#import "ATGoogleAdManagerRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import <objc/runtime.h>
#import "Utilities.h"
#import "ATAdManager+RewardedVideo.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATAdCustomEvent.h"
#import "ATAppSettingManager.h"
NSString *const kGoogleAdManagerRVAssetsCustomEventKey = @"google_ad_manager_rewarded_video_custom_object";
@interface ATGoogleAdManagerRewardedVideoAdapter()
@property(nonatomic, readonly) ATGoogleAdManagerRewardedVideoCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATDFPRewardedAd> rewardedAd;
@end

static NSString *const kUnitIDKey = @"unit_id";
@implementation ATGoogleAdManagerRewardedVideoAdapter
//+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall *)finalWaterfall {
//    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[kUnitIDKey]} unitGroup:unitGroup finalWaterfall:finalWaterfall];
//}

+(BOOL) adReadyWithCustomObject:(id<ATDFPRewardedAd>)customObject info:(NSDictionary*)info {
    return customObject.isReady;
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATGoogleAdManagerRewardedVideoCustomEvent *customEvent = (ATGoogleAdManagerRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.delegate = delegate;
    [((id<ATDFPRewardedAd>)rewardedVideo.customObject) presentFromRootViewController:viewController delegate:customEvent];
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
//                        if (set) {
//                            consentInfo.consentStatus = limit ? ATPACConsentStatusNonPersonalized : ATPACConsentStatusPersonalized;
//                        }
//                    }
                }
            });//End of configure consent status
        });
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"DFPRequest") != nil && NSClassFromString(@"GADRewardedAd") != nil) {
        _customEvent = [[ATGoogleAdManagerRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestNumber = [serverInfo[@"request_num"] integerValue];
        _customEvent.requestCompletionBlock = completion;
        _rewardedAd = [[NSClassFromString(@"GADRewardedAd") alloc] initWithAdUnitID:serverInfo[@"unit_id"]];
        __weak typeof(self) weakSelf = self;
        [_rewardedAd loadRequest:(id<ATDFPRequest>)[NSClassFromString(@"DFPRequest") request] completionHandler:^(NSError * _Nullable error) {
            if (error == nil) {
                [weakSelf.customEvent trackRewardedVideoAdLoaded:weakSelf.rewardedAd adExtra:nil];
            } else {
                [weakSelf.customEvent trackRewardedVideoAdLoadFailed:error];
            }
        }];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"GoogleAdManager"]}]);
    }
}
@end
