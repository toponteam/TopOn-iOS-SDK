//
//  ATOnlineApiNativeAdapter.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/21.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiNativeAdapter.h"
#import "ATOnlineApiOfferModel.h"
#import "ATOnlineApiLoader.h"
#import "ATOfferResourceManager.h"
#import "ATOnlineApiNativeAdCustomEvent.h"
#import "ATOnlineApiPlacementSetting.h"
#import "ATOnlineApiNativeAdManager.h"
#import "ATNativeADCache.h"
#import "ATOnlineApiNativeRender.h"
#import "NSObject+ExtraInfo.h"
#import "ATRequestConfiguration.h"
#import "ATNativeADOfferManager.h"

@interface ATOnlineApiNativeAdapter ()
@property(nonatomic, readonly) ATOnlineApiNativeAdCustomEvent *customEvent;

@end
@implementation ATOnlineApiNativeAdapter

//+ (id<ATAd>)readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall*)finalWaterfall {
//
//    ATOnlineApiOfferModel *model = [[ATOnlineApiLoader sharedLoader] readyOnlineApiAdWithUnitGroupModelID:unitGroup.unitID placementID:placementModel.placementID];
//    ATOfferResourceModel *resource = [[ATOfferResourceManager sharedManager] retrieveResourceModelWithResourceID:model.localResourceID];
//    if (model && resource) {
//        NSDictionary *serverInfo = [ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil];
//        ATOnlineApiNativeAdCustomEvent *customEvent = [[ATOnlineApiNativeAdCustomEvent alloc] initWithUnitID:nil serverInfo:serverInfo localInfo:nil];
//        customEvent.offerModel = model;
//        customEvent.setting = [[ATOnlineApiPlacementSetting alloc]initWithPlacementDictionary:placementModel.olApiSettingDict infoDictionary:serverInfo placementID:placementModel.placementID];
//
//        ATNativeADCache *offerCache = [[ATNativeADCache alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:[self nativeAdLoaded:model customEvent:customEvent] unitGroup:unitGroup finalWaterfall:finalWaterfall];
//        return offerCache;
//    } else {
//        return nil;
//    }
//}
//
//+ (BOOL)adReadyForInfo:(NSDictionary*)info {
//    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)info[kAdapterCustomInfoUnitGroupModelKey];
//    ATPlacementModel *placementModel = (ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey];
//    ATOnlineApiPlacementSetting *setting = [[ATOnlineApiPlacementSetting alloc]initWithPlacementDictionary:placementModel.olApiSettingDict infoDictionary:info placementID:placementModel.placementID];
//    BOOL ready = [[ATOnlineApiNativeAdManager sharedManager] readyOnlineApiAdWithUnitGroupModelID:unitGroupModel.unitID placementSetting:setting];
//    return ready;
//}

+ (Class)rendererClass {
    return [ATOnlineApiNativeRender class];
}

- (instancetype)initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    return self;
}

- (void)loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    _customEvent = [[ATOnlineApiNativeAdCustomEvent alloc] init];
    _customEvent.requestExtra = localInfo;
    _customEvent.unitID = serverInfo[@"unit_id"];
    _customEvent.requestCompletionBlock = completion;
    
    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
    ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
    
    _customEvent.unitGroupModel = unitGroupModel;
    _customEvent.setting = [[ATOnlineApiPlacementSetting alloc]initWithPlacementDictionary:placementModel.olApiSettingDict infoDictionary:serverInfo placementID:placementModel.placementID];
        
    NSString *requestID = serverInfo[kAdapterCustomInfoRequestIDKey];

    ATRequestConfiguration *config = [ATRequestConfiguration new];
    config.networkFirmID = unitGroupModel.networkFirmID;
    config.unitID = unitGroupModel.unitID;
    config.setting = _customEvent.setting;
    config.delegate = _customEvent;
    config.extraInfo = serverInfo;
    config.requestID = requestID;
    config.groupID = placementModel.groupID;
    config.trafficGroupID = placementModel.trafficGroupID;
    [[ATOnlineApiNativeAdManager sharedManager] requestOnlineApiAdsWithConfiguration:config];
}

+ (NSDictionary *)nativeAdLoaded:(ATOnlineApiOfferModel *)offerModel customEvent:(ATOnlineApiNativeAdCustomEvent *)customEvent {
    NSMutableDictionary *assetInfo = [NSMutableDictionary dictionary];
    assetInfo[kAdAssetsCustomEventKey] = customEvent;
    assetInfo[kAdAssetsCustomObjectKey] = offerModel;
    assetInfo[kNativeADAssetsUnitIDKey] = customEvent.unitID;
    
    if ([offerModel.title length] > 0) { assetInfo[kNativeADAssetsMainTitleKey] = offerModel.title; }
    if ([offerModel.text length] > 0) { assetInfo[kNativeADAssetsMainTextKey] = offerModel.text; }
    if ([offerModel.CTA length] > 0) { assetInfo[kNativeADAssetsCTATextKey] = offerModel.CTA; }
    
    dispatch_group_t img_group = dispatch_group_create();
    if ([offerModel.iconURL length] > 0) {
       assetInfo[kNativeADAssetsIconURLKey] = offerModel.iconURL;
       dispatch_group_enter(img_group);
       [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:offerModel.iconURL] completion:^(UIImage *image, NSError *error) {
           if ([image isKindOfClass:[UIImage class]]) { assetInfo[kNativeADAssetsIconImageKey] = image; }
           dispatch_group_leave(img_group);
       }];
    }
    if ([offerModel.fullScreenImageURL length] > 0) {
       assetInfo[kNativeADAssetsImageURLKey] = offerModel.fullScreenImageURL;
       dispatch_group_enter(img_group);
       [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:offerModel.fullScreenImageURL] completion:^(UIImage *image, NSError *error) {
           if ([image isKindOfClass:[UIImage class]]) { assetInfo[kNativeADAssetsMainImageKey] = image; }
           dispatch_group_leave(img_group);
       }];
    }
    if ([offerModel.logoURL length] > 0) {
       assetInfo[kNativeADAssetsLogoURLKey] = offerModel.logoURL;
       dispatch_group_enter(img_group);
       [[ATImageLoader shareLoader] loadImageWithURL:[NSURL URLWithString:offerModel.logoURL] completion:^(UIImage *image, NSError *error) {
           if ([image isKindOfClass:[UIImage class]]) { assetInfo[kNativeADAssetsLogoImageKey] = image; }
           dispatch_group_leave(img_group);
       }];
    }
    
    dispatch_group_wait(img_group, DISPATCH_TIME_FOREVER);
    return assetInfo;
}
@end
