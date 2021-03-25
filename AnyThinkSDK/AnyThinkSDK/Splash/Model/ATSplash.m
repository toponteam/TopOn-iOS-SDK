//
//  ATSplash.m
//  AnyThinkSplash
//
//  Created by Martin Lau on 2018/12/20.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATSplash.h"
#import "ATPlacementModel.h"
#import "ATUnitGroupModel.h"
#import "Utilities.h"
#import "ATSplashManager.h"
#import "ATSplashCustomEvent.h"
@implementation ATSplash
-(instancetype) initWithPriority:(NSInteger) priority placementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID assets:(NSDictionary*)assets unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall *)finalWaterfall {
    self = [super init];
    if (self != nil) {
        _priority = priority;
        _placementModel = placementModel;
        _requestID = requestID;
        _originalRequestID = requestID;
        _unitID = assets[kAdAssetsUnitIDKey];
        _unitGroup = unitGroup;
        _cacheDate = [NSDate normalizaedDate];
        _expireDate = [[NSDate date] dateByAddingTimeInterval:_unitGroup.networkCacheTime / 1000.0f];
        _showTimes = 0;
        _customEvent = assets[kAdAssetsCustomEventKey];
        _customEvent.ad = self;
        _customObject = assets[kAdAssetsCustomObjectKey];
        _priorityLevel = _placementModel.maxConcurrentRequestCount > 0 ? ([ATAdCustomEvent calculateAdPriority:self] / _placementModel.maxConcurrentRequestCount) + 1 : 1;
        
        NSString *bidPrice = assets[kAdAssetsPriceKey];
        _price = unitGroup.headerBidding ? bidPrice : unitGroup.price;
        
        _bidId = unitGroup.headerBidding ? assets[kAdAssetsBidIDKey] : @"";
        _finalWaterfall = finalWaterfall;
        if ([assets[kATTrackerExtraRequestExpectedOfferNumberFlagKey] boolValue]) { _autoReqType = 5; }
    }
    return self;
}

-(void) renewAdWithPriority:(NSInteger)priority placementModel:(ATPlacementModel *)placementModel unitGroup:(ATUnitGroupModel *)unitGroup requestID:(NSString *)requestID {
    
}

-(BOOL) renewed {
    return ![_originalRequestID isEqualToString:_requestID];
}

-(BOOL) ready {
    return YES;
}

- (NSString *)ecpm {
    if (self.unitGroup.headerBidding) {
        NSDecimalNumber *priceDecimal = [NSDecimalNumber decimalNumberWithString:self.price];
        NSDecimalNumber *rateDecimal = [NSDecimalNumber decimalNumberWithString:self.placementModel.exchangeRate];
        return [[priceDecimal decimalNumberByMultiplyingBy:rateDecimal] stringValue];
    }
    return self.unitGroup.ecpmByCurrency;
}
@end
