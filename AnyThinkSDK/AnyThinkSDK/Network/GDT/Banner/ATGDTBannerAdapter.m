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
#import "ATGDTBaseManager.h"
#import "ATAdManager+Banner.h"

@interface ATGDTBannerAdapter()
@property(nonatomic, readonly) ATGDTBannerCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATGDTMobBannerView> bannerView;
@property(nonatomic, readonly) id<ATGDTUnifiedBannerView> unifiedBannerView;
@end
@implementation ATGDTBannerAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATGDTBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"GDTUnifiedBannerView") != nil) {
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
        _customEvent = [[ATGDTBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([serverInfo[@"unit_version"] integerValue] == 2) {
                CGSize adSize = unitGroupModel.adSize;
                if ([localInfo[kATAdLoadingExtraBannerAdSizeKey] respondsToSelector:@selector(CGSizeValue)]) {
                    CGSize size = [localInfo[kATAdLoadingExtraBannerAdSizeKey] CGSizeValue];
                    adSize = CGSizeMake(size.width, size.width/6.4);
                }
                self->_unifiedBannerView = [[NSClassFromString(@"GDTUnifiedBannerView") alloc] initWithFrame:CGRectMake(.0f, .0f, adSize.width, adSize.height) placementId:serverInfo[@"unit_id"] viewController:[ATBannerCustomEvent rootViewControllerWithPlacementID:((ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey]).placementID requestID:serverInfo[kAdapterCustomInfoRequestIDKey]]];
                self->_unifiedBannerView.delegate = self->_customEvent;
                self->_unifiedBannerView.autoSwitchInterval = [serverInfo[@"nw_rft"] intValue] / 1000;
                [self->_unifiedBannerView loadAdAndShow];
            }
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"GDT"]}]);
    }
}
@end
