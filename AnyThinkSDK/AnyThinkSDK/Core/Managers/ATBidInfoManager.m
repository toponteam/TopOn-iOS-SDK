//
//  ATBidInfoManager.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 2020/4/28.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATBidInfoManager.h"
#import "ATThreadSafeAccessor.h"
#import "ATUnitGroupModel.h"
@interface ATBidInfoManager()
@property(nonatomic, readonly) NSMutableDictionary *info;
@property(nonatomic, readonly) ATThreadSafeAccessor *infoAccessor;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSString*>* requestIDStorage;
@property(nonatomic, readonly) ATThreadSafeAccessor *requestIDStorageAccessor;
@end
@implementation ATBidInfoManager
+(instancetype) sharedManager {
    static ATBidInfoManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATBidInfoManager alloc] init];
    });
    return sharedManager;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _info = [NSMutableDictionary dictionary];
        _infoAccessor = [ATThreadSafeAccessor new];
        
        _requestIDStorage = [NSMutableDictionary<NSString*, NSString*> dictionary];
        _requestIDStorageAccessor = [ATThreadSafeAccessor new];
    }
    return self;
}

-(void) saveRequestID:(NSString*)requestID forPlacementID:(NSString*)placementID {
    __weak typeof(self) weakSelf = self;
    [_requestIDStorageAccessor writeWithBlock:^{ weakSelf.requestIDStorage[placementID] = requestID; }];
}

-(NSString*)requestForPlacementID:(NSString*)placementID {
    __weak typeof(self) weakSelf = self;
    return [_requestIDStorageAccessor readWithBlock:^id{ return weakSelf.requestIDStorage[placementID]; }];
}

-(void) renewBidInfoForPlacementID:(NSString*)placementID fromRequestID:(NSString*)requestID toRequestID:(NSString*)newRequestID unitGroups:(NSArray<ATUnitGroupModel*>*)unitGroups {
    __weak typeof(self) weakSelf = self;
    [_infoAccessor writeWithBlock:^{
        NSDictionary<NSString*, ATBidInfo*>* requestIDEntry = weakSelf.info[placementID][requestID];
        [unitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ATBidInfo *bidInfo = requestIDEntry[obj.unitID];
            if (bidInfo != nil) { [weakSelf thread_unsafe_saveBidInfo:bidInfo forRequestID:newRequestID]; }
        }];
    }];
}

-(void) saveBidInfo:(ATBidInfo*)bidInfo forRequestID:(NSString*)requestID {
    __weak typeof(self) weakSelf = self;
    [_infoAccessor writeWithBlock:^{ [weakSelf thread_unsafe_saveBidInfo:bidInfo forRequestID:requestID]; }];
}

-(void) thread_unsafe_saveBidInfo:(ATBidInfo*)bidInfo forRequestID:(NSString*)requestID {
    NSString *placementID = bidInfo.placementID;
    NSMutableDictionary *placementEntry = _info[placementID];
    NSMutableDictionary *requestIDIntry = placementEntry[requestID];
    if (placementEntry == nil) {
        placementEntry = [NSMutableDictionary dictionary];
        requestIDIntry = [NSMutableDictionary dictionary];
        placementEntry[requestID] = requestIDIntry;
        _info[placementID] = placementEntry;
    } else {
        if (requestIDIntry == nil) {
            requestIDIntry = [NSMutableDictionary dictionary];
            placementEntry[requestID] = requestIDIntry;
        }
    }
    requestIDIntry[bidInfo.unitGroupUnitID] = bidInfo;
}

/**
{
    placement_id:{
        request_id:{
            unit_id:bidInfo
        }
    }
}
*/
-(NSArray<ATUnitGroupModel*>*) unitGroupWithHistoryBidInfoAvailableForPlacementID:(NSString*)placementID unitGroups:(NSArray<ATUnitGroupModel*>*)unitGroupsToInspect newRequestID:(NSString*)newRequestID {
    NSMutableArray<ATUnitGroupModel*>* unitGroups = [NSMutableArray<ATUnitGroupModel*> array];
    __weak typeof(self) weakSelf = self;
    [_infoAccessor readWithBlock:^id{
        NSMutableArray<ATBidInfo*>* bidInfoToResave = [NSMutableArray<ATBidInfo*> array];
        NSDictionary<NSString*, NSMutableDictionary<NSString*, ATBidInfo*>*>* placementEntry = weakSelf.info[placementID];
        [placementEntry enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableDictionary<NSString*, ATBidInfo*> * _Nonnull reqIDEntry, BOOL * _Nonnull midStop) {
            NSMutableArray<NSString*>* keysToRemove = [NSMutableArray<NSString*> array];
            [unitGroupsToInspect enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull ug, NSUInteger idx, BOOL * _Nonnull stop) {
                if (reqIDEntry[ug.unitID].isValid) {
                    [unitGroups addObject:ug];
                    [bidInfoToResave addObject:reqIDEntry[ug.unitID]];
                    [keysToRemove addObject:ug.unitID];
                }
            }];
            [reqIDEntry removeObjectsForKeys:keysToRemove];
        }];
        [bidInfoToResave enumerateObjectsUsingBlock:^(ATBidInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { [weakSelf thread_unsafe_saveBidInfo:obj forRequestID:newRequestID]; }];
        return nil;
    }];
    return unitGroups;
}

-(void) invalidateBidInfoForPlacementID:(NSString*)placementID unitGroupModel:(ATUnitGroupModel*)unitGroupModel requestID:(NSString*)requestID {
    __weak typeof(self) weakSelf = self;
    [_infoAccessor writeWithBlock:^{
        ATBidInfo *info = weakSelf.info[placementID][requestID][unitGroupModel.unitID];
        [info invalidate];
    }];
}

-(ATBidInfo*) bidInfoForPlacementID:(NSString*)placementID unitGroupModel:(ATUnitGroupModel*)unitGroupModel requestID:(NSString*)requestID {
    __weak typeof(self) weakSelf = self;
    return [_infoAccessor readWithBlock:^id{ return weakSelf.info[placementID][requestID][unitGroupModel.unitID]; }];
}

+(double) priceForUnitGroup:(ATUnitGroupModel*)unitGroupModel placementID:(NSString*)placementID requestID:(NSString*)requestID {
    return unitGroupModel.headerBidding ? [[ATBidInfoManager sharedManager] bidInfoForPlacementID:placementID unitGroupModel:unitGroupModel requestID:requestID].price : unitGroupModel.price;
}
@end
