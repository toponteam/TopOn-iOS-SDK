//
//  ATWaterfallManager.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 2020/4/28.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATWaterfallManager.h"
#import "ATPlacementSettingManager.h"
#import "ATUnitGroupModel.h"
#import "ATBidInfoManager.h"
#import "ATThreadSafeAccessor.h"
#import "ATCapsManager.h"
#import "ATAdStorageUtility.h"
#pragma mark - waterfall
@interface ATWaterfall()
@property(nonatomic, readonly) NSString *placementID;
@property(nonatomic, readonly) NSString *requestID;
@property(nonatomic, readonly) NSMutableArray<ATUnitGroupModel*>* finishedUnitGroups;
@property(nonatomic, readonly) NSMutableArray<ATUnitGroupModel*>* timeoutUnitGroups;
@property(nonatomic, readonly) NSMutableArray<ATUnitGroupModel*>* requestSentUnitGroups;
@property(nonatomic, readonly) NSMutableArray<ATUnitGroupModel*>* requestFilledUnitGroups;
@end

@implementation ATWaterfall
-(instancetype) initWithUnitGroups:(NSArray<ATUnitGroupModel*>*)unitGroups placementID:(NSString*)placementID requestID:(NSString*)requestID {
    self = [super init];
    if (self != nil) {
        _requestID = requestID;
        _placementID = placementID;
        _unitGroups = [NSMutableArray<ATUnitGroupModel*> array];
        if ([unitGroups count] > 0) { [_unitGroups addObjectsFromArray:unitGroups]; }
        _finishedUnitGroups = [NSMutableArray<ATUnitGroupModel*> array];
        _requestSentUnitGroups = [NSMutableArray<ATUnitGroupModel*> array];
        _timeoutUnitGroups = [NSMutableArray<ATUnitGroupModel*> array];
        _requestFilledUnitGroups = [NSMutableArray<ATUnitGroupModel*> array];
    }
    return self;
}

-(BOOL)canContinueLoading:(BOOL)waitForSentRequests {
    return [_unitGroups count] > 0 && (waitForSentRequests ? ([_requestSentUnitGroups count] == ([_finishedUnitGroups count] + [_timeoutUnitGroups count])) : YES) && [_requestSentUnitGroups count] < [_unitGroups count];
}

-(BOOL) isLoading {
    return [_requestSentUnitGroups count] > ([_finishedUnitGroups count] + [_timeoutUnitGroups count]);
}

-(void) requestUnitGroup:(ATUnitGroupModel*)unitGroup {
    [_requestSentUnitGroups addObject:unitGroup];
}

-(NSUInteger) numberOfTimeoutRequests {
    return [_timeoutUnitGroups count];
}

-(ATUnitGroupModel*) firstPendingNonHBUnitGroupWithNetworkFirmID:(NSInteger)nwFirmID{
    __block ATUnitGroupModel *ug = nil;
    
    __block BOOL defaultNetworkLoaded = NO;
    [_finishedUnitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { defaultNetworkLoaded = *stop = !obj.headerBidding && obj.networkFirmID == nwFirmID; }];
    
    if (!defaultNetworkLoaded) {
        NSMutableArray<ATUnitGroupModel*>* ugs = [NSMutableArray<ATUnitGroupModel*> arrayWithArray:_unitGroups];
        [ugs removeObjectsInArray:_finishedUnitGroups];
        [ugs enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!obj.headerBidding && obj.networkFirmID == nwFirmID) {
                ug = obj;
                *stop = YES;
            }
        }];
    }
    return ug;
}

-(void) finishUnitGroup:(ATUnitGroupModel*)unitGroup withType:(ATUnitGroupFinishType)type {
    if (type == ATUnitGroupFinishTypeTimeout) {
        [_timeoutUnitGroups addObject:unitGroup];
    } else {
        [_timeoutUnitGroups removeObject:unitGroup];
        [_finishedUnitGroups addObject:unitGroup];
        if (type == ATUnitGroupFinishTypeFinished) { [_requestFilledUnitGroups addObject:unitGroup]; }
    }
}

-(void) addUnitGroup:(ATUnitGroupModel*)unitGroup {
    if (unitGroup != nil) { [_unitGroups addObject:unitGroup]; }
}

-(void) insertUnitGroups:(NSArray<ATUnitGroupModel*>*)unitGrous {
    [unitGrous enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { [self insertUnitGroup:obj price:obj.price]; }];
}

