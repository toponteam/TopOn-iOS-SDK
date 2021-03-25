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
#import "ATAdmobBaseManager.h"

NSString *const kAdmobRVAssetsCustomEventKey = @"admob_rewarded_video_custom_object";
@interface ATAdmobRewardedVideoAdapter()
@property(nonatomic, readonly) ATAdmobRewardedVideoCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATGADRewardedAd> rewardedAd;
@end

static NSString *const kUnitIDKey = @"unit_id";
@implementation ATAdmobRewardedVideoAdapter

+(BOOL) adReadyWithCustomObject:(id<ATGADRewardedAd>)customObject info:(NSDictionary*)info {
    return customObject.isReady;
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATAdmobRewardedVideoCustomEvent *customEvent = (ATAdmobRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.delegate = delegate;
    [((id<ATGADRewardedAd>)rewardedVideo.customObject) presentFromRootViewController:viewController delegate:customEvent];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATAdmobBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"GADRequest") != nil && NSClassFromString(@"GADRewardedAd") != nil) {
        _customEvent = [[ATAdmobRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestNumber = [serverInfo[@"request_num"] integerValue];
        _customEvent.requestCompletionBlock = completion;
        _rewardedAd = [[NSClassFromString(@"GADRewardedAd") alloc] initWithAdUnitID:serverInfo[@"unit_id"]];
        
        id<ATGADServerSideVerificationOptions> options = [[NSClassFromString(@"GADServerSideVerificationOptions") alloc] init];
        if (localInfo[kATAdLoadingExtraUserIDKey] != nil) {
            options.userIdentifier = localInfo[kATAdLoadingExtraUserIDKey];
        }
        if (localInfo[kATAdLoadingExtraMediaExtraKey] != nil) {
            options.customRewardString = localInfo[kATAdLoadingExtraMediaExtraKey];
        }
        _rewardedAd.serverSideVerificationOptions = options;
        __weak typeof(self) weakSelf = self;
        [_rewardedAd loadRequest:(id<ATGADRequest>)[NSClassFromString(@"GADRequest") request] completionHandler:^(NSError * _Nullable error) {
            if (error == nil) {
                [weakSelf.customEvent trackRewardedVideoAdLoaded:weakSelf.rewardedAd adExtra:nil];
            } else {
                [weakSelf.customEvent trackRewardedVideoAdLoadFailed:error];
            }
        }];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Admob"]}]);
    }
}
@end
