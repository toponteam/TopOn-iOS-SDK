//
//  ATNendRewardedVideoAdapter.m
//  AnyThinkNendRewardedVideoAdapter
//
//  Created by Martin Lau on 2019/4/19.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATNendRewardedVideoAdapter.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import <objc/runtime.h>
#import "ATAdManager+RewardedVideo.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATNendRewardedVideoCustomEvent.h"
#import "ATNendBaseManager.h"

@interface ATNendRewardedVideoAdapter()
@property(nonatomic, readonly) id<ATNADRewardedVideo> rewardedVideo;
@property(nonatomic, readonly) ATNendRewardedVideoCustomEvent *customEvent;
@end
static NSString *const kRewardedVideoClassName = @"NADRewardedVideo";
@implementation ATNendRewardedVideoAdapter

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return ((id<ATNADRewardedVideo>)customObject).isReady;
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ((ATNendRewardedVideoCustomEvent*)rewardedVideo.customEvent).delegate = delegate;
    [((id<ATNADRewardedVideo>)rewardedVideo.customObject) showAdFromViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATNendBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kRewardedVideoClassName) != nil) {
        _customEvent = [[ATNendRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        _rewardedVideo = [[NSClassFromString(kRewardedVideoClassName) alloc] initWithSpotId:serverInfo[@"spot_id"] apiKey:serverInfo[@"api_key"]];
        _rewardedVideo.delegate = _customEvent;
        [_rewardedVideo loadAd];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Nend"]}]);
    }
}
@end
