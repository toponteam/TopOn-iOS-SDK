//
//  ATBidTrackingModel.m
//  AnyThinkSDK
//
//  Created by stephen on 17/9/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATBidTrackingModel.h"

@implementation ATBidTrackingModel

-(instancetype) initBidTrackingModelWithRequestID:(NSString*)requestID offerCachedHBUGs:(NSArray<ATUnitGroupModel*>*)offerCachedHBUGs unitGroupsWithHistoryBidInfo:(NSArray<ATUnitGroupModel*>*)unitGroupsWithHistoryBidInfo inactiveUGInfo:(NSArray<NSDictionary*>*)inactiveUGInfo inactiveHBUGInfo:(NSArray<NSDictionary*>*)inactiveHBUGInfo extra:(NSDictionary*)extra  bidStartDate:(NSDate*)bidStartDate {
    self = [super init];
    if (self != nil) {
        _requestID = requestID;
        _offerCachedHBUGs = offerCachedHBUGs;
        _unitGroupsWithHistoryBidInfo = unitGroupsWithHistoryBidInfo;
        _inactiveUGInfo = inactiveUGInfo;
        _inactiveHBUGInfo = inactiveHBUGInfo;
        _extra = extra;
        _bidStartDate = bidStartDate;
    }
    return self;
}

@end