-(void) removeUnitGroupWithUnitID:(NSString*)unitID {
    void(^RemoveUnitGroup)(NSMutableArray<ATUnitGroupModel*>* unitGroups, NSString *unitID) = ^(NSMutableArray<ATUnitGroupModel*>* unitGroups, NSString *unitID) {
        NSMutableArray<NSString*>* unitIDs = [NSMutableArray<NSString*> array];
        [unitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { [unitIDs addObject:obj.unitID]; }];
        NSUInteger indexToRemove = [unitIDs indexOfObject:unitID];
        if (indexToRemove != NSNotFound) { [unitGroups removeObjectAtIndex:indexToRemove]; }
    };
    
    RemoveUnitGroup(_unitGroups, unitID);
    RemoveUnitGroup(_finishedUnitGroups, unitID);
    RemoveUnitGroup(_requestSentUnitGroups, unitID);
    RemoveUnitGroup(_requestFilledUnitGroups, unitID);
    RemoveUnitGroup(_timeoutUnitGroups, unitID);
}

-(void) insertUnitGroup:(ATUnitGroupModel*)unitGroup price:(double)price {
    __block NSUInteger indexToInsert = [_unitGroups count];
    [_unitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (price > [ATBidInfoManager priceForUnitGroup:obj placementID:_placementID requestID:_requestID]) {
            indexToInsert = idx;
            *stop = YES;
        }
    }];
    [_unitGroups insertObject:unitGroup atIndex:indexToInsert];
}

-(ATUnitGroupModel*)unitGroupWithMaximumPrice {
    NSMutableArray<ATUnitGroupModel*> *unitGroups = [NSMutableArray<ATUnitGroupModel*> arrayWithArray:_unitGroups];
    [unitGroups removeObjectsInArray:_requestSentUnitGroups];
    __block ATUnitGroupModel *unitGroup = [unitGroups firstObject];
    [unitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { if ([ATBidInfoManager priceForUnitGroup:obj placementID:_placementID requestID:_requestID] > [ATBidInfoManager priceForUnitGroup:unitGroup placementID:_placementID requestID:_requestID]) { unitGroup = obj; } }];
    return unitGroup;
}

-(ATUnitGroupModel*) unitGroupWithUnitID:(NSString*)unitID {
    __block ATUnitGroupModel *unitGroup = nil;
    if ([unitID isKindOfClass:[NSString class]]) {
        [_unitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.unitID isEqualToString:unitID]) {
                unitGroup = obj;
                *stop = YES;
            }
        }];
    }
    return unitGroup;
}

-(ATUnitGroupModel*)unitGroupWithMinimumPrice {
    __block ATUnitGroupModel *minimumUG = [_requestSentUnitGroups firstObject];
    [_requestSentUnitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { if ([ATBidInfoManager priceForUnitGroup:obj placementID:_placementID requestID:_requestID] < [ATBidInfoManager priceForUnitGroup:minimumUG placementID:_placementID requestID:_requestID]) { minimumUG = obj; } }];
    return minimumUG;
}

-(void) enumerateTimeoutUnitGroupWithBlock:(void(^)(ATUnitGroupModel*unitGroup))block {
    [_timeoutUnitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { block(obj); }];
}
@end

#pragma mark - waterfall wrapper
@interface ATWaterfallWrapper()
+(instancetype) wrapperWithPlacementID:(NSString*)placementID requestID:(NSString*)requestID;
@property(nonatomic, readonly) dispatch_queue_t access_queue;
@property(nonatomic, readonly) ATWaterfall *waterfall;
@property(nonatomic, readonly) ATWaterfall *headerBiddingWaterfall;
@property(nonatomic, readonly) ATWaterfall *finalWaterfall;
@property(nonatomic, readonly) BOOL finished;
@property(nonatomic, readonly) NSDate *startDate;
@property(nonatomic, readonly) NSString *placementID;
@property(nonatomic, readonly) NSString *requestID;
@end
@implementation ATWaterfallWrapper
+(instancetype) wrapperWithPlacementID:(NSString*)placementID requestID:(NSString*)requestID {
    return [[ATWaterfallWrapper alloc] initWithPlacementID:placementID requestID:requestID];
}

