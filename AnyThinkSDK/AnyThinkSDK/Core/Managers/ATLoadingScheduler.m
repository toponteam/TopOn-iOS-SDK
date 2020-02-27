//
//  ATLoadingScheduler.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 2019/3/6.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATLoadingScheduler.h"
#import "ATThreadSafeAccessor.h"
#import "ATPlacementModel.h"
#import "ATUnitGroupModel.h"
#import "ATAdManager+Internal.h"
#import "ATLogger.h"
#import "ATCapsManager.h"

NSString *const kATScheduledLoadFiredNotification = @"com.anythink.ScheduledLoadFired";
NSString *const kATScheduledLoadFiredNotificationUserInfoPlacementModel = @"placement_model";
NSString *const kATScheduledLoadFiredNotificationUserInfoUnitGroupModel = @"unit_group_model";
NSString *const kATScheduledLoadFiredNotificationUserInfoRequestID = @"request_id";
NSString *const kATScheduledLoadFiredNotificationUserInfoExtra = @"extra";

@interface ATScheduledLoading:NSObject
+(instancetype) scheduledLoadingWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel requestID:(NSString*)requestID extra:(NSDictionary*)extra;
-(void) cancel;
@property(nonatomic, readonly) ATPlacementModel *placementModel;
@property(nonatomic, readonly) ATUnitGroupModel *unitGroupModel;
@property(nonatomic, readonly) NSString *requestID;
@property(nonatomic, readonly) NSDictionary *extra;
@end

@interface ATLoadingScheduler()
@property(nonatomic, readonly) ATThreadSafeAccessor *dispatchInfoAccessor;
@property(nonatomic, readonly) NSMutableDictionary *dispatchInfo;
@end

static NSString *const kDispatchInfoPlacementModelKey = @"placement_model";
static NSString *const kDispatchInfoUnitGroupKey = @"dispatch_unit_group";
static NSString *const kDispatchInfoFireDateKey = @"fire_date";
static NSString *const kDispatchInfoLoadingObjectKey = @"loading_object";
static NSString *const kDispatchInfoRequestIDKey = @"request_id";
@implementation ATLoadingScheduler
+(instancetype)sharedScheduler {
    static ATLoadingScheduler *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATLoadingScheduler alloc] init];
    });
    return sharedManager;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _dispatchInfo = [NSMutableDictionary dictionary];
        _dispatchInfoAccessor = [ATThreadSafeAccessor new];
    }
    return self;
}

-(void) scheduleLoadingWithPlacementModel:(ATPlacementModel*)placementModel unitGroup:(ATUnitGroupModel*)unitGroupModel requestID:(NSString*)requestID extra:(NSDictionary*)extra{
    if (placementModel.format != ATAdFormatBanner && placementModel.format != ATAdFormatSplash && placementModel.autoloadingEnabled && unitGroupModel.networkCacheTime > -1) {
        __weak typeof(self) weakSelf = self;
        [_dispatchInfoAccessor writeWithBlock:^{
            BOOL shouldSchedule = NO;
            if (weakSelf.dispatchInfo[placementModel.placementID] != nil) {
                ATUnitGroupModel *scheduledUnitGroup = weakSelf.dispatchInfo[placementModel.placementID][kDispatchInfoUnitGroupKey];
                if ([placementModel.unitGroups indexOfObject:scheduledUnitGroup] >= [placementModel.unitGroups indexOfObject:unitGroupModel]) {
                    [ATLogger logMessage:@"ATLoadingScheduler::New incoming offer has a higher priority, will cancel previously scheduled loading & schedule a new one" type:ATLogTypeInternal];
                    [ATLogger logMessage:[NSString stringWithFormat:@"ATLoadingScheduler::Before cancelation:\ndispatch_info:%@", weakSelf.dispatchInfo] type:ATLogTypeInternal];
                    [weakSelf internal_cancelScheduleLoadingWithPlacementModel:placementModel unitGroup:unitGroupModel requestID:requestID];
                    [ATLogger logMessage:[NSString stringWithFormat:@"ATLoadingScheduler::After cancelation:\ndispatch_info:%@", weakSelf.dispatchInfo] type:ATLogTypeInternal];
                    shouldSchedule = YES;
                } else {
                    [ATLogger logMessage:@"ATLoadingScheduler::New incoming offer has a lower priority, no scheduling needed" type:ATLogTypeInternal];
                }
            } else {
                [ATLogger logMessage:@"ATLoadingScheduler::First offer in the placement, will schedule offer loading" type:ATLogTypeInternal];
                shouldSchedule = YES;
            }
            if (shouldSchedule) {
                [ATLogger logMessage:[NSString stringWithFormat:@"ATLoadingScheduler::Before Scheduling:\ndispatch_info:%@", weakSelf.dispatchInfo] type:ATLogTypeInternal];
                weakSelf.dispatchInfo[placementModel.placementID] = @{kDispatchInfoLoadingObjectKey:[ATScheduledLoading scheduledLoadingWithPlacementModel:placementModel unitGroupModel:unitGroupModel requestID:requestID extra:extra],
                                                                      kDispatchInfoPlacementModelKey:placementModel,
                                                                      kDispatchInfoUnitGroupKey:unitGroupModel,
                                                                      kDispatchInfoFireDateKey:[[NSDate date] dateByAddingTimeInterval:unitGroupModel.networkCacheTime],
                                                                      kDispatchInfoRequestIDKey:requestID
                                                                      };
                [ATLogger logMessage:[NSString stringWithFormat:@"ATLoadingScheduler::After Scheduling:\ndispatch_info:%@", weakSelf.dispatchInfo] type:ATLogTypeInternal];
            }
        }];
    }
}

