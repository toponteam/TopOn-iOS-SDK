//
//  ATADXRewardedVideoAdapter.m
//  AnyThinkSDK
//
//  Created by stephen on 20/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATADXRewardedVideoAdapter.h"
#import "ATADXRewardedVideoCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
#import "ATBidInfo.h"
#import "ATBidInfoManager.h"
#import "ATNetworkingManager.h"
#import "ATAdManager+Internal.h"
#import "ATADXRewardedVideoAdManager.h"
#import "ATRewardedVideoManager.h"

@interface ATADXRewardedVideoAdapter()
@property(nonatomic, readonly) ATADXRewardedVideoCustomEvent *customEvent;
@end


@implementation ATADXRewardedVideoAdapter
+(NSDictionary*)headerBiddingParametersWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel extra:(NSDictionary *)extra {
    return @{@"unit_id":unitGroupModel.unitID,
             @"nw_firm_id":@(unitGroupModel.networkFirmID),
             @"ad_format":@(ATAdFormatRewardedVideo).stringValue,
             @"ecpoffer":[[ATAPI sharedInstance] exludeAppleIdArray] != nil? [[ATAPI sharedInstance] exludeAppleIdArray]:@[]
    };
}


+(id<ATAd>) readyFilledAdWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID priority:(NSInteger)priority unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall *)finalWaterfall {
    ATADXRewardedVideoCustomEvent *customEvent = [[ATADXRewardedVideoCustomEvent alloc] initWithInfo:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil] localInfo:nil];
    customEvent.price = [[ATADXRewardedVideoAdManager sharedManager] priceForReadyUnitGroupModel:unitGroup setting:[[ATADXPlacementSetting alloc] initWithPlacementDictionary:placementModel.adxSettingDict infoDictionary:[ATAdCustomEvent customInfoWithUnitGroupModel:unitGroup extra:nil] placementID:placementModel.placementID]];
    ATRewardedVideo *ad = [[ATRewardedVideo alloc] initWithPriority:priority placementModel:placementModel requestID:requestID assets:@{kRewardedVideoAssetsUnitIDKey:customEvent.unitID, kAdAssetsCustomObjectKey:customEvent.unitID, kRewardedVideoAssetsCustomEventKey:customEvent} unitGroup:unitGroup finalWaterfall:finalWaterfall];
    return ad;
}

+(BOOL) adReadyForInfo:(NSDictionary*)info {
    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)info[kAdapterCustomInfoUnitGroupModelKey];
    ATPlacementModel *placementModel = (ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey];
    return [[ATADXRewardedVideoAdManager sharedManager] readyForUnitGroupModel:unitGroupModel setting:[[ATADXPlacementSetting alloc] initWithPlacementDictionary:placementModel.adxSettingDict infoDictionary:info placementID:placementModel.placementID]];
}

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    ATADXRewardedVideoCustomEvent *customEvent = (ATADXRewardedVideoCustomEvent*)customObject;
    ATUnitGroupModel *unitGroupModel = customEvent.unitGroupModel;
    ATPlacementModel *placementModel = customEvent.placementModel;
    return [[ATADXRewardedVideoAdManager sharedManager] readyForUnitGroupModel:unitGroupModel setting:[[ATADXPlacementSetting alloc] initWithPlacementDictionary:placementModel.adxSettingDict infoDictionary:info placementID:placementModel.placementID]];
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    
    ATADXRewardedVideoCustomEvent *customEvent = (ATADXRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.delegate = delegate;
    ATUnitGroupModel *unitGroupModel = customEvent.unitGroupModel;
    ATPlacementModel *placementModel = customEvent.placementModel;
    NSString *requestID = customEvent.serverInfo[kAdapterCustomInfoRequestIDKey];
    ATBidInfo *bidInfo = [[ATBidInfoManager sharedManager] bidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
    
    [[ATADXRewardedVideoAdManager sharedManager] showRewardedVideoWithUnitGroupModel:unitGroupModel setting:[[ATADXPlacementSetting alloc] initWithPlacementDictionary:placementModel.adxSettingDict infoDictionary:customEvent.serverInfo placementID:placementModel.placementID] viewController:viewController delegate:customEvent];
    [[ATBidInfoManager sharedManager] invalidateBidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    
    _customEvent = [[ATADXRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
    ATPlacementModel *placementModel = (ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey];
    _customEvent.unitGroupModel = unitGroupModel;
    _customEvent.placementModel = placementModel;
    NSString *requestID = serverInfo[kAdapterCustomInfoRequestIDKey];
    ATBidInfo *bidInfo = [[ATBidInfoManager sharedManager] bidInfoForPlacementID:placementModel.placementID unitGroupModel:unitGroupModel requestID:requestID];
    if(bidInfo != nil){
        self->_customEvent.price = bidInfo.price;
        if (bidInfo.nURL.length > 0) { dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{ [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:bidInfo.nURL]] resume]; }); }
        [[ATADXRewardedVideoAdManager sharedManager] loadADWithUnitGroup:unitGroupModel bidInfo:bidInfo setting:[[ATADXPlacementSetting alloc] initWithPlacementDictionary:placementModel.adxSettingDict infoDictionary:serverInfo placementID:placementModel.placementID] placementModel:placementModel content:serverInfo requestID:requestID delegate:_customEvent];
    }else{
        completion(nil, [NSError errorWithDomain:@"com.anythink.ATADXRewardedVideoAdapter" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"ATADXRewardedVideoAdapter loadADWithInfo failed", NSLocalizedFailureReasonErrorKey:@"BidInfo is nil"}]);
    }
   
    
}

+(NSString*) adsourceRemoteKeyWithContent:(NSDictionary*)content unitGroupModel:(ATUnitGroupModel *)unitGroupModel {
    return unitGroupModel.unitID;
}

@end
