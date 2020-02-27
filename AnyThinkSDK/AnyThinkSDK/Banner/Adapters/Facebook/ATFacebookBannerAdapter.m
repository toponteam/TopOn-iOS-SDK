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

@interface ATFacebookBannerAdapter()
@property(nonatomic, readonly) ATFacebookBannerCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATFBAdView> adView;
@end
@implementation ATFacebookBannerAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameFacebook]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameFacebook];
            [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameFacebook];
        }
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"FBAdView") != nil) {
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)info[kAdapterCustomInfoUnitGroupModelKey];
        _customEvent = [[ATFacebookBannerCustomEvent alloc] initWithUnitID:info[@"unit_id"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_adView = [[NSClassFromString(@"FBAdView") alloc] initWithPlacementID:info[@"unit_id"] adSize:(struct FBAdSize){{-1, unitGroupModel.adSize.height}} rootViewController:[ATBannerCustomEvent rootViewControllerWithPlacementID:((ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey]).placementID requestID:info[kAdapterCustomInfoRequestIDKey]]];
            self->_adView.frame = CGRectMake(0, 0, unitGroupModel.adSize.width, unitGroupModel.adSize.height);
            self->_adView.delegate = self->_customEvent;
            NSString *requestID = info[kAdapterCustomInfoRequestIDKey];
            if ([unitGroupModel bidTokenWithRequestID:requestID] != nil) {
                [self->_adView loadAdWithBidPayload:[unitGroupModel bidTokenWithRequestID:requestID]];
                [unitGroupModel setBidTokenUsedFlagForRequestID:requestID];
            } else {
                [self->_adView loadAd];
            }
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load banner.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Facebook"]}]);
    }
}
@end