-(instancetype) initWithPlacementID:(NSString*)placementID requestID:(NSString*)requestID {
    self = [super init];
    if (self != nil) {
        _startDate = [NSDate date];
        _placementID = placementID;
        _requestID = requestID;
        _access_queue = dispatch_queue_create("com.anythink.WaterfallWrapper", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

-(void) fill {
    _filled = YES;
}

-(void) installWaterfall:(ATWaterfall*)waterfallToInstall {
    _waterfall = waterfallToInstall;
    _finalWaterfall = [[ATWaterfall alloc] initWithUnitGroups:_waterfall.unitGroups placementID:_waterfall.placementID requestID:_waterfall.requestID];
    _headerBiddingWaterfall = [[ATWaterfall alloc] initWithUnitGroups:nil placementID:waterfallToInstall.placementID requestID:waterfallToInstall.requestID];
}

-(ATUnitGroupModel*) filledUnitGroupWithMaximumPrice {
    NSMutableArray<ATUnitGroupModel*>* finishedUGs = [NSMutableArray<ATUnitGroupModel*> array];
    [finishedUGs addObjectsFromArray:_waterfall.requestFilledUnitGroups];
    [finishedUGs addObjectsFromArray:_headerBiddingWaterfall.requestFilledUnitGroups];
    
    NSArray<NSString*>* shownUGIDs = [[ATCapsManager sharedManager] showRecordsForPlacementID:_placementID requestID:_requestID];
    __block ATUnitGroupModel *maxUG = [finishedUGs firstObject];
    [finishedUGs enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { if (![shownUGIDs containsObject:obj.unitID] && [ATBidInfoManager priceForUnitGroup:obj placementID:_placementID requestID:_requestID] > [ATBidInfoManager priceForUnitGroup:maxUG placementID:_placementID requestID:_requestID]) { maxUG = obj; } }];
    return maxUG;
}

-(void) finish {
    _finished = YES;
}
@end

#pragma mark - array op
@interface NSMutableArray(AnyThinkKit)
-(NSMutableArray*) arrayBySubstractingObjectsFromArray:(NSArray*)objectsToSub;
@end
@implementation NSMutableArray (AnyThinkKit)
-(NSMutableArray*) arrayBySubstractingObjectsFromArray:(NSArray*)objectsToSub {
    NSMutableArray *array = [self mutableCopy];
    if ([objectsToSub count] > 0) { [array removeObjectsInArray:objectsToSub]; }
    
    return array;
}
@end

#pragma mark - manager
@interface ATWaterfallManager()
@property(nonatomic, readonly) ATThreadSafeAccessor *waterfallWrappersAccessor;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSMutableDictionary<NSString*, ATWaterfallWrapper*>*> *waterfallWrappers;
@end
@implementation ATWaterfallManager
+(instancetype) sharedManager {
    static ATWaterfallManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATWaterfallManager alloc] init];
    });
    return sharedManager;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _waterfallWrappersAccessor = [ATThreadSafeAccessor new];
        _waterfallWrappers = [NSMutableDictionary<NSString*, NSMutableDictionary<NSString*, ATWaterfallWrapper*>*> dictionary];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePlacementModelUpdateNotification:) name:kATPlacementManagerPlacementUpdateNotification object:nil];
    }
    return self;
}

-(void) handlePlacementModelUpdateNotification:(NSNotification*)notification {
    ATPlacementModel *placementModel = notification.userInfo[kATPlacementManagerPlacementUpdateNotificationUserInfoPlacementModelKey];
    [[ATWaterfallManager sharedManager] updateWaterfallForPlacementModel:placementModel];
}

