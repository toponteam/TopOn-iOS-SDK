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
@interface ATBaiduBannerAdapter()
@property(nonatomic, readonly) ATBaiduBannerCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATBaiduMobAdView> baiduBannerView;
@property(nonatomic, readonly) UIView *containerView;
@end
@implementation ATBaiduBannerAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameBaidu];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameBaidu]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameBaidu];
                id<BaiduMobAdSetting> setting = [NSClassFromString(@"BaiduMobAdSetting") sharedInstance];
                setting.supportHttps = YES;
                [NSClassFromString(@"BaiduMobAdSetting") setMaxVideoCacheCapacityMb:30];
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"BaiduMobAdView") != nil) {
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)info[kAdapterCustomInfoUnitGroupModelKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_containerView = [[UIView alloc] initWithFrame:CGRectMake(.0, .0f, unitGroupModel.adSize.width, unitGroupModel.adSize.height)];
            self->_baiduBannerView = [[NSClassFromString(@"BaiduMobAdView") alloc] init];
            self->_baiduBannerView.AdUnitTag = info[@"ad_place_id"];
            self->_baiduBannerView.AdType = BaiduMobAdViewTypeBanner;
            self->_baiduBannerView.presentAdViewController = [ATBannerCustomEvent rootViewControllerWithPlacementID:((ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey]).placementID requestID:info[kAdapterCustomInfoRequestIDKey]];
            self->_baiduBannerView.frame = CGRectMake(.0, .0f, unitGroupModel.adSize.width, unitGroupModel.adSize.height);
            [self->_containerView addSubview:(UIView*)self->_baiduBannerView];
            
            self->_customEvent = [[ATBaiduBannerCustomEvent alloc] initWithUnitID:info[@"ad_place_id"] customInfo:info bannerView:self->_containerView];
            self->_customEvent.requestCompletionBlock = completion;
            self->_baiduBannerView.delegate = self->_customEvent;
            
            [self->_baiduBannerView start];
        });
        
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load banner ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Baidu"]}]);
    }
}
@end
