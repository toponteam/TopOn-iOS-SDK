//
//  ATRewardedVideo.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 28/06/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATRewardedVideo.h"
#import "Utilities.h"
#import "ATRewardedVideoManager.h"
#import "ATRewardedVideoCustomEvent.h"
#import "ATRewardedVideoAdapter.h"
#import "ATAdManager+Internal.h"
@implementation ATRewardedVideo
-(instancetype) initWithPriority:(NSInteger) priority placementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID assets:(NSDictionary*)assets unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall *)finalWaterfall {
    self = [super init];
    if (self != nil) {
        _priority = priority;
        _placementModel = placementModel;
        _requestID = requestID;
        _originalRequestID = requestID;
        _customObject = assets[kAdAssetsCustomObjectKey];
        _unitID = assets[kRewardedVideoAssetsUnitIDKey];
        _unitGroup = unitGroup;
        _cacheDate = [NSDate normalizaedDate];
        _expireDate = [[NSDate date] dateByAddingTimeInterval:_unitGroup.networkCacheTime / 1000.0f];
        _showTimes = 0;
        _customEvent = assets[kRewardedVideoAssetsCustomEventKey];
        _customEvent.ad = self;
        _customEvent.rewardedVideo = self;
        _appID = assets[kATAdAssetsAppIDKey];
        _priorityLevel = _placementModel.maxConcurrentRequestCount > 0 ? ([ATAdCustomEvent calculateAdPriority:self] / _placementModel.maxConcurrentRequestCount) + 1 : 1;
        _price = unitGroup.headerBidding ? assets[kAdAssetsPriceKey] : unitGroup.price;
        _finalWaterfall = finalWaterfall;
        if ([assets[kATTrackerExtraRequestExpectedOfferNumberFlagKey] boolValue]) { _autoReqType = 5; }
    }
    return self;
}

-(void) renewAdWithPriority:(NSInteger)priority placementModel:(ATPlacementModel *)placementModel unitGroup:(ATUnitGroupModel *)unitGroup requestID:(NSString *)requestID {
    _priority = priority;
    _placementModel = placementModel;
    _unitGroup = unitGroup;
    _requestID = requestID;
}

-(BOOL) renewed {
    return ![_originalRequestID isEqualToString:_requestID];
}

-(BOOL) filledByReady {
    NSDictionary *extra = [_customEvent.localInfo isKindOfClass:[NSDictionary class]] ? _customEvent.localInfo : nil;
    return [extra[kAdLoadingExtraFilledByReadyFlagKey] boolValue];
}

-(BOOL) filledByAutoloadOnClose {
    NSDictionary *extra = [_customEvent.localInfo isKindOfClass:[NSDictionary class]] ? _customEvent.localInfo : nil;
    return [extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue];
}

-(BOOL) ready {
    return [self.unitGroup.adapterClass adReadyWithCustomObject:self.customObject info:self.unitGroup.content];
}

-(NSString*)description {
    return [NSString stringWithFormat:@"{ hash:%ld======unit_group_id:%@======show_time:%ld======priority:%ld======cache_date:%lf======network_cache_time:%lf======placement_id: %@ }", [self hash], _unitGroup.unitGroupID, _showTimes, _priority, [_cacheDate timeIntervalSinceReferenceDate], _unitGroup.networkCacheTime, _placementModel.placementID];
}
@end
