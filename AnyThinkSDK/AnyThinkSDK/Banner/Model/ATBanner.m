//
//  ATBanner.m
//  AnyThinkBanner
//
//  Created by Martin Lau on 18/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATBanner.h"
#import "ATUnitGroupModel.h"
#import "ATPlacementModel.h"
#import "Utilities.h"
#import "ATBannerManager.h"
#import "ATBannerCustomEvent.h"
#import "ATAdManager+Internal.h"

@interface ATBanner()

@end
@implementation ATBanner
-(instancetype) initWithPriority:(NSInteger) priority placementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID assets:(NSDictionary*)assets unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall *)finalWaterfall {
    self = [super init];
    if (self != nil) {
        _priority = priority;
        _placementModel = placementModel;
        _requestID = requestID;
        _originalRequestID = requestID;
        _unitID = assets[kBannerAssetsUnitIDKey];
        _unitGroup = unitGroup;
        _cacheDate = [NSDate normalizaedDate];
        _expireDate = [[NSDate date] dateByAddingTimeInterval:_unitGroup.networkCacheTime / 1000.0f];
        _showTimes = 0;
        _bannerView = assets[kBannerAssetsBannerViewKey];
        _customEvent = assets[kBannerAssetsCustomEventKey];
        _customEvent.ad = self;
        _customEvent.banner = self;
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
    _priority = priority;
    _placementModel = placementModel;
    _unitGroup = unitGroup;
    _requestID = requestID;
}

-(BOOL) renewed {
    return ![_originalRequestID isEqualToString:_requestID];
}

-(BOOL) ready {
    return YES;
}

-(BOOL) fillByAutorefresh {
    return [_customEvent.localInfo[kAdLoadingExtraRefreshFlagKey] boolValue];
}

-(void) dealloc {
    [_customEvent cleanup];
    _customEvent = nil;
    [ATLogger logMessage:@"ATBanner dealloc(Added for testing memory issues)." type:ATLogTypeInternal];
}

-(NSString*)description {
    return [NSString stringWithFormat:@"priority = %ld, placementID = %@, requestID = %@, unitGroupID = %@", _priority, _placementModel.placementID, _requestID, _unitGroup.unitGroupID];
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
