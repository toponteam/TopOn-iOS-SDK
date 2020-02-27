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
@interface ATNendRewardedVideoAdapter()
@property(nonatomic, readonly) id<ATNADRewardedVideo> rewardedVideo;
@property(nonatomic, readonly) ATNendRewardedVideoCustomEvent *customEvent;
@end
static NSString *const kRewardedVideoClassName = @"NADRewardedVideo";
@implementation ATNendRewardedVideoAdapter
+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup {
    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[@"spot_id"]} unitGroup:unitGroup];
}

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return ((id<ATNADRewardedVideo>)customObject).isReady;
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ((ATNendRewardedVideoCustomEvent*)rewardedVideo.customEvent).delegate = delegate;
    [((id<ATNADRewardedVideo>)rewardedVideo.customObject) showAdFromViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameNend]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameNend];
                [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameNend];
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kRewardedVideoClassName) != nil) {
        _customEvent = [[ATNendRewardedVideoCustomEvent alloc] initWithUnitID:info[@"spot_id"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        _rewardedVideo = [[NSClassFromString(kRewardedVideoClassName) alloc] initWithSpotId:info[@"spot_id"] apiKey:info[@"api_key"]];
        _rewardedVideo.delegate = _customEvent;
        [_rewardedVideo loadAd];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Nend"]}]);
    }
}
@end
