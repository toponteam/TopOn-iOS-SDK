//
//  ATBidTrackingModel.h
//  AnyThinkSDK
//
//  Created by stephen on 17/9/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATModel.h"
#import "ATUnitGroupModel.h"

@interface ATBidTrackingModel : ATModel
@property(nonatomic, readonly) NSString *requestID;
@property(nonatomic, readonly) NSArray<ATUnitGroupModel*> *offerCachedHBUGs;
@property(nonatomic, readonly) NSArray<ATUnitGroupModel*> *unitGroupsWithHistoryBidInfo;
@property(nonatomic, readonly) NSArray<NSDictionary*> *inactiveUGInfo;
@property(nonatomic, readonly) NSArray<NSDictionary*> *inactiveHBUGInfo;
@property(nonatomic, readonly) NSDictionary *extra;
@property(nonatomic, readonly) NSDate *bidStartDate;


-(instancetype) initBidTrackingModelWithRequestID:(NSString*)requestID offerCachedHBUGs:(NSArray<ATUnitGroupModel*>*)offerCachedHBUGs unitGroupsWithHistoryBidInfo:(NSArray<ATUnitGroupModel*>*)unitGroupsWithHistoryBidInfo inactiveUGInfo:(NSArray<NSDictionary*>*)inactiveUGInfo inactiveHBUGInfo:(NSArray<NSDictionary*>*)inactiveHBUGInfo extra:(NSDictionary*)extra  bidStartDate:(NSDate*)bidStartDate;

@end
