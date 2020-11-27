//
//  ATBidJobModel.h
//  AnyThinkSDK
//
//  Created by stephen on 17/9/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATModel.h"
#import "ATUnitGroupModel.h"
#import "ATPlacementModel.h"

@interface ATBidJobModel : ATModel
@property(nonatomic, readonly) NSString *requestID;
@property(nonatomic, readonly) NSArray<ATUnitGroupModel*> *headerBiddingUnitGroups;
@property(nonatomic, readonly) NSArray<ATUnitGroupModel*> *s2sHBUnitGroups;
@property(nonatomic, readonly) ATPlacementModel *placementModel;

-(instancetype) initBidJobModelWithRequestID:(NSString*)requestID headerBiddingUnitGroups:(NSArray<ATUnitGroupModel*>*)headerBiddingUnitGroups s2sHBUnitGroups:(NSArray<ATUnitGroupModel*>*)s2sHBUnitGroups placementModel:(ATPlacementModel*)placementModel;

@end
