//
//  ATFacebookBannerAdapter.m
//  AnyThinkFacebookBannerAdapter
//
//  Created by Martin Lau on 29/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATFacebookBannerAdapter.h"
#import "ATAPI+Internal.h"
#import "ATFacebookBannerCustomEvent.h"
#import "ATAdAdapter.h"
#import "ATFaceBookBaseManager.h"
#import "ATBidInfoManager.h"
#import "ATFBBiddingManager.h"

@interface ATFacebookBannerAdapter()
@property(nonatomic, readonly) ATFacebookBannerCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATFBAdView> adView;
@end
@implementation ATFacebookBannerAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATFaceBookBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"FBAdView") != nil) {
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
        _customEvent = [[ATFacebookBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
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
            NSString *fbPlacementID = serverInfo[@"unit_id"];
            self->_adView = [[NSClassFromString(@"FBAdView") alloc] initWithPlacementID:bidInfo ? fbPlacementID : serverInfo[@"unit_id"] adSize:(struct FBAdSize){{-1, unitGroupModel.adSize.height}} rootViewController:[ATBannerCustomEvent rootViewControllerWithPlacementID:((ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey]).placementID requestID:serverInfo[kAdapterCustomInfoRequestIDKey]]];
            self->_adView.frame = CGRectMake(0, 0, unitGroupModel.adSize.width, unitGroupModel.adSize.height);
            self->_adView.delegate = self->_customEvent;

            if (bidInfo) {
                [self->_adView loadAdWithBidPayload:bidInfo.bidId];
                [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
            }else {
                [self->_adView loadAd];
            }
        });

    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Facebook"]}]);
    }
}

// c2s
+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    
    NSString *appID = info[@"app_id"];
    NSString *placemengID = placementModel.placementID;
    ATFacebookBaseRequest *request = [ATFacebookBaseRequest new];
    request.appID = appID;
    request.placementID = placemengID;
    request.unitGroup = unitGroupModel;
    request.facebookPlacementID = info[@"unit_id"];
    request.completion = completion;
    request.unitGroups = placementModel.waterfallA;
    request.format = [self getFormatWithSizeString:info[@"size"]];
    request.timeOut = placementModel.FBHBTimeOut;
    [[ATFBBiddingManager sharedManager] bidRequest:request];
}

+ (ATFBBKFacebookAdBidFormat)getFormatWithSizeString:(NSString *)size {
    
    if ([size isEqualToString:@"320x90"]) {
        return ATFBBKFacebookAdBidFormatBanner_HEIGHT_90;
    }
    if ([size isEqualToString:@"320x250"]) {
        return ATFBBKFacebookAdBidFormatBanner_HEIGHT_250;
    }
    return ATFBBKFacebookAdBidFormatBanner_320_50;
}
@end
