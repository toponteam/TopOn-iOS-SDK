//
//  ATLoadingScheduler.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 2019/3/6.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ATPlacementModel;
@class ATUnitGroupModel;

extern NSString *const kATScheduledLoadFiredNotification;
extern NSString *const kATScheduledLoadFiredNotificationUserInfoPlacementModel;
extern NSString *const kATScheduledLoadFiredNotificationUserInfoUnitGroupModel;
extern NSString *const kATScheduledLoadFiredNotificationUserInfoRequestID;
extern NSString *const kATScheduledLoadFiredNotificationUserInfoExtra;
@interface ATLoadingScheduler : NSObject
+(instancetype)sharedScheduler;
-(void) scheduleLoadingWithPlacementModel:(ATPlacementModel*)placementModel unitGroup:(ATUnitGroupModel*)unitGroupModel requestID:(NSString*)requestID extra:(NSDictionary*)extra;
-(void) cancelScheduleLoadingWithPlacementModel:(ATPlacementModel*)placementModel unitGroup:(ATUnitGroupModel*)unitGroupModel requestID:(NSString*)requestID;
-(void) cancelAllScheduledLoading;
@end
