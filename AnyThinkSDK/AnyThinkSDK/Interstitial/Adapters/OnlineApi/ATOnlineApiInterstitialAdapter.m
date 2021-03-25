//
//  ATOlApiInterstitialAdapter.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/21.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiInterstitialAdapter.h"
#import "ATOnlineApiInterstitialCustomEvent.h"
#import "ATInterstitialManager.h"
#import "ATOnlineApiInterstitialAdManager.h"
#import "ATOnlineApiPlacementSetting.h"
#import "ATRequestConfiguration.h"
#import "ATOnlineApiLoader.h"

@interface ATOnlineApiInterstitialAdapter ()
@property(nonatomic, strong) ATOnlineApiInterstitialCustomEvent *customEvent;
@end

@implementation ATOnlineApiInterstitialAdapter

+ (id<ATAd>)readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall*)finalWaterfall {
    ATOnlineApiInterstitialCustomEvent *customEvent = [[ATOnlineApiInterstitialCustomEvent alloc] initWithInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil] localInfo:nil];
    customEvent.offerModel = [[ATOnlineApiLoader sharedLoader] readyOnlineApiAdWithUnitGroupModelID:unitGroup.unitID placementID:placementModel.placementID];
    ATInterstitial *ad = [[ATInterstitial alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:@{kInterstitialAssetsUnitIDKey:customEvent.unitID, kInterstitialAssetsCustomEventKey:customEvent, kAdAssetsCustomObjectKey:customEvent} unitGroup:unitGroup finalWaterfall:finalWaterfall];
    return ad;
}

+ (BOOL)adReadyForInfo:(NSDictionary*)info {
    ATUnitGroupModel *unitGroupModel = (ATUnitGroupModel *)info[kAdapterCustomInfoUnitGroupModelKey];
    ATPlacementModel *placementModel =  (ATPlacementModel *)info[kAdapterCustomInfoPlacementModelKey];
    
    ATOnlineApiPlacementSetting *setting = [[ATOnlineApiPlacementSetting alloc]initWithPlacementDictionary:placementModel.olApiSettingDict infoDictionary:info placementID:placementModel.placementID];

    return [[ATOnlineApiInterstitialAdManager sharedManager] readyOnlineApiAdWithUnitGroupModelID:unitGroupModel.unitID placementSetting:setting];
}

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    ATOnlineApiInterstitialCustomEvent *customEvent = (ATOnlineApiInterstitialCustomEvent*)customObject;
    ATUnitGroupModel *unitGroupModel = customEvent.unitGroupModel;
    ATPlacementModel *placementModel = customEvent.placementModel;
    
    ATOnlineApiPlacementSetting *setting = [[ATOnlineApiPlacementSetting alloc]initWithPlacementDictionary:placementModel.olApiSettingDict infoDictionary:info placementID:placementModel.placementID];

    return [[ATOnlineApiInterstitialAdManager sharedManager] readyOnlineApiAdWithUnitGroupModelID:unitGroupModel.unitID placementSetting:setting];
}

+ (void) showInterstitial:(ATInterstitial *)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    
    ATOnlineApiInterstitialCustomEvent *customEvent = (ATOnlineApiInterstitialCustomEvent *)interstitial.customEvent;
    customEvent.delegate = delegate;
    ATUnitGroupModel *unitGroupModel = customEvent.unitGroupModel;
    ATPlacementModel *placementModel = customEvent.placementModel;
    ATOnlineApiPlacementSetting *setting = [[ATOnlineApiPlacementSetting alloc]initWithPlacementDictionary:placementModel.olApiSettingDict infoDictionary:customEvent.serverInfo placementID:placementModel.placementID];

    [[ATOnlineApiInterstitialAdManager sharedManager] showInterstitialWithUnitGroupModelID:unitGroupModel.unitID setting:setting viewController:viewController delegate:customEvent];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    
    return self;
}

+(NSString*) adsourceRemoteKeyWithContent:(NSDictionary*)content unitGroupModel:(ATUnitGroupModel *)unitGroupModel{
    return unitGroupModel.unitID;
}

- (void)loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    _customEvent = [[ATOnlineApiInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
    
    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
    ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
    _customEvent.unitGroupModel = unitGroupModel;
    _customEvent.placementModel = placementModel;
    
    ATOnlineApiPlacementSetting *setting = [[ATOnlineApiPlacementSetting alloc]initWithPlacementDictionary:placementModel.olApiSettingDict infoDictionary:serverInfo placementID:placementModel.placementID];

    NSString *requestID = serverInfo[kAdapterCustomInfoRequestIDKey];

    ATRequestConfiguration *config = [ATRequestConfiguration new];
    config.networkFirmID = unitGroupModel.networkFirmID;
    config.setting = setting;
    config.unitID = unitGroupModel.unitID;
    config.delegate = _customEvent;
    config.requestID = requestID;
    config.extraInfo = serverInfo;
    config.groupID = placementModel.groupID;
    config.trafficGroupID = placementModel.trafficGroupID;
    [[ATOnlineApiInterstitialAdManager sharedManager] requestOnlineApiAdsWithConfiguration:config];
}

@end
