//
//  ATTTBannerAdapter.m
//  AnyThinkTTBannerAdapter
//
//  Created by Martin Lau on 20/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATTTBannerAdapter.h"
#import "ATTTBannerCustomEvent.h"
#import "ATAPI+Internal.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Banner.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
@interface ATTTBannerAdapter()
@property(nonatomic, readonly) id<ATBUBannerAdView> bannerView;
@property(nonatomic, readonly) id<ATBUNativeExpressBannerView> expressBannerView;
@property(nonatomic, readonly) ATTTBannerCustomEvent *customEvent;
@end
@implementation ATTTBannerAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameTT]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameTT];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"BUAdSDKManager") SDKVersion] forNetwork:kNetworkNameTT];
            [NSClassFromString(@"BUAdSDKManager") setAppID:info[@"app_id"]];
        }
    }
    return self;
}


-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"BUBannerAdView") != nil && NSClassFromString(@"BUSize") != nil && NSClassFromString(@"BUNativeExpressBannerView") != nil) {

        NSDictionary *extraInfo = info[kAdapterCustomInfoExtraKey];
        CGSize adSize = [extraInfo[kATAdLoadingExtraBannerAdSizeKey] respondsToSelector:@selector(CGSizeValue)] ? [extraInfo[kATAdLoadingExtraBannerAdSizeKey] CGSizeValue] : CGSizeMake(320.0f, 50.0f);

        _customEvent = [[ATTTBannerCustomEvent alloc] initWithUnitID:info[@"slot_id"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        dispatch_async(dispatch_get_main_queue(), ^{
            id<ATBUSize> size = [NSClassFromString(@"BUSize") sizeBy:[info[@"media_size"] integerValue]];
            if ([info[@"layout_type"] integerValue] == 1) {
                self->_expressBannerView = [[NSClassFromString(@"BUNativeExpressBannerView") alloc]initWithSlotID:info[@"slot_id"] rootViewController:[ATBannerCustomEvent rootViewControllerWithPlacementID:((ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey]).placementID requestID:info[kAdapterCustomInfoRequestIDKey]] adSize:CGSizeMake(adSize.width, adSize.width * size.height / size.width) IsSupportDeepLink:YES];                self->_expressBannerView.frame = CGRectMake(.0f, .0f, adSize.width, adSize.width * size.height / size.width);
                self->_expressBannerView.delegate = self->_customEvent;
                [self->_expressBannerView loadAdData];
            } else {
                self->_bannerView = [[NSClassFromString(@"BUBannerAdView") alloc] initWithSlotID:info[@"slot_id"] size:size rootViewController:[ATBannerCustomEvent rootViewControllerWithPlacementID:((ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey]).placementID requestID:info[kAdapterCustomInfoRequestIDKey]]];
                self->_bannerView.frame = CGRectMake(.0f, .0f, adSize.width, adSize.width * size.height / size.width);
                self->_bannerView.delegate = self->_customEvent;
                [self->_bannerView loadAdData];
            }
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load banner.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"TT"]}]);
    }
}
@end
