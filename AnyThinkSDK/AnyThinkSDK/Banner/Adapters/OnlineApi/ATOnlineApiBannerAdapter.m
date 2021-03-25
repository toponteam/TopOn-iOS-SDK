//
//  ATOnlineApiBannerAdapter.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/22.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiBannerAdapter.h"
#import "ATOfferBannerView.h"
#import "ATOnlineApiBannerCustomEvent.h"
#import "ATOnlineApiOfferModel.h"
#import "ATOnlineApiLoader.h"
#import "ATOnlineApiPlacementSetting.h"
#import "ATOnlineApiBannerAdManager.h"
#import "ATRequestConfiguration.h"
#import "ATBannerManager.h"
#import "ATAdManager+Internal.h" 

@interface ATOnlineApiBannerAdapter()
@property(nonatomic, readonly) ATOnlineApiBannerCustomEvent *customEvent;
@end

@implementation ATOnlineApiBannerAdapter

//+ (id<ATAd>)readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall*)finalWaterfall {
//    ATOnlineApiOfferModel *offerModel = [[ATOnlineApiLoader sharedLoader] readyOnlineApiAdWithUnitGroupModelID:unitGroup.unitID placementID:placementModel.placementID];
//    NSDictionary *loadExtraInfo = [[ATAdManager sharedManager] lastExtraInfoForPlacementID:placementModel.placementID];
//    if (loadExtraInfo) {
//        ATOnlineApiBannerCustomEvent *customEvent = [[ATOnlineApiBannerCustomEvent alloc] initWithInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil] localInfo:loadExtraInfo];
//        customEvent.unitGroupModel = unitGroup;
//        customEvent.offerModel = offerModel;
//        customEvent.setting = [[ATOnlineApiPlacementSetting alloc] initWithPlacementDictionary:placementModel.olApiSettingDict infoDictionary:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil] placementID:placementModel.placementID];
//        
//        ATOfferBannerView *bannerView = [[ATOnlineApiBannerAdManager sharedManager] retrieveBannerViewWithOfferModel:offerModel setting:[[ATOnlineApiPlacementSetting alloc] initWithPlacementDictionary:placementModel.adxSettingDict infoDictionary:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil] placementID:placementModel.placementID] extra:nil delegate:customEvent];
//        if(bannerView){
//            ATBanner *banner = [[ATBanner alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:@{kBannerAssetsUnitIDKey:offerModel.offerID, kBannerAssetsCustomEventKey:customEvent, kBannerAssetsBannerViewKey:bannerView} unitGroup:unitGroup finalWaterfall:finalWaterfall];
//            return banner;
//        }else{
//            return nil;
//        }
//    }else{
//        return nil;
//    }
//}
//
//+ (BOOL)adReadyForInfo:(NSDictionary*)info {
//    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)info[kAdapterCustomInfoUnitGroupModelKey];
//    ATPlacementModel *placementModel = (ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey];
//    ATOnlineApiPlacementSetting *setting = [[ATOnlineApiPlacementSetting alloc] initWithPlacementDictionary:placementModel.olApiSettingDict infoDictionary:info placementID:placementModel.placementID];
//    return [[ATOnlineApiBannerAdManager sharedManager] readyOnlineApiAdWithUnitGroupModelID:unitGroupModel.unitID placementSetting:setting];
//}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    _customEvent = [[ATOnlineApiBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    
    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
    ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
    
    _customEvent.unitGroupModel = unitGroupModel;
    _customEvent.setting = [[ATOnlineApiPlacementSetting alloc] initWithPlacementDictionary:placementModel.olApiSettingDict infoDictionary:serverInfo placementID:placementModel.placementID];
    
    NSString *requestID = serverInfo[kAdapterCustomInfoRequestIDKey];
    ATRequestConfiguration *config = [ATRequestConfiguration new];
    config.networkFirmID = unitGroupModel.networkFirmID;
    config.unitID = unitGroupModel.unitID;
    config.delegate = _customEvent;
    config.setting = _customEvent.setting;
    config.extraInfo = serverInfo;
    config.requestID = requestID;
    config.groupID = placementModel.groupID;
    config.trafficGroupID = placementModel.trafficGroupID;
    config.bannerWidth = [self sizeToSizeType:serverInfo[@"size"]].width;
    config.bannerHight = [self sizeToSizeType:serverInfo[@"size"]].height;
    [[ATOnlineApiBannerAdManager sharedManager] requestOnlineApiAdsWithConfiguration:config];
}

- (CGSize) sizeToSizeType:(NSString *)sizeStr {
    if ([sizeStr isEqualToString:@"728x90"]) {
        return CGSizeMake(728.0f, 90.0f);
    } else if ([sizeStr isEqualToString:@"300x250"]) {
        return CGSizeMake(300.0f, 250.0f);
    }  else if ([sizeStr isEqualToString:@"320x90"]) {
        return CGSizeMake(320.0f, 90.0f);
    } else {
        return CGSizeMake(320.0f, 50.0f);
    }
}

@end
