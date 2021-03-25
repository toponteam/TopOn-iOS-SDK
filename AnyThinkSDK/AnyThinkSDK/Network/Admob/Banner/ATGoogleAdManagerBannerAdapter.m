//
//  ATGoogleAdManagerBannerAdapter.m
//  AnyThinkGoogleAdManagerBannerAdapter
//
//  Created by stephen on 7/27/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATGoogleAdManagerBannerAdapter.h"
#import "ATGoogleAdManagerBannerCustomEvent.h"
#import "ATAPI+Internal.h"
#import "ATBannerManager.h"
#import "ATAdManager+Banner.h"
#import <objc/runtime.h>
#import "Utilities.h"
#import "ATAppSettingManager.h"
#import "ATAdmobBaseManager.h"

@interface ATGoogleAdManagerBannerAdapter()
@property(nonatomic, readonly) ATGoogleAdManagerBannerCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATDFPBannerView> bannerView;
@end
@implementation ATGoogleAdManagerBannerAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATAdmobBaseManager initGoogleAdManagerWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"DFPBannerView") != nil && NSClassFromString(@"DFPRequest") != nil) {
        _customEvent = [[ATGoogleAdManagerBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        CGSize unitGroupSize = ((ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey]).adSize;
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_bannerView = [[NSClassFromString(@"DFPBannerView") alloc] initWithAdSize:(GADAdSize){CGSizeMake(unitGroupSize.width, unitGroupSize.height), 0}];
            self->_bannerView.adUnitID = serverInfo[@"unit_id"];
            self->_bannerView.delegate = self->_customEvent;
            self->_bannerView.rootViewController = [ATBannerCustomEvent rootViewControllerWithPlacementID:((ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey]).placementID requestID:serverInfo[kAdapterCustomInfoRequestIDKey]];
            [self->_bannerView loadRequest:[NSClassFromString(@"DFPRequest") request]];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"GoogleAdManager"]}]);
    }
}
@end
