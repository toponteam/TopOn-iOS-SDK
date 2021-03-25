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
#import "ATMopubBaseManager.h"

@interface ATMopubRewardedVideoAdapter()
@property(nonatomic) ATMopubRewardedVideoCustomEvent *customEvent;
@end

static NSString *const kUnitIDKey = @"unitid";
@implementation ATMopubRewardedVideoAdapter

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return [NSClassFromString(@"MPRewardedVideo") hasAdAvailableForAdUnitID:info[kUnitIDKey]];
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATMopubRewardedVideoCustomEvent *customEvent = [[ATMopubRewardedVideoCustomEvent alloc] initWithInfo:nil localInfo:nil];
    customEvent.delegate = delegate;
    customEvent.rewardedVideo = rewardedVideo;
    [NSClassFromString(@"MPRewardedVideo") setDelegate:customEvent forAdUnitId:rewardedVideo.unitGroup.content[kUnitIDKey]];
    [[ATRewardedVideoManager sharedManager] setCustomEvent:customEvent forKey:rewardedVideo.placementModel.placementID];
    [NSClassFromString(@"MPRewardedVideo") presentRewardedVideoAdForAdUnitID:rewardedVideo.unitGroup.content[kUnitIDKey] fromViewController:viewController withReward:[NSClassFromString(@"MPRewardedVideo") selectedRewardForAdUnitID:rewardedVideo.unitGroup.content[kUnitIDKey]]];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATMopubBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"MPRewardedVideo")) {
        id<ATMoPub> mopub = [NSClassFromString(@"MoPub") sharedInstance];

        __weak typeof(self) weakSelf = self;
        void(^Load)(void) = ^{
            weakSelf.customEvent = [[ATMopubRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
            weakSelf.customEvent.requestNumber = [serverInfo[@"request_num"] integerValue];
            weakSelf.customEvent.requestCompletionBlock = completion;
            dispatch_async(dispatch_get_main_queue(), ^{
                for (NSInteger i = 0; i < [serverInfo[@"request_num"] integerValue]; i++) {
                    [NSClassFromString(@"MPRewardedVideo") setDelegate:weakSelf.customEvent forAdUnitId:serverInfo[kUnitIDKey]];
                    [NSClassFromString(@"MPRewardedVideo") loadRewardedVideoAdWithAdUnitID:serverInfo[kUnitIDKey] keywords:serverInfo[kATAdLoadingExtraKeywordKey] userDataKeywords:serverInfo[kATAdLoadingExtraUserDataKeywordKey] location:serverInfo[kATAdLoadingExtraLocationKey] customerId:[[ATAdManager sharedManager] extraInfoForPlacementID:((ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey]).placementID requestID:serverInfo[kAdapterCustomInfoRequestIDKey]][kATAdLoadingExtraUserIDKey] mediationSettings:nil];
                }
            });
            
        };
        if(![ATAPI getMPisInit]){
            [mopub initializeSdkWithConfiguration:[[NSClassFromString(@"MPMoPubConfiguration") alloc] initWithAdUnitIdForAppInitialization:serverInfo[kUnitIDKey]] completion:^{
                [ATAPI setMPisInit:YES];
                Load();
            }];
        }else{
            Load();
        }
        
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Mopub"]}]);
    }
}
@end
