//
//  ATApplovinBannerAdapter.m
//  AnyThinkApplovinBannerAdapter
//
//  Created by Martin Lau on 20/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATApplovinBannerAdapter.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATApplovinBannerCustomEvent.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
#import "ATApplovinBaseManager.h"

@interface ATApplovinBannerAdapter()
@property(nonatomic, readonly) id<ATALAdView> bannerView;
@property(nonatomic, readonly) ATApplovinBannerCustomEvent *customEvent;
@end
@implementation ATApplovinBannerAdapter
+(void) showBanner:(ATBanner*)banner inView:(UIView*)view presentingViewController:(UIViewController*)viewController {
    id<ATALAdView> bannerView = banner.bannerView;
    [bannerView render:banner.customObject];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATApplovinBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"ALAdView") != nil && NSClassFromString(@"ALSdk") != nil && NSClassFromString(@"ALAdSize") != nil) {
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
        _customEvent = [[ATApplovinBannerCustomEvent alloc] initWithUnitID:serverInfo[@"zone_id"] serverInfo:serverInfo localInfo:localInfo sdkKey:serverInfo[@"sdkkey"] alSize:unitGroupModel.adSize];
        _customEvent.requestCompletionBlock = completion;
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_bannerView = [[NSClassFromString(@"ALAdView") alloc] initWithSdk:[NSClassFromString(@"ALSdk") sharedWithKey:serverInfo[@"sdkkey"]] size:CGSizeEqualToSize(unitGroupModel.adSize, CGSizeMake(300.0f, 250.0f)) ? [NSClassFromString(@"ALAdSize") sizeMRec] : [NSClassFromString(@"ALAdSize") sizeBanner] zoneIdentifier:serverInfo[@"zone_id"]];
            self->_bannerView.adLoadDelegate = self->_customEvent;
            self->_bannerView.adEventDelegate = self->_customEvent;
            self->_bannerView.adEventDelegate = self->_customEvent;
            self->_customEvent.alAdView = self->_bannerView;
            [self->_bannerView loadNextAd];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Applovin"]}]);
    }
}
@end
