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
#import "ATFBBiddingManager.h"
#import "ATBidInfoManager.h"
#import "ATFaceBookBaseManager.h"

NSString *const kFacebookRVCustomEventKey = @"custom_event";
@interface ATFacebookRewardedVideoAdapter()
@property(nonatomic, readonly) id<ATFBRewardedVideoAd> rewardedVideoAd;
@property(nonatomic, readonly) ATFacebookRewardedVideoCustomEvent *customEvent;
@end

static NSString *const kPlacementID = @"unit_id";
static NSString *const kRewardedVideoClassName = @"FBRewardedVideoAd";
@implementation ATFacebookRewardedVideoAdapter

+(BOOL) adReadyWithCustomObject:(id<ATFBRewardedVideoAd>)customObject info:(NSDictionary*)info {
    return customObject.isAdValid;
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATFacebookRewardedVideoCustomEvent *customEvent = (ATFacebookRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.rewardedVideo = rewardedVideo;
    customEvent.delegate = delegate;
    [((id<ATFBRewardedVideoAd>)rewardedVideo.customObject) showAdFromRootViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATFaceBookBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kRewardedVideoClassName)) {
        _customEvent = [[ATFacebookRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
        ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
        NSString *requestID = serverInfo[kAdapterCustomInfoRequestIDKey];
        
        ATBidInfo *bidInfo = [[ATBidInfoManager sharedManager] bidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
        _customEvent.price = bidInfo ? bidInfo.price : unitGroupModel.price;
        _customEvent.bidId = bidInfo ? bidInfo.bidId : @"";
        if (bidInfo.nURL) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:bidInfo.nURL]] resume];
            });
        }
        _customEvent.requestCompletionBlock = completion;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bidInfo) {
                NSString *fbPlacementID = serverInfo[@"unit_id"];
                self->_rewardedVideoAd = [[NSClassFromString(kRewardedVideoClassName) alloc] initWithPlacementID:fbPlacementID];
                [self->_rewardedVideoAd loadAdWithBidPayload:bidInfo.bidId];
                [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
            }else {
                self->_rewardedVideoAd = [[NSClassFromString(kRewardedVideoClassName) alloc] initWithPlacementID:serverInfo[kPlacementID] withUserID:[[ATAdManager sharedManager] extraInfoForPlacementID:((ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey]).placementID requestID:serverInfo[kAdapterCustomInfoRequestIDKey]][kATAdLoadingExtraUserIDKey] withCurrency:@"gold"];
                [self->_rewardedVideoAd loadAd];
            }
            self->_rewardedVideoAd.delegate = self->_customEvent;
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Facebook"]}]);
    }
}

// c2s
+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    
    NSString *appID = info[@"app_id"];
    NSString *placemengID = placementModel.placementID;
    ATFacebookBaseRequest *request = [ATFacebookBaseRequest new];
    request.appID = appID;
    request.facebookPlacementID = info[@"unit_id"];
    request.unitGroup = unitGroupModel;
    request.placementID = placemengID;
    request.completion = completion;
    request.timeOut = placementModel.FBHBTimeOut;
    request.unitGroups = placementModel.waterfallA;
    request.format = ATFBBKFacebookAdBidFormatRewardedVideo;
    [[ATFBBiddingManager sharedManager] bidRequest:request];
}

@end
