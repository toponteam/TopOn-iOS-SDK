//
//  ATSplash.h
//  AnyThinkSplash
//
//  Created by Martin Lau on 2018/12/20.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATAd.h"
@class ATPlacementModel, ATUnitGroupModel, ATSplashCustomEvent;

@interface ATSplash : NSObject<ATAd>
-(instancetype) initWithPriority:(NSInteger) priority placementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID assets:(NSDictionary*)assets unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall *)finalWaterfall;
@property(nonatomic) NSInteger showTimes;
/**
 Priority is calculate by the index of the unit group in the placement's unit group list; zero is the highest
 */
@property(nonatomic, readonly) NSInteger priority;
@property(nonatomic, readonly) NSInteger priorityLevel;
@property(nonatomic, readonly) ATPlacementModel *placementModel;
@property(nonatomic, readonly) NSString *requestID;
@property(nonatomic, readonly) NSString *originalRequestID;
@property(nonatomic, readonly) NSDate *expireDate;
@property(nonatomic, readonly) NSDate *cacheDate;
@property(nonatomic, readonly) ATUnitGroupModel *unitGroup;
@property(nonatomic, readonly) NSString *unitID;
@property(nonatomic, readonly) id customObject;
@property(nonatomic, readonly) ATSplashCustomEvent *customEvent;
@property(nonatomic, readonly) NSString *price;
@property(nonatomic, readonly, weak) ATWaterfall *finalWaterfall;
@property(nonatomic, readonly) NSInteger autoReqType;
@end
