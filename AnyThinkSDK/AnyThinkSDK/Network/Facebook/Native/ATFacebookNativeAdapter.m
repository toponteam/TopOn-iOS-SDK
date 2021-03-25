//
//  ATFacebookAdapter.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 25/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATFacebookNativeAdapter.h"
#import "ATFacebookCustomEvent.h"
#import "ATFacebookNativeADRenderer.h"
#import "ATAPI+Internal.h"
#import "NSObject+ExtraInfo.h"
#import "ATAdAdapter.h"
#import "ATFaceBookBaseManager.h"
#import "ATBidInfoManager.h"
#import "ATFBBiddingManager.h"

const CGFloat kATFBAdOptionsViewWidth = 43.0f;
const CGFloat kATFBAdOptionsViewHeight = 18.0f;
@interface ATFacebookNativeAdapter()
@property(nonatomic, readonly) id<ATFBNativeBannerAd> nativeBannerAd;
@property(nonatomic, readonly) id<ATFBNativeAd> nativeAd;
@property(nonatomic, readonly) ATFacebookCustomEvent *customEvent;
@end
@implementation ATFacebookNativeAdapter
+(Class) rendererClass {
    return [ATFacebookNativeADRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATFaceBookBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary*> *assets, NSError *error))completion {
    if (NSClassFromString(@"FBNativeAd") != nil && NSClassFromString(@"FBNativeBannerAd") != nil) {
        _customEvent = [ATFacebookCustomEvent new];
        _customEvent.unitID = serverInfo[@"unit_id"];
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
        _customEvent.requestNumber = 1;
        _customEvent.requestExtra = localInfo;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([serverInfo[@"unit_type"] integerValue] == 0) {
                if (bidInfo) {
                    NSString *fbPlacementID = serverInfo[@"unit_id"];
                    self->_nativeAd = [[NSClassFromString(@"FBNativeAd") alloc] initWithPlacementID:fbPlacementID];
                    [self->_nativeAd loadAdWithBidPayload:bidInfo.bidId];
                    [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
                }else {
                    self->_nativeAd = [[NSClassFromString(@"FBNativeAd") alloc] initWithPlacementID:serverInfo[@"unit_id"]];
                    [self->_nativeAd loadAd];
                }
                self->_nativeAd.delegate = self->_customEvent;

            } else {
                if (bidInfo) {
                    NSString *fbPlacementID = serverInfo[@"unit_id"];
                    self->_nativeBannerAd = [[NSClassFromString(@"FBNativeBannerAd") alloc] initWithPlacementID:fbPlacementID];
                    [self->_nativeBannerAd loadAdWithBidPayload:bidInfo.bidId];
                    [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
                }else {
                    self->_nativeBannerAd = [[NSClassFromString(@"FBNativeBannerAd") alloc] initWithPlacementID:serverInfo[@"unit_id"]];

                    [self->_nativeBannerAd loadAd];
                }
                self->_nativeBannerAd.delegate = self->_customEvent;
            }
        });

    }else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadNativeADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Facebook"]}]);
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
    request.format = ATFBBKFacebookAdBidFormatNative;
    request.timeOut = placementModel.FBHBTimeOut;
    [[ATFBBiddingManager sharedManager] bidRequest:request];
}
@end
