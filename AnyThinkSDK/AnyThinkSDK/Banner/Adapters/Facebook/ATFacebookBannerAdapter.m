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
-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameFacebook]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameFacebook];
            [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameFacebook];
            [NSClassFromString(@"FBAdSettings") setAdvertiserTrackingEnabled:YES];
        }
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"FBAdView") != nil) {
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
        _customEvent = [[ATFacebookBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_adView = [[NSClassFromString(@"FBAdView") alloc] initWithPlacementID:serverInfo[@"unit_id"] adSize:(struct FBAdSize){{-1, unitGroupModel.adSize.height}} rootViewController:[ATBannerCustomEvent rootViewControllerWithPlacementID:((ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey]).placementID requestID:serverInfo[kAdapterCustomInfoRequestIDKey]]];
            self->_adView.frame = CGRectMake(0, 0, unitGroupModel.adSize.width, unitGroupModel.adSize.height);
            self->_adView.delegate = self->_customEvent;
            [self->_adView loadAd];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Facebook"]}]);
    }
}
@end
