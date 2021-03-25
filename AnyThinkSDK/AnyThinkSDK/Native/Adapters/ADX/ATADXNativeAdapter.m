//
//  ATADXNativeAdapter.m
//  AnyThinkSDK
//
//  Created by Topon on 10/20/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATADXNativeAdapter.h"
#import "ATADXNativeCustomEvent.h"
#import "ATADXNativeRenderer.h"
#import "NSObject+ExtraInfo.h"
#import "ATMyOfferUtilities.h"
#import "ATPlacementModel.h"
#import "ATADXOfferModel.h"
#import "ATPlacementSettingManager.h"
#import "ATADXAdManager.h"
#import "ATAPI+Internal.h"
#import "ATAdAdapter.h"
#import "ATADXNativeAdManager.h"
#import "ATADXLoader.h"
#import "ATBidInfo.h"
#import "ATBidInfoManager.h"
#import "ATAdManagement.h"
#import "ATOfferResourceManager.h"

@interface ATADXNativeAdapter ()
@property(nonatomic, readonly) ATADXNativeCustomEvent *customEvent;
@end

@implementation ATADXNativeAdapter

+(NSDictionary*)headerBiddingParametersWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel extra:(NSDictionary *)extra {
    return @{@"unit_id":unitGroupModel.unitID,
             @"nw_firm_id":@(unitGroupModel.networkFirmID),
             @"ad_format":@(ATAdFormatNative).stringValue,
             @"ecpoffer":[[ATAPI sharedInstance] exludeAppleIdArray] != nil? [[ATAPI sharedInstance] exludeAppleIdArray]:@[]
    };
}

//+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall*)finalWaterfall {
//    ATADXOfferModel *offerModel = [[ATADXLoader sharedLoader] offerModelWithPlacementID:placementModel.placementID unitGroupModel:unitGroup];
//    if (offerModel != nil && [[ATOfferResourceManager sharedManager] retrieveResourceModelWithResourceID:offerModel.localResourceID]) {
//        ATADXNativeCustomEvent *customEvent = [[ATADXNativeCustomEvent alloc] initWithUnitID:nil serverInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil] localInfo:nil];
//        customEvent.unitGroupModel = unitGroup;
//        customEvent.offerModel = offerModel;
//        customEvent.setting = [[ATADXPlacementSetting alloc] initWithPlacementDictionary:placementModel.adxSettingDict infoDictionary:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil] placementID:placementModel.placementID];
//        customEvent.price = [[ATADXNativeAdManager sharedManager] priceForReadyUnitGroupModel:unitGroup setting:[[ATADXPlacementSetting alloc] initWithPlacementDictionary:placementModel.adxSettingDict infoDictionary:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil] placementID:placementModel.placementID]];
//        ATNativeADCache *offerCache = [[ATNativeADCache alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:[self nativeAdLoaded:offerModel customEvent:customEvent] unitGroup:unitGroup finalWaterfall:finalWaterfall];
//        return offerCache;
//    } else {
//        return nil;
//    }
//}
//
//+(BOOL) adReadyForInfo:(NSDictionary*)info {
//    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)info[kAdapterCustomInfoUnitGroupModelKey];
//    ATPlacementModel *placementModel = (ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey];
//    return [[ATADXNativeAdManager sharedManager] readyForUnitGroupModel:unitGroupModel setting:[[ATADXPlacementSetting alloc] initWithPlacementDictionary:placementModel.adxSettingDict infoDictionary:info placementID:placementModel.placementID]];
//}

+(Class) rendererClass {
    return [ATADXNativeRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    _customEvent = [[ATADXNativeCustomEvent alloc] init];
    _customEvent.requestExtra = localInfo;
    _customEvent.unitID = serverInfo[@"unit_id"];
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
        if (bidInfo.nURL != nil) { dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{ [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:bidInfo.nURL]] resume]; }); }
        
        [[ATADXNativeAdManager sharedManager] loadADWithUnitGroup:unitGroupModel bidInfo:bidInfo setting:[[ATADXPlacementSetting alloc] initWithPlacementDictionary:placementModel.adxSettingDict infoDictionary:serverInfo placementID:placementModel.placementID] placementModel:placementModel content:serverInfo requestID:requestID delegate:_customEvent];
    }else{
        completion(nil, [NSError errorWithDomain:@"com.anythink.ATADXNativeAdapter" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"ATADXNativeAdapter loadADWithInfo failed", NSLocalizedFailureReasonErrorKey:@"BidInfo is nil"}]);
    }
}

//+ (NSDictionary *)nativeAdLoaded:(ATADXOfferModel*)offerModel customEvent:(ATADXNativeCustomEvent*)customEvent {
//    NSMutableDictionary *assetInfo = [NSMutableDictionary dictionary];
//    assetInfo[kAdAssetsCustomEventKey] = customEvent;
//    assetInfo[kAdAssetsCustomObjectKey] = offerModel;
//    assetInfo[kNativeADAssetsUnitIDKey] = customEvent.unitID;
//    assetInfo[kAdAssetsPriceKey] = customEvent.price;
//
//    if ([offerModel.title length] > 0) { assetInfo[kNativeADAssetsMainTitleKey] = offerModel.title; }
//    if ([offerModel.text length] > 0) { assetInfo[kNativeADAssetsMainTextKey] = offerModel.text; }
//    if ([offerModel.CTA length] > 0) { assetInfo[kNativeADAssetsCTATextKey] = offerModel.CTA; }
//
//    dispatch_group_t img_group = dispatch_group_create();
//    if ([offerModel.iconURL length] > 0) {
//       assetInfo[kNativeADAssetsIconURLKey] = offerModel.iconURL;
//       dispatch_group_enter(img_group);
//       [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:offerModel.iconURL] completion:^(UIImage *image, NSError *error) {
//           if ([image isKindOfClass:[UIImage class]]) { assetInfo[kNativeADAssetsIconImageKey] = image; }
//           dispatch_group_leave(img_group);
//       }];
//    }
//    if ([offerModel.fullScreenImageURL length] > 0) {
//       assetInfo[kNativeADAssetsImageURLKey] = offerModel.fullScreenImageURL;
//       dispatch_group_enter(img_group);
//       [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:offerModel.fullScreenImageURL] completion:^(UIImage *image, NSError *error) {
//           if ([image isKindOfClass:[UIImage class]]) { assetInfo[kNativeADAssetsMainImageKey] = image; }
//           dispatch_group_leave(img_group);
//       }];
//    }
//    if ([offerModel.logoURL length] > 0) {
//       assetInfo[kNativeADAssetsLogoURLKey] = offerModel.logoURL;
//       dispatch_group_enter(img_group);
//       [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:offerModel.logoURL] completion:^(UIImage *image, NSError *error) {
//           if ([image isKindOfClass:[UIImage class]]) { assetInfo[kNativeADAssetsLogoImageKey] = image; }
//           dispatch_group_leave(img_group);
//       }];
//    }
//
//    dispatch_group_wait(img_group, DISPATCH_TIME_FOREVER);
//    return assetInfo;
//}

+(NSString*) adsourceRemoteKeyWithContent:(NSDictionary*)content unitGroupModel:(ATUnitGroupModel *)unitGroupModel{
    return unitGroupModel.unitID;
}

@end