-(void) updateWaterfallForPlacementModel:(ATPlacementModel*)placementModel {
    __weak typeof(self) weakSelf = self;
    [_waterfallWrappersAccessor readWithBlock:^id{
        NSDictionary<NSString*, ATWaterfallWrapper*> *placementEntry = weakSelf.waterfallWrappers[placementModel.placementID];
        [placementEntry enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, ATWaterfallWrapper * _Nonnull obj, BOOL * _Nonnull stop) {
            __weak ATWaterfallWrapper *wrapper = obj;
            dispatch_async(wrapper.access_queue, ^{
                NSMutableArray<NSString*>* unitIDs = [NSMutableArray<NSString*> array];
                [wrapper.finalWaterfall.unitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { [unitIDs addObject:obj.unitID]; }];
                
                NSMutableArray<NSString*>* hbUnitIDs = [NSMutableArray<NSString*> array];
                [placementModel.S2SHeaderBiddingUnitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { [hbUnitIDs addObject:obj.unitID]; }];
                
                /**
                 Remove hb_adsource that no long exist in hb_list
                 Revove all history ug_list ad source
                 Add all ug_list adsource back
                 */
                NSMutableArray<NSString*>* objectsToRemove = [NSMutableArray<NSString*> array];
                [unitIDs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    ATUnitGroupModel *ug = wrapper.finalWaterfall.unitGroups[idx];
                    if (ug.headerBidding) {//hb_list
                        if (![hbUnitIDs containsObject:obj]) { [objectsToRemove addObject:obj]; }
                    } else {//ug_list
                        [objectsToRemove addObject:obj];
                    }
                }];
                [objectsToRemove enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { [wrapper.finalWaterfall removeUnitGroupWithUnitID:obj]; }];
                
                [wrapper.finalWaterfall insertUnitGroups:placementModel.unitGroups];
            });
        }];
        return nil;
    }];
}

/*
 {
 placement_id: {
 request_id: waterfall_wrapper
 }
 */
-(void) accessWaterfallForPlacementID:(NSString*)placementID requestID:(NSString*)requestID withBlock:(void(^)(ATWaterfallWrapper *waterfallWrapper, ATWaterfall *waterfall, ATWaterfall *headerBiddingWaterfall, ATWaterfall *finalWaterfall, BOOL finished, NSDate *loadStartDate))block {
    __weak typeof(self) weakSelf = self;
    [_waterfallWrappersAccessor readWithBlock:^id{
        __weak ATWaterfallWrapper *wrapper = weakSelf.waterfallWrappers[placementID][requestID];
        if (wrapper != nil) { dispatch_async(wrapper.access_queue, ^{ block(wrapper, wrapper.waterfall, wrapper.headerBiddingWaterfall, wrapper.finalWaterfall, wrapper.finished, wrapper.startDate); }); }
        return nil;
    }];
}

-(BOOL) loadingAdForPlacementID:(NSString*)placementID {
    __weak typeof(self) weakSelf = self;
    return [[_waterfallWrappersAccessor readWithBlock:^id{
        __block BOOL loading = NO;
        NSDictionary<NSString*, ATWaterfallWrapper*> *placementEntry = weakSelf.waterfallWrappers[placementID];
        [placementEntry enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, ATWaterfallWrapper * _Nonnull obj, BOOL * _Nonnull stop) { loading = *stop = (!obj.finished && obj.waterfall.numberOfTimeoutRequests == 0 && obj.headerBiddingWaterfall.numberOfTimeoutRequests == 0); }];
        return @(loading);
    }] boolValue];
}

-(void) attachWaterfall:(ATWaterfall*)waterfall completion:(void(^)(ATWaterfallWrapper *waterfallWrapper, ATWaterfall *waterfall, ATWaterfall *headerBiddingWaterfall, ATWaterfall *finalWaterfall, BOOL finished, NSDate *loadStartDate))completion {
    __weak typeof(self) weakSelf = self;
    [_waterfallWrappersAccessor writeWithBlock:^{
        NSMutableDictionary<NSString*, ATWaterfallWrapper*>* placementEntry = weakSelf.waterfallWrappers[waterfall.placementID];
        if (placementEntry == nil) {
            placementEntry = [NSMutableDictionary<NSString*, ATWaterfallWrapper*> dictionary];
            weakSelf.waterfallWrappers[waterfall.placementID] = placementEntry;
        }
        ATWaterfallWrapper *wrapper = placementEntry[waterfall.requestID];
        if (wrapper == nil) {
            wrapper = [ATWaterfallWrapper wrapperWithPlacementID:waterfall.placementID requestID:waterfall.requestID];
            placementEntry[waterfall.requestID] = wrapper;
        }
        __weak ATWaterfallWrapper *weakWrapper = wrapper;
        dispatch_async(wrapper.access_queue, ^{
            [weakWrapper installWaterfall:waterfall];
            completion(weakWrapper, weakWrapper.waterfall, weakWrapper.headerBiddingWaterfall, weakWrapper.finalWaterfall, weakWrapper.finished, weakWrapper.startDate);
        });
    }];
}
@end
