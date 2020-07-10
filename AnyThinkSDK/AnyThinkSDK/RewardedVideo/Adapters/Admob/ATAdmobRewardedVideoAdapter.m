//
//  ATAdmobRewardedVideoAdapter.m
//  AnyThinkAdmobRewardedVideoAdapter
//
//  Created by Martin Lau on 07/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdmobRewardedVideoAdapter.h"
#import "ATAdmobRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import <objc/runtime.h>
#import "Utilities.h"
#import "ATAdManager+RewardedVideo.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATAdCustomEvent.h"
#import "ATAppSettingManager.h"
NSString *const kAdmobRVAssetsCustomEventKey = @"admob_rewarded_video_custom_object";
@interface ATAdmobRewardedVideoAdapter()
@property(nonatomic, readonly) ATAdmobRewardedVideoCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATGADRewardedAd> rewardedAd;
@end

static NSString *const kUnitIDKey = @"unit_id";
@implementation ATAdmobRewardedVideoAdapter
+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup {
    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[kUnitIDKey]} unitGroup:unitGroup];
}

+(BOOL) adReadyWithCustomObject:(id<ATGADRewardedAd>)customObject info:(NSDictionary*)info {
    return customObject.isReady;
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATAdmobRewardedVideoCustomEvent *customEvent = (ATAdmobRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.delegate = delegate;
    [((id<ATGADRewardedAd>)rewardedVideo.customObject) presentFromRootViewController:viewController delegate:customEvent];
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
                        if (set) {
                            consentInfo.consentStatus = limit ? ATPACConsentStatusNonPersonalized : ATPACConsentStatusPersonalized;
                        }
                    }
                }
            });//End of configure consent status
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"GADRequest") != nil && NSClassFromString(@"GADRewardedAd") != nil) {
        _customEvent = [[ATAdmobRewardedVideoCustomEvent alloc] initWithUnitID:info[kUnitIDKey] customInfo:info];
        _customEvent.requestNumber = [info[@"request_num"] integerValue];
        _customEvent.requestCompletionBlock = completion;
        _rewardedAd = [[NSClassFromString(@"GADRewardedAd") alloc] initWithAdUnitID:info[@"unit_id"]];
        __weak typeof(self) weakSelf = self;
        [_rewardedAd loadRequest:(id<ATGADRequest>)[NSClassFromString(@"GADRequest") request] completionHandler:^(NSError * _Nullable error) {
            if (error == nil) {
                [weakSelf.customEvent handleAssets:@{kRewardedVideoAssetsUnitIDKey:info[@"unit_id"], kRewardedVideoAssetsCustomEventKey:weakSelf.customEvent, kAdAssetsCustomObjectKey:weakSelf.rewardedAd}];
            } else {
                [ATLogger logMessage:[NSString stringWithFormat:@"AdmobRewardedVideo::requestFailedWithError:%@(code:%@)", error, [ATAdmobRewardedVideoCustomEvent errorMessageWithError:error]] type:ATLogTypeExternal];
                [weakSelf.customEvent handleLoadingFailure:error];
            }
        }];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Admob"]}]);
    }
}
@end
