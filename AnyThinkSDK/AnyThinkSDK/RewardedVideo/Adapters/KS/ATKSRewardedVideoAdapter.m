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
static NSString *const kKSVideoClassName = @"KSRewardedVideoAd";

@interface ATKSRewardedVideoAdapter ()
@property(nonatomic, readonly) id<ATKSRewardedVideoAd> rewardedVideo;
@property(nonatomic, readonly) ATKSRewardedVideoCustomEvent *customEvent;
@end
@implementation ATKSRewardedVideoAdapter

+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup {
    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[@"unit_id"]} unitGroup:unitGroup];
}

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return ((id<ATKSRewardedVideoAd>)customObject).isValid;
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATKSRewardedVideoCustomEvent *customEvent = (ATKSRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.rewardedVideo = rewardedVideo;
    customEvent.delegate = delegate;
    [((id<ATKSRewardedVideoAd>)rewardedVideo.customObject)  showAdFromRootViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if(self != nil){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameKS]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameKS];
                [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"KSAdSDKManager") SDKVersion] forNetwork:kNetworkNameKS];
                [NSClassFromString(@"KSAdSDKManager") setAppId:info[@"app_id"]];
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if(NSClassFromString(kKSVideoClassName)!=nil){
        _customEvent = [[ATKSRewardedVideoCustomEvent alloc] initWithUnitID:info[@"position_id"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
        _rewardedVideo = [[NSClassFromString(kKSVideoClassName) alloc]initWithPosId:info[@"position_id"] rewardedVideoModel:[NSClassFromString(@"KSRewardedVideoModel") new]];
        _rewardedVideo.delegate = _customEvent;
        [_rewardedVideo loadAdData];
    }else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"KS"]}]);
    }
}
@end
