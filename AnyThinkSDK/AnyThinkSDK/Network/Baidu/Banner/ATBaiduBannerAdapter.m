//
//  ATBaiduBannerAdapter.m
//  AnyThinkBaiduBannerAdapter
//
//  Created by Martin Lau on 2018/11/30.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATBaiduBannerAdapter.h"
#import "ATBaiduBannerCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATBaiduBaseManager.h"

@interface ATBaiduBannerAdapter()
@property(nonatomic, readonly) ATBaiduBannerCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATBaiduMobAdView> baiduBannerView;
@property(nonatomic, readonly) UIView *containerView;
@end
@implementation ATBaiduBannerAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATBaiduBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"BaiduMobAdView") != nil) {
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_containerView = [[UIView alloc] initWithFrame:CGRectMake(.0, .0f, unitGroupModel.adSize.width, unitGroupModel.adSize.height)];
            self->_baiduBannerView = [[NSClassFromString(@"BaiduMobAdView") alloc] init];
            self->_baiduBannerView.AdUnitTag = serverInfo[@"ad_place_id"];
            self->_baiduBannerView.AdType = BaiduMobAdViewTypeBanner;
            self->_baiduBannerView.presentAdViewController = [ATBannerCustomEvent rootViewControllerWithPlacementID:((ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey]).placementID requestID:serverInfo[kAdapterCustomInfoRequestIDKey]];
            self->_baiduBannerView.frame = CGRectMake(.0, .0f, unitGroupModel.adSize.width, unitGroupModel.adSize.height);
            [self->_containerView addSubview:(UIView*)self->_baiduBannerView];
            
            self->_customEvent = [[ATBaiduBannerCustomEvent alloc] initWithUnitID:serverInfo[@"ad_place_id"] serverInfo:serverInfo localInfo:localInfo bannerView:self->_containerView];
            self->_customEvent.requestCompletionBlock = completion;
            self->_baiduBannerView.delegate = self->_customEvent;
            
            [self->_baiduBannerView start];
        });
        
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Baidu"]}]);
    }
}
@end
