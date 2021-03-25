//
//  ATFacebookInterstitialAdapter.m
//  AnyThinkFacebookInterstitialAdapter
//
//  Created by Martin Lau on 29/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATFacebookInterstitialAdapter.h"
#import "ATFacebookInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "ATAdAdapter.h"
#import "ATFaceBookBaseManager.h"
#import "ATBidInfo.h"
#import "ATUnitGroupModel.h"
#import "ATBidInfoManager.h"
#import "ATFBBiddingManager.h"

@interface ATFacebookInterstitialAdapter()
@property(nonatomic, readonly) id<ATFBInterstitialAd> interstitialAd;
@property(nonatomic, readonly) ATFacebookInterstitialCustomEvent *customEvent;
@end
@implementation ATFacebookInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return ((id<ATFBInterstitialAd>)customObject).adValid;
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    [((id<ATFBInterstitialAd>)interstitial.customObject) showAdFromRootViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATFaceBookBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"FBInterstitialAd") != nil) {
        _customEvent = [[ATFacebookInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        
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
                self->_interstitialAd = [[NSClassFromString(@"FBInterstitialAd") alloc] initWithPlacementID:fbPlacementID];
                [self->_interstitialAd loadAdWithBidPayload:bidInfo.bidId];
                [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];

            }else {
                self->_interstitialAd = [[NSClassFromString(@"FBInterstitialAd") alloc] initWithPlacementID:serverInfo[@"unit_id"]];
                [self->_interstitialAd loadAd];

            }
            self->_interstitialAd.delegate = self->_customEvent;
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Facebook"]}]);
    }
}

// c2s
+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    
    NSString *appID = info[@"app_id"];
    NSString *placemengID = placementModel.placementID;
    ATFacebookBaseRequest *request = [ATFacebookBaseRequest new];
    request.appID = appID;
    request.unitGroup = unitGroupModel;
    request.facebookPlacementID = info[@"unit_id"];
    request.placementID = placemengID;
    request.completion = completion;
    request.unitGroups = placementModel.waterfallA;
    request.format = ATFBBKFacebookAdBidFormatInterstitial;
    request.timeOut = placementModel.FBHBTimeOut;
    [[ATFBBiddingManager sharedManager] bidRequest:request];
}
@end
