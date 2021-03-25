//
//  ATKSRewardedVideoAdapter.m
//  AnyThinkSDK
//
//  Created by Topon on 2019/9/10.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATKSRewardedVideoAdapter.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import <objc/runtime.h>
#import "ATAdManager+RewardedVideo.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATKSRewardedVideoCustomEvent.h"
#import "ATKSBaseManager.h"

static NSString *const kKSVideoClassName = @"KSRewardedVideoAd";

@interface ATKSRewardedVideoAdapter ()
@property(nonatomic, readonly) id<ATKSRewardedVideoAd> rewardedVideo;
@property(nonatomic, readonly) ATKSRewardedVideoCustomEvent *customEvent;
@end
@implementation ATKSRewardedVideoAdapter

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return ((id<ATKSRewardedVideoAd>)customObject).isValid;
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATKSRewardedVideoCustomEvent *customEvent = (ATKSRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.rewardedVideo = rewardedVideo;
    customEvent.delegate = delegate;
    [((id<ATKSRewardedVideoAd>)rewardedVideo.customObject)  showAdFromRootViewController:viewController direction:[@{@1:@(KSAdShowDirection_Vertical),@2:@(KSAdShowDirection_Horizontal)}[@([rewardedVideo.customEvent.serverInfo[@"orientation"] integerValue])] integerValue]];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if(self != nil){
        [ATKSBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if(NSClassFromString(kKSVideoClassName)!=nil){
        _customEvent = [[ATKSRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
        _rewardedVideo = [[NSClassFromString(kKSVideoClassName) alloc]initWithPosId:serverInfo[@"position_id"] rewardedVideoModel:[NSClassFromString(@"KSRewardedVideoModel") new]];
        _rewardedVideo.shouldMuted = [serverInfo[@"video_muted"] boolValue];
        _rewardedVideo.delegate = _customEvent;
        [_rewardedVideo loadAdData];
    }else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"KS"]}]);
    }
}
@end
