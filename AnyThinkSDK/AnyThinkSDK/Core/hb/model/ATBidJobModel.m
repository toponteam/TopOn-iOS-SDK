//
//  ATBidJobModel.m
//  AnyThinkSDK
//
//  Created by stephen on 17/9/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATBidJobModel.h"

@implementation ATBidJobModel

-(instancetype) initBidJobModelWithRequestID:(NSString*)requestID headerBiddingUnitGroups:(NSArray<ATUnitGroupModel*>*)headerBiddingUnitGroups s2sHBUnitGroups:(NSArray<ATUnitGroupModel*>*)s2sHBUnitGroups placementModel:(ATPlacementModel*)placementModel {
    self = [super init];
    if (self != nil) {
        _requestID = requestID;
        _headerBiddingUnitGroups = headerBiddingUnitGroups;
        _s2sHBUnitGroups = s2sHBUnitGroups;
        _placementModel = placementModel;
    }
    return self;
}

@end
