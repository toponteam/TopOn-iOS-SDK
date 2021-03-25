//
//  ATADXBannerAdapter.m
//  AnyThinkSDK
//
//  Created by Topon on 10/22/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATADXBannerAdapter.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
#import "Utilities.h"
#import "ATAdManager+Internal.h"
#import "ATAdManager+Banner.h"
#import "ATADXOfferModel.h"
#import "ATADXPlacementSetting.h"
#import "ATBannerManager.h"
#import "ATBidInfo.h"
#import "ATBidInfoManager.h"
#import "ATADXBannerAdManager.h"
#import "ATOfferBannerView.h"
#import "ATADXBannerCustomEvent.h"
#import "ATADXLoader.h"

@interface ATADXBannerAdapter()
@property(nonatomic, readonly) ATADXBannerCustomEvent *customEvent;
@end

@implementation ATADXBannerAdapter

+(NSDictionary*)headerBiddingParametersWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel extra:(NSDictionary *)extra {
    return @{@"unit_id":unitGroupModel.unitID,
             @"nw_firm_id":@(unitGroupModel.networkFirmID),
             @"ad_format":@(ATAdFormatBanner).stringValue,
             @"ad_width":@(unitGroupModel.adSize.width),
             @"ad_height":@(unitGroupModel.adSize.height),
             @"ecpoffer":[[ATAPI sharedInstance] exludeAppleIdArray] != nil? [[ATAPI sharedInstance] exludeAppleIdArray]:@[]
    };
}

//+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall*)finalWaterfall {
//    ATADXOfferModel *offerModel = [[ATADXLoader sharedLoader] offerModelWithPlacementID:placementModel.placementID unitGroupModel:unitGroup];
//    if (offerModel != nil) {
//        NSDictionary *loadExtraInfo = [[ATAdManager sharedManager] lastExtraInfoForPlacementID:placementModel.placementID];
//        if (loadExtraInfo != nil) {
//            ATADXBannerCustomEvent *customEvent = [[ATADXBannerCustomEvent alloc] initWithInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil] localInfo:loadExtraInfo];
//            customEvent.unitGroupModel = unitGroup;
//            customEvent.offerModel = offerModel;
//            customEvent.setting = [[ATADXPlacementSetting alloc] initWithPlacementDictionary:placementModel.adxSettingDict infoDictionary:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil] placementID:placementModel.placementID];
//            customEvent.price = [[ATADXBannerAdManager sharedManager] priceForReadyUnitGroupModel:unitGroup setting:[[ATADXPlacementSetting alloc] initWithPlacementDictionary:placementModel.adxSettingDict infoDictionary:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil] placementID:placementModel.placementID]];
//
//            ATOfferBannerView *bannerView = [[ATADXBannerAdManager sharedManager] retrieveBannerViewWithOfferModel:offerModel setting:[[ATADXPlacementSetting alloc] initWithPlacementDictionary:placementModel.adxSettingDict infoDictionary:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil] placementID:placementModel.placementID] extra:nil delegate:customEvent];
//            if(bannerView != nil){
//                ATBanner *banner = [[ATBanner alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:@{kBannerAssetsUnitIDKey:offerModel.offerID, kBannerAssetsCustomEventKey:customEvent, kBannerAssetsBannerViewKey:bannerView} unitGroup:unitGroup finalWaterfall:finalWaterfall];
//                return banner;
//            }else{
//                return nil;
//            }
//        }else{
//            return nil;
//        }
//    } else {
//        return nil;
//    }
//}
//
//+(BOOL) adReadyForInfo:(NSDictionary*)info {
//    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)info[kAdapterCustomInfoUnitGroupModelKey];
//    ATPlacementModel *placementModel = (ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey];
//    return [[ATADXBannerAdManager sharedManager] readyForUnitGroupModel:unitGroupModel setting:[[ATADXPlacementSetting alloc] initWithPlacementDictionary:placementModel.adxSettingDict infoDictionary:info placementID:placementModel.placementID]];
//}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    _customEvent = [[ATADXBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    
    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
    ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
    
    _customEvent.unitGroupModel = unitGroupModel;
    _customEvent.setting = [[ATADXPlacementSetting alloc] initWithPlacementDictionary:placementModel.adxSettingDict infoDictionary:serverInfo placementID:placementModel.placementID];
    
    NSString *requestID = serverInfo[kAdapterCustomInfoRequestIDKey];
    _customEvent.requestID = requestID;
    ATBidInfo *bidInfo = [[ATBidInfoManager sharedManager] bidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
    if(bidInfo != nil){
        self->_customEvent.price = bidInfo.price;
        self->_customEvent.bidId = bidInfo.bidId;
        if (bidInfo.nURL.length > 0) { dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{ [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:bidInfo.nURL]] resume]; }); }
        [[ATADXBannerAdManager sharedManager] loadADWithUnitGroup:unitGroupModel bidInfo:bidInfo setting:[[ATADXPlacementSetting alloc] initWithPlacementDictionary:placementModel.adxSettingDict infoDictionary:serverInfo placementID:placementModel.placementID] placementModel:placementModel content:serverInfo requestID:requestID delegate:_customEvent];
    }else{
        completion(nil, [NSError errorWithDomain:@"com.anythink.ATADXBannerAdapter" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"ATADXBannerAdapter loadADWithInfo failed", NSLocalizedFailureReasonErrorKey:@"BidInfo is nil"}]);
    }
}

+(NSString*) adsourceRemoteKeyWithContent:(NSDictionary*)content unitGroupModel:(ATUnitGroupModel *)unitGroupModel{
    return unitGroupModel.unitID;
}

@end
