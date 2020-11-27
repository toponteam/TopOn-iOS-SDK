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
#import "ATBidInfo.h"
#import "ATBidInfoManager.h"

static NSString *const kATMintegralPluginNumber = @"Y+H6DFttYrPQYcIeicKwJQKQYrN=";//topon的渠道号
@interface ATMintegralBannerAdapter ()
@property(nonatomic, readonly) id<ATMTGBannerAdView> bannerView;
@property(nonatomic, readonly) ATMintegralBannerCustomEvent *customEvent;
@end

CGSize SizeInUnitGroupModel_MTGBannerSizeParser(ATUnitGroupModel *unitGroupModel) {
    CGSize size = CGSizeZero;
    NSArray<NSString*>* comp = [unitGroupModel.content[@"size"] componentsSeparatedByString:@"x"];
    if ([comp count] == 2 && [comp[0] respondsToSelector:@selector(doubleValue)] && [comp[1] respondsToSelector:@selector(doubleValue)]) { size = CGSizeMake([comp[0] doubleValue], [comp[1] doubleValue]); }
    return size;
}

@implementation ATMintegralBannerAdapter
+(NSDictionary*)headerBiddingParametersWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel extra:(NSDictionary *)extra {
    CGSize size = SizeInUnitGroupModel_MTGBannerSizeParser(unitGroupModel);
    return @{@"display_manager_ver":@"6.2.0",
             @"unit_id":unitGroupModel.content[@"unitid"] != nil ? unitGroupModel.content[@"unitid"] : @"",
             @"app_id":unitGroupModel.content[@"appid"] != nil ? unitGroupModel.content[@"appid"] : @"",
             @"nw_firm_id":@(unitGroupModel.networkFirmID),
             @"buyeruid":[NSClassFromString(@"MTGBiddingSDK") buyerUID] != nil ? [NSClassFromString(@"MTGBiddingSDK") buyerUID] : @"",
             @"ad_format":@(ATAdFormatBanner).stringValue,
             @"ad_width":@(size.width),
             @"ad_height":@(size.height)
    };
}

+(void) bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMintegral]) {
        [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"MTGSDK") sdkVersion] forNetwork:kNetworkNameMintegral];
        [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMintegral];
        void(^blk)(void) = ^{
            Class class = NSClassFromString(@"MTGSDK");
            SEL selector = NSSelectorFromString(@"setChannelFlag:");
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                if ([class respondsToSelector:selector]) {
                    [class performSelector:selector withObject:kATMintegralPluginNumber];
                }
            #pragma clang diagnostic pop
            
            BOOL set = NO;
            BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
            if (set) { ((id<ATMTGSDK>)[NSClassFromString(@"MTGSDK") sharedInstance]).consentStatus = !limit; }
            [[NSClassFromString(@"MTGSDK") sharedInstance] setAppID:info[@"appid"] ApiKey:info[@"appkey"]];
        };
        if ([NSThread currentThread].isMainThread) blk();
        else dispatch_sync(dispatch_get_main_queue(), blk);
    }
    
    if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) { [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[info[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:2 unitId:info[@"unitid"]]; }
    [NSClassFromString(@"MTGBiddingRequest") getBidWithRequestParameter:[[NSClassFromString(@"MTGBiddingBannerRequestParameter") alloc] initWithPlacementId:info[@"placement_id"] unitId:info[@"unitid"] basePrice:0 bannerSizeType:[ATMintegralBannerAdapter sizeToMTGBannerSizeType:unitGroupModel.adSize]] completionHandler:^(id<ATMTGBiddingResponse> bidResponse) {
        if (completion != nil) { completion(bidResponse.success ? [ATBidInfo bidInfoWithPlacementID:placementModel.placementID unitGroupUnitID:unitGroupModel.unitID token:bidResponse.bidToken price:bidResponse.price expirationInterval:unitGroupModel.bidTokenTime customObject:bidResponse] : nil, bidResponse.success ? nil : (bidResponse.error != nil ? bidResponse.error : [NSError errorWithDomain:@"com.anythink.MTGInterstitialHBFailure" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Bid request has failed", NSLocalizedFailureReasonErrorKey:@"MTGSDK has failed to get bid info"}])); }
    }];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"MTGSDK") sdkVersion] forNetwork:kNetworkNameMintegral];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMintegral]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMintegral];
                void(^blk)(void) = ^{
                    Class class = NSClassFromString(@"MTGSDK");
                    SEL selector = NSSelectorFromString(@"setChannelFlag:");
                    #pragma clang diagnostic push
                    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        if ([class respondsToSelector:selector]) {
                            [class performSelector:selector withObject:kATMintegralPluginNumber];
                        }
                    #pragma clang diagnostic pop
                    
                    BOOL set = NO;
                    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                    BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                    if (set) { ((id<ATMTGSDK>)[NSClassFromString(@"MTGSDK") sharedInstance]).consentStatus = !limit; }
                    [[NSClassFromString(@"MTGSDK") sharedInstance] setAppID:serverInfo[@"appid"] ApiKey:serverInfo[@"appkey"]];
                };
                if ([NSThread currentThread].isMainThread) blk();
                else dispatch_sync(dispatch_get_main_queue(), blk);
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"MTGSDK") != nil && NSClassFromString(@"MTGBannerAdView") != nil) {
        NSDictionary *extraInfo = localInfo;
        CGSize adSize = [extraInfo[kATAdLoadingExtraBannerAdSizeKey] respondsToSelector:@selector(CGSizeValue)] ? [extraInfo[kATAdLoadingExtraBannerAdSizeKey] CGSizeValue] : CGSizeMake(320.0f, 50.0f);
        _customEvent = [[ATMintegralBannerCustomEvent alloc]initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
        ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
        NSString *requestID = serverInfo[kAdapterCustomInfoRequestIDKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_bannerView = [[NSClassFromString(@"MTGBannerAdView") alloc] initBannerAdViewWithBannerSizeType:[ATMintegralBannerAdapter sizeToMTGBannerSizeType:unitGroupModel.adSize] placementId:serverInfo[@"placement_id"] unitId:serverInfo[@"unitid"] rootViewController:[ATBannerCustomEvent rootViewControllerWithPlacementID:((ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey]).placementID requestID:serverInfo[kAdapterCustomInfoRequestIDKey]]];
            self->_bannerView.delegate = self->_customEvent;
            self->_bannerView.autoRefreshTime = [serverInfo[@"nw_rft"] integerValue] / 1000;
            if ([serverInfo[@"size"] isEqualToString:@"smart"]) { self->_bannerView.frame = CGRectMake(0, 0, adSize.width, adSize.height); }
            ATBidInfo *bidInfo = [[ATBidInfoManager sharedManager] bidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
            if (bidInfo != nil) {
                if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) { [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[serverInfo[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:1 unitId:serverInfo[@"unitid"]]; }
                
                if (bidInfo.nURL != nil) { dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{ [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:bidInfo.nURL]] resume]; }); }
                
                self->_customEvent.price = bidInfo.price;
                [self->_bannerView loadBannerAdWithBidToken:bidInfo.bidId];
                [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
            }else {
                if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) { [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[serverInfo[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:0 unitId:serverInfo[@"unitid"]]; }
                self->_customEvent.price = unitGroupModel.price;
                [self->_bannerView loadBannerAd];
            }
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"MTG"]}]);
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

+(NSString*) adsourceRemoteKeyWithContent:(NSDictionary*)content unitGroupModel:(ATUnitGroupModel *)unitGroupModel {
    return content[@"unitid"];
}

@end
