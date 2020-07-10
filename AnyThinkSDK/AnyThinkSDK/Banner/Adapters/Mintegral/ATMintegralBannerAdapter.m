//
//  ATMintegralBannerAdapter.m
//  AnyThinkSDK
//
//  Created by Topon on 2019/11/15.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import "ATMintegralBannerAdapter.h"
#import "ATMintegralBannerCustomEvent.h"
#import "ATAPI+Internal.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Banner.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATAppSettingManager.h"

@interface ATMintegralBannerAdapter ()
@property(nonatomic, readonly) id<ATMTGBannerAdView> bannerView;
@property(nonatomic, readonly) ATMintegralBannerCustomEvent *customEvent;
@end

@implementation ATMintegralBannerAdapter

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"MTGSDK") sdkVersion] forNetwork:kNetworkNameMintegral];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMintegral]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMintegral];
                void(^blk)(void) = ^{
                    BOOL set = NO;
                    BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                    if (set) { ((id<ATMTGSDK>)[NSClassFromString(@"MTGSDK") sharedInstance]).consentStatus = !limit; }
                    [[NSClassFromString(@"MTGSDK") sharedInstance] setAppID:info[@"appid"] ApiKey:info[@"appkey"]];
                };
                if ([NSThread currentThread].isMainThread) blk();
                else dispatch_sync(dispatch_get_main_queue(), blk);
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"MTGSDK") != nil && NSClassFromString(@"MTGBannerAdView") != nil) {
        NSDictionary *extraInfo = info[kAdapterCustomInfoExtraKey];
        CGSize adSize = [extraInfo[kATAdLoadingExtraBannerAdSizeKey] respondsToSelector:@selector(CGSizeValue)] ? [extraInfo[kATAdLoadingExtraBannerAdSizeKey] CGSizeValue] : CGSizeMake(320.0f, 50.0f);
        _customEvent = [[ATMintegralBannerCustomEvent alloc]initWithUnitID:info[@"unitid"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)info[kAdapterCustomInfoUnitGroupModelKey];
        NSString *requestID = info[kAdapterCustomInfoRequestIDKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_bannerView = [[NSClassFromString(@"MTGBannerAdView") alloc] initBannerAdViewWithBannerSizeType:[ATMintegralBannerAdapter sizeToMTGBannerSizeType:unitGroupModel.adSize] placementId:info[@"placement_id"] unitId:info[@"unitid"] rootViewController:[ATBannerCustomEvent rootViewControllerWithPlacementID:((ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey]).placementID requestID:info[kAdapterCustomInfoRequestIDKey]]];
            self->_bannerView.delegate = self->_customEvent;
            self->_bannerView.autoRefreshTime = [info[@"nw_rft"] integerValue] / 1000;
            if ([info[@"size"] isEqualToString:@"smart"]) { self->_bannerView.frame = CGRectMake(0, 0, adSize.width, adSize.height); }
            if ([unitGroupModel bidTokenWithRequestID:requestID] != nil) {
                if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) {
                    [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[info[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:1 unitId:info[@"unitid"]];
                }
                [self->_bannerView loadBannerAdWithBidToken:[unitGroupModel bidTokenWithRequestID:requestID]];
                [unitGroupModel setBidTokenUsedFlagForRequestID:requestID];
            }else {
                if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) {
                    [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[info[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:0 unitId:info[@"unitid"]];
                }
                [self->_bannerView loadBannerAd];
            }
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load banner.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"MTG"]}]);
    }
}

+(ATMTGBannerSizeType) sizeToMTGBannerSizeType:(CGSize)size {
    if (size.width == 320 && size.height == 50) {
        return ATMTGStandardBannerType320x50;
    } else if (size.width == 320 && size.height == 90) {
        return ATMTGLargeBannerType320x90;
    } else if (size.width == 300 && size.height == 250) {
        return ATMTGMediumRectangularBanner300x250;
    } else {
        return ATMTGSmartBannerType;
    }
}
@end
