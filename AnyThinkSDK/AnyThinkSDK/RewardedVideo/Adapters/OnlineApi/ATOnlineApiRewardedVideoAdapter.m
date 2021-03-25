//
//  ATOnlineApiRewardedVideoAdapter.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiRewardedVideoAdapter.h"
#import "ATOnlineApiRewardedVideoCustomEvent.h"
#import "ATUnitGroupModel.h"
#import "NSArray+KAKit.h"
#import "ATOnlineApiRewardedVideoManager.h"
#import "ATOnlineApiPlacementSetting.h"
#import "ATRewardedVideoManager.h"
#import "ATRequestConfiguration.h"
#import "ATOnlineApiLoader.h"

@interface ATOnlineApiRewardedVideoAdapter ()
@property(nonatomic, strong) ATOnlineApiRewardedVideoCustomEvent *customEvent;

@end

@implementation ATOnlineApiRewardedVideoAdapter

+ (id<ATAd>)readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall *)finalWaterfall {
    ATOnlineApiRewardedVideoCustomEvent *customEvent = [[ATOnlineApiRewardedVideoCustomEvent alloc] initWithInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil] localInfo:nil];
    customEvent.offerModel = [[ATOnlineApiLoader sharedLoader] readyOnlineApiAdWithUnitGroupModelID:unitGroup.unitID placementID:placementModel.placementID];
    ATRewardedVideo *ad = [[ATRewardedVideo alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:customEvent.unitID, kAdAssetsCustomObjectKey:customEvent.unitID, kRewardedVideoAssetsCustomEventKey:customEvent} unitGroup:unitGroup finalWaterfall:finalWaterfall];
    return ad;
}

+ (BOOL)adReadyForInfo:(NSDictionary*)info {
    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)info[kAdapterCustomInfoUnitGroupModelKey];
    ATPlacementModel *placementModel = (ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey];
    ATOnlineApiPlacementSetting *setting = [[ATOnlineApiPlacementSetting alloc]initWithPlacementDictionary:placementModel.olApiSettingDict infoDictionary:info placementID:placementModel.placementID];
    BOOL ready = [[ATOnlineApiRewardedVideoManager sharedManager] readyOnlineApiAdWithUnitGroupModelID:unitGroupModel.unitID placementSetting:setting];
    return ready;
}

+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    ATOnlineApiRewardedVideoCustomEvent *customEvent = (ATOnlineApiRewardedVideoCustomEvent* )customObject;
    ATUnitGroupModel *unitGroupModel = customEvent.unitGroupModel;
    ATPlacementModel *placementModel = customEvent.placementModel;
    
    ATOnlineApiPlacementSetting *setting = [[ATOnlineApiPlacementSetting alloc]initWithPlacementDictionary:placementModel.olApiSettingDict infoDictionary:customEvent.serverInfo placementID:placementModel.placementID];
    BOOL ready = [[ATOnlineApiRewardedVideoManager sharedManager] readyOnlineApiAdWithUnitGroupModelID:unitGroupModel.unitID placementSetting:setting];
    return ready;
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    
    ATOnlineApiRewardedVideoCustomEvent *customEvent = (ATOnlineApiRewardedVideoCustomEvent *)rewardedVideo.customEvent;
    customEvent.delegate = delegate;
    ATUnitGroupModel *unitGroupModel = customEvent.unitGroupModel;
    ATPlacementModel *placementModel = customEvent.placementModel;
    ATOnlineApiPlacementSetting *setting = [[ATOnlineApiPlacementSetting alloc]initWithPlacementDictionary:placementModel.olApiSettingDict infoDictionary:customEvent.serverInfo placementID:placementModel.placementID];

    [[ATOnlineApiRewardedVideoManager sharedManager] showRewardedVideoWithUnitGroupModelID:unitGroupModel.unitID setting:setting viewController:viewController delegate:customEvent];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    
    _customEvent = [[ATOnlineApiRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
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
    config.requestID = requestID;
    config.unitID = unitGroupModel.unitID;
    config.setting = setting;
    config.delegate = _customEvent;
    config.groupID = placementModel.groupID;
    config.trafficGroupID = placementModel.trafficGroupID;
    [[ATOnlineApiRewardedVideoManager sharedManager] requestOnlineApiAdsWithConfiguration:config];
}

+(NSString*) adsourceRemoteKeyWithContent:(NSDictionary*)content unitGroupModel:(ATUnitGroupModel *)unitGroupModel {
    return unitGroupModel.unitID;
}

@end
