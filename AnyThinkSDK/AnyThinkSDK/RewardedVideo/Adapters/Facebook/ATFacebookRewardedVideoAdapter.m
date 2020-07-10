//
//  ATFacebookRewardedVideoAdapter.m
//  AnyThinkFacebookRewardedVideoAdapter
//
//  Created by Martin Lau on 10/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATFacebookRewardedVideoAdapter.h"
#import "ATFacebookRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import <objc/runtime.h>
#import "ATAdManager+RewardedVideo.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATAdLoader+HeaderBidding.h"

NSString *const kFacebookRVCustomEventKey = @"custom_event";
@interface ATFacebookRewardedVideoAdapter()
@property(nonatomic, readonly) id<ATFBRewardedVideoAd> rewardedVideoAd;
@property(nonatomic, readonly) ATFacebookRewardedVideoCustomEvent *customEvent;
@end

static NSString *const kPlacementID = @"unit_id";
static NSString *const kRewardedVideoClassName = @"FBRewardedVideoAd";
@implementation ATFacebookRewardedVideoAdapter
+(id<ATAd>) placeholderAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID unitGroup:(ATUnitGroupModel*)unitGroup {
    return [[ATRewardedVideo alloc] initWithPriority:0 placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:unitGroup.content[kPlacementID]} unitGroup:unitGroup];
}

+(BOOL) adReadyWithCustomObject:(id<ATFBRewardedVideoAd>)customObject info:(NSDictionary*)info {
    return customObject.isAdValid;
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATFacebookRewardedVideoCustomEvent *customEvent = (ATFacebookRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.rewardedVideo = rewardedVideo;
    customEvent.delegate = delegate;
    [((id<ATFBRewardedVideoAd>)rewardedVideo.customObject) showAdFromRootViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameFacebook]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameFacebook];
                [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameFacebook];
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kRewardedVideoClassName)) {
        _customEvent = [[ATFacebookRewardedVideoCustomEvent alloc] initWithUnitID:info[kPlacementID] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        _rewardedVideoAd = [[NSClassFromString(kRewardedVideoClassName) alloc] initWithPlacementID:info[kPlacementID] withUserID:[[ATAdManager sharedManager] extraInfoForPlacementID:((ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey]).placementID requestID:info[kAdapterCustomInfoRequestIDKey]][kATAdLoadingExtraUserIDKey] withCurrency:@"gold"];
        _rewardedVideoAd.delegate = _customEvent;
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)info[kAdapterCustomInfoUnitGroupModelKey];
        NSString *requestID = info[kAdapterCustomInfoRequestIDKey];
        if ([unitGroupModel bidTokenWithRequestID:requestID] != nil) {
            [_rewardedVideoAd loadAdWithBidPayload:[unitGroupModel bidTokenWithRequestID:requestID]];
            [unitGroupModel setBidTokenUsedFlagForRequestID:requestID];
        } else {
            [_rewardedVideoAd loadAd];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Facebook"]}]);
    }
}
@end
