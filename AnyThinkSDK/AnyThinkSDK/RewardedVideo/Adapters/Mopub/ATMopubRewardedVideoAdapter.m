//
//  ATMopubRewardedVideoAdapter.m
//  AnyThinkMopubRewardedVideoAdapter
//
//  Created by Martin Lau on 10/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMopubRewardedVideoAdapter.h"
#import "AnyThinkRewardedVideo.h"
#import "ATMopubRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import "ATAdManager+RewardedVideo.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
@interface ATMopubRewardedVideoAdapter()
@property(nonatomic) ATMopubRewardedVideoCustomEvent *customEvent;
@end

static NSString *const kUnitIDKey = @"unitid";
@implementation ATMopubRewardedVideoAdapter
+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup {
    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[kUnitIDKey]} unitGroup:unitGroup];
}

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return [NSClassFromString(@"MPRewardedVideo") hasAdAvailableForAdUnitID:info[kUnitIDKey]];
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATMopubRewardedVideoCustomEvent *customEvent = [[ATMopubRewardedVideoCustomEvent alloc] initWithUnitID:rewardedVideo.unitGroup.content[kUnitIDKey] customInfo:nil];
    customEvent.delegate = delegate;
    customEvent.rewardedVideo = rewardedVideo;
    [NSClassFromString(@"MPRewardedVideo") setDelegate:customEvent forAdUnitId:rewardedVideo.unitGroup.content[kUnitIDKey]];
    [[ATRewardedVideoManager sharedManager] setCustomEvent:customEvent forKey:rewardedVideo.placementModel.placementID];
    [NSClassFromString(@"MPRewardedVideo") presentRewardedVideoAdForAdUnitID:rewardedVideo.unitGroup.content[kUnitIDKey] fromViewController:viewController withReward:[NSClassFromString(@"MPRewardedVideo") selectedRewardForAdUnitID:rewardedVideo.unitGroup.content[kUnitIDKey]]];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            id<ATMoPub> mopub = [NSClassFromString(@"MoPub") sharedInstance];
            [[ATAPI sharedInstance] setVersion:[mopub version] forNetwork:kNetworkNameMopub];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMopub]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMopub];
                if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameMopub]) {
                    if ([[ATAPI sharedInstance].networkConsentInfo[kNetworkNameMopub] boolValue]) {
                        [mopub grantConsent];
                    } else {
                        [mopub revokeConsent];
                    }
                } else {
                    BOOL set = NO;
                    BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                    if (set) {
                        if (limit) {
                            [mopub grantConsent];
                        } else {
                            [mopub revokeConsent];
                        }
                    }
                }
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"MPRewardedVideo")) {
        id<ATMoPub> mopub = [NSClassFromString(@"MoPub") sharedInstance];

        __weak typeof(self) weakSelf = self;
        void(^Load)(void) = ^{
            weakSelf.customEvent = [[ATMopubRewardedVideoCustomEvent alloc] initWithUnitID:info[kUnitIDKey] customInfo:info];
            weakSelf.customEvent.requestNumber = [info[@"request_num"] integerValue];
            weakSelf.customEvent.requestCompletionBlock = completion;
            for (NSInteger i = 0; i < [info[@"request_num"] integerValue]; i++) {
                [NSClassFromString(@"MPRewardedVideo") setDelegate:weakSelf.customEvent forAdUnitId:info[kUnitIDKey]];
                [NSClassFromString(@"MPRewardedVideo") loadRewardedVideoAdWithAdUnitID:info[kUnitIDKey] keywords:info[kATAdLoadingExtraKeywordKey] userDataKeywords:info[kATAdLoadingExtraUserDataKeywordKey] location:info[kATAdLoadingExtraLocationKey] customerId:[[ATAdManager sharedManager] extraInfoForPlacementID:((ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey]).placementID requestID:info[kAdapterCustomInfoRequestIDKey]][kATAdLoadingExtraUserIDKey] mediationSettings:nil];
            }
        };
        if(![ATAPI getMPisInit]){
            [mopub initializeSdkWithConfiguration:[[NSClassFromString(@"MPMoPubConfiguration") alloc] initWithAdUnitIdForAppInitialization:info[kUnitIDKey]] completion:^{
                [ATAPI setMPisInit:YES];
                Load();
            }];
        }else{
            Load();
        }
        
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Mopub"]}]);
    }
}
@end