-(void) cancelAllScheduledLoading {
    __weak typeof(self) weakSelf = self;
    [_dispatchInfoAccessor writeWithBlock:^{
        [weakSelf.dispatchInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [weakSelf internal_cancelScheduleLoadingWithPlacementModel:obj[kDispatchInfoPlacementModelKey] unitGroup:obj[kDispatchInfoUnitGroupKey] requestID:obj[kDispatchInfoRequestIDKey]];
        }];
        [weakSelf.dispatchInfo removeAllObjects];
    }];
}

-(void) cancelScheduleLoadingWithPlacementModel:(ATPlacementModel*)placementModel unitGroup:(ATUnitGroupModel*)unitGroupModel requestID:(NSString*)requestID {
    if (placementModel != nil && unitGroupModel != nil) {
        __weak typeof(self) weakSelf = self;
        [_dispatchInfoAccessor writeWithBlock:^{
            [weakSelf internal_cancelScheduleLoadingWithPlacementModel:placementModel unitGroup:unitGroupModel requestID:requestID];
        }];
    }
}

-(void) internal_cancelScheduleLoadingWithPlacementModel:(ATPlacementModel*)placementModel unitGroup:(ATUnitGroupModel*)unitGroupModel requestID:(NSString*)requestID {
    if (placementModel.placementID != nil) {
        [ATLogger logMessage:@"ATLoadingScheduler::Cancelation" type:ATLogTypeInternal];
        [(ATScheduledLoading*)(_dispatchInfo[placementModel.placementID][kDispatchInfoLoadingObjectKey]) cancel];
        [ATLogger logMessage:[NSString stringWithFormat:@"ATLoadingScheduler::Before remove dispatch info:\n%@", _dispatchInfo] type:ATLogTypeInternal];
        [_dispatchInfo removeObjectForKey:placementModel.placementID];
        [ATLogger logMessage:[NSString stringWithFormat:@"ATLoadingScheduler::After remove dispatch info:\n%@", _dispatchInfo] type:ATLogTypeInternal];
    }
}
@end

@implementation ATScheduledLoading
+(instancetype) scheduledLoadingWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel requestID:(NSString*)requestID extra:(NSDictionary*)extra {
    return [[ATScheduledLoading alloc] initWithPlacementModel:placementModel unitGroupModel:unitGroupModel requestID:requestID extra:extra];
}

-(instancetype) initWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel requestID:(NSString*)requestID extra:(NSDictionary*)extra {
    self = [super init];
    if (self != nil) {
        _placementModel = placementModel;
        _unitGroupModel = unitGroupModel;
        _requestID = requestID;
        _extra = extra;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(fire) withObject:nil afterDelay:unitGroupModel.networkCacheTime / 1000.0f];
        });
        
        [ATLogger logMessage:[NSString stringWithFormat:@"Scheduling load with info:%@", @{@"network_firm_id":@(_unitGroupModel.networkFirmID), @"unit_group_id":_unitGroupModel.unitGroupID, @"unit_group_ids":[_placementModel mutableArrayValueForKeyPath:@"unitGroups.unitGroupID"] != nil ? [_placementModel mutableArrayValueForKeyPath:@"unitGroups.unitGroupID"] : @[]}] type:ATLogTypeInternal];
    }
    return self;
}

-(void) cancel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fire) object:nil];
    });
}

-(void) fire {
    [ATLogger logMessage:[NSString stringWithFormat:@"Scheduled load fired with info:%@", @{@"network_firm_id":@(_unitGroupModel.networkFirmID), @"unit_group_id":_unitGroupModel.unitGroupID, @"unit_group_ids":[_placementModel mutableArrayValueForKeyPath:@"unitGroups.unitGroupID"] != nil ? [_placementModel mutableArrayValueForKeyPath:@"unitGroups.unitGroupID"] : @[]}] type:ATLogTypeInternal];
    [[ATLoadingScheduler sharedScheduler] cancelScheduleLoadingWithPlacementModel:_placementModel unitGroup:_unitGroupModel requestID:_requestID];
    [[ATAdManager sharedManager] clearCacheWithPlacementModel:_placementModel unitGroupModel:_unitGroupModel];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATScheduledLoadFiredNotification object:nil userInfo:@{kATScheduledLoadFiredNotificationUserInfoExtra:_extra != nil ? _extra : @{}, kATScheduledLoadFiredNotificationUserInfoRequestID:_requestID != nil ? _requestID : @"", kATScheduledLoadFiredNotificationUserInfoPlacementModel:_placementModel, kATScheduledLoadFiredNotificationUserInfoUnitGroupModel:_unitGroupModel}];
}
@end
