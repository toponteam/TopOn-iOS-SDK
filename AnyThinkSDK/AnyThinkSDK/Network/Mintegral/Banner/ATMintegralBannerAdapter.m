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
#import "ATMintegralBaseManager.h"

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
    return @{@"display_manager_ver":[NSClassFromString(@"MTGSDK") sdkVersion],
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
    [ATMintegralBaseManager bidRequestWithPlacementModel:placementModel unitGroupModel:unitGroupModel info:info completion:completion];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATMintegralBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
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
            self->_customEvent.price = bidInfo ? bidInfo.price : unitGroupModel.price;
            self->_customEvent.bidId = bidInfo ? bidInfo.bidId : @"";
            if (bidInfo != nil) {
                if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) { [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[serverInfo[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:1 unitId:serverInfo[@"unitid"]]; }
                
                if (bidInfo.nURL != nil) { dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{ [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:bidInfo.nURL]] resume]; }); }
                
                [self->_bannerView loadBannerAdWithBidToken:bidInfo.bidId];
                [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
            }else {
                if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) { [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[serverInfo[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:0 unitId:serverInfo[@"unitid"]]; }
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
