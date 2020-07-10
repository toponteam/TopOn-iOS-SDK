//
//  ATGDTBannerAdapter.m
//  AnyThinkGDTBannerAdapter
//
//  Created by Martin Lau on 20/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATGDTBannerAdapter.h"
#import "ATGDTBannerCustomEvent.h"
#import <objc/runtime.h>
#import "ATAdLoader.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
@interface ATGDTBannerAdapter()
@property(nonatomic, readonly) ATGDTBannerCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATGDTMobBannerView> bannerView;
@property(nonatomic, readonly) id<ATGDTUnifiedBannerView> unifiedBannerView;
@end
@implementation ATGDTBannerAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameGDT]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameGDT];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"GDTSDKConfig") sdkVersion] forNetwork:kNetworkNameGDT];
            [NSClassFromString(@"GDTSDKConfig") registerAppId:info[@"app_id"]];
        }
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"GDTMobBannerView") != nil && NSClassFromString(@"GDTUnifiedBannerView") != nil) {
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)info[kAdapterCustomInfoUnitGroupModelKey];
        _customEvent = [[ATGDTBannerCustomEvent alloc] initWithUnitID:info[@"unit_id"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([info[@"unit_version"] integerValue] == 2) {
                self->_unifiedBannerView = [[NSClassFromString(@"GDTUnifiedBannerView") alloc] initWithFrame:CGRectMake(.0f, .0f, unitGroupModel.adSize.width, unitGroupModel.adSize.height) placementId:info[@"unit_id"] viewController:[ATBannerCustomEvent rootViewControllerWithPlacementID:((ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey]).placementID requestID:info[kAdapterCustomInfoRequestIDKey]]];
                self->_unifiedBannerView.delegate = self->_customEvent;
                self->_unifiedBannerView.autoSwitchInterval = [info[@"nw_rft"] intValue] / 1000;
                [self->_unifiedBannerView loadAdAndShow];
            } else {
                self->_bannerView = [[NSClassFromString(@"GDTMobBannerView") alloc] initWithFrame:CGRectMake(.0f, .0f, unitGroupModel.adSize.width, unitGroupModel.adSize.height) appId:info[@"app_id"] placementId:info[@"unit_id"]];
                self->_bannerView.delegate = self->_customEvent;
                self->_customEvent.gdtBannerView = self->_bannerView;
                self->_bannerView.currentViewController = [ATBannerCustomEvent rootViewControllerWithPlacementID:((ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey]).placementID requestID:info[kAdapterCustomInfoRequestIDKey]];
                self->_bannerView.interval = [info[@"nw_rft"] intValue] / 1000;
                [self->_bannerView loadAdAndShow];
            }
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load banner.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"GDT"]}]);
    }
}
@end
