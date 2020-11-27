//
//  ATNativeADCache.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 17/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATNativeADCache.h"
#import "ATAPI+Internal.h"
#import "ATPlacementModel.h"
#import "Utilities.h"
#import "ATAdCustomEvent.h"
#import "ATAdManagement.h"
@interface ATNativeAd(Private)
-(instancetype) initWithAssets:(NSDictionary*)assets;
@end

@implementation ATNativeADCache
-(instancetype) initWithPriority:(NSInteger) priority placementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID assets:(NSDictionary*)assets unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall *)finalWaterfall {
    self = [super initWithAssets:assets];
    if (self != nil) {
        _priority = priority;
        _placementModel = placementModel;
        _requestID = requestID;
        _originalRequestID = requestID;
        _assets = [NSDictionary dictionaryWithDictionary:assets];
        _unitGroup = unitGroup;
         _finalWaterfall = finalWaterfall;
        _cacheDate = [NSDate normalizaedDate];
        _expireDate = [[NSDate date] dateByAddingTimeInterval:_unitGroup.networkCacheTime / 1000.0f];
        _showTimes = 0;
        _customEvent = assets[kAdAssetsCustomEventKey];
        _customObject = assets[kAdAssetsCustomObjectKey];
        _unitID = assets[kNativeADAssetsUnitIDKey];
        _appID = assets[kATAdAssetsAppIDKey];
        _priorityIndex = [ATAdCustomEvent calculateAdPriority:self];
        _priorityLevel = _placementModel.maxConcurrentRequestCount > 0 ? (_priorityIndex / _placementModel.maxConcurrentRequestCount) + 1 : 1;
        _price = unitGroup.headerBidding ? assets[kAdAssetsPriceKey] : unitGroup.price;
        if ([assets[kATTrackerExtraRequestExpectedOfferNumberFlagKey] boolValue]) { _autoReqType = 5; }
    }
    return self;
}

-(BOOL) ready {
    return YES;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"{ hash:%ld======unit_group_id:%@======show_time:%ld======priority:%ld======cache_date:%lf======network_cache_time:%lf======placement_id: %@ }", [self hash], _unitGroup.unitGroupID, _showTimes, _priority, [_cacheDate timeIntervalSinceReferenceDate], _unitGroup.networkCacheTime, _placementModel.placementID];
}

-(void) renewAdWithPriority:(NSInteger)priority placementModel:(ATPlacementModel*)placementModel unitGroup:(ATUnitGroupModel*)unitGroup requestID:(NSString*)requestID {
    _priority = priority;
    _placementModel = placementModel;
    _unitGroup = unitGroup;
    _requestID = requestID;
}

-(BOOL) renewed {
    return ![_originalRequestID isEqualToString:_requestID];
}
@end
