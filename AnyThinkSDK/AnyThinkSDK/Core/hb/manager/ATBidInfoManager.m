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
#import "Utilities.h"
@interface ATBidInfoManager()
@property(nonatomic, readonly) NSMutableDictionary *info;
@property(nonatomic, readonly) ATThreadSafeAccessor *infoAccessor;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSString*>* requestIDStorage;
@property(nonatomic, readonly) ATThreadSafeAccessor *requestIDStorageAccessor;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, ATBidInfo*>* diskBidInfoStorage;
@property(nonatomic, readonly) ATThreadSafeAccessor *diskBidInfoStorageAccessor;
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
        
        _diskBidInfoStorage = [NSMutableDictionary<NSString*, NSString*> dictionary];
        _diskBidInfoStorageAccessor = [ATThreadSafeAccessor new];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[ATBidInfoManager bidInfoCacheArchivePath]]) { [[NSFileManager defaultManager] createDirectoryAtPath:[ATBidInfoManager bidInfoCacheArchivePath] withIntermediateDirectories:NO attributes:nil error:nil]; }
        [self loadBidInfoFromDisk];
    }
    return self;
}

+(NSString*) bidInfoCacheArchivePath {
    return [[Utilities documentsPath] stringByAppendingPathComponent:@"com.anythink.bidinfo"];
}

-(void) loadBidInfoFromDisk {
    __weak typeof(self) weakSelf = self;
    //get adx offer from disk
    [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[ATBidInfoManager bidInfoCacheArchivePath] error:nil] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *path = [[ATBidInfoManager bidInfoCacheArchivePath] stringByAppendingPathComponent:obj];
        NSDictionary *bidInfoDict = nil;
        if ([NSDictionary respondsToSelector:@selector(dictionaryWithContentsOfURL:error:)]) {
            bidInfoDict = [NSMutableDictionary dictionaryWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
        } else {
            bidInfoDict = [NSDictionary dictionaryWithContentsOfFile:path];
        }
        NSDictionary<NSFileAttributeKey, id> * attr = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        if ([bidInfoDict isKindOfClass:[NSDictionary class]]) {
            weakSelf.diskBidInfoStorage[obj] = [[ATBidInfo alloc] initWithDictionary:bidInfoDict];
        }
    }];
    
}


-(void) saveBidInfoToDiskWithBidInfo:(ATBidInfo *)bidInfo {
    __weak typeof(self) weakSelf = self;
    [_diskBidInfoStorageAccessor writeWithBlock:^{
        //save adx bidinfo
        weakSelf.diskBidInfoStorage[[NSString stringWithFormat:@"%@",bidInfo.unitGroupUnitID]] = bidInfo;
        NSString *path = [[ATBidInfoManager bidInfoCacheArchivePath] stringByAppendingPathComponent:bidInfo.unitGroupUnitID];
        [[bidInfo serializationToDictionary] writeToFile:path atomically:YES];
    }];
}

-(void) removeDiskBidInfo:(ATBidInfo*)bidInfo {
    __weak typeof(self) weakSelf = self;
    [_diskBidInfoStorageAccessor writeWithBlock:^{
        NSString *path = [[ATBidInfoManager bidInfoCacheArchivePath] stringByAppendingPathComponent:bidInfo.unitGroupUnitID];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        [weakSelf.diskBidInfoStorage removeObjectForKey:bidInfo.unitGroupUnitID];
    }];
  
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
    
    if(bidInfo.networkFirmID == ATNetworkFirmIdADX){
        //todo save bidinfo to disk for adx
        [self saveBidInfoToDiskWithBidInfo:bidInfo];
    }
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
-(NSArray<ATUnitGroupModel*>*) unitGroupWithHistoryBidInfoAvailableForPlacementID:(NSString*)placementID unitGroups:(NSArray<ATUnitGroupModel*>*)unitGroupsToInspect s2sUnitGroups:(NSArray<ATUnitGroupModel*>*)s2sUnitGroupsToInspect newRequestID:(NSString*)newRequestID {
    NSMutableArray<ATUnitGroupModel*>* unitGroups = [NSMutableArray<ATUnitGroupModel*> array];
    __weak typeof(self) weakSelf = self;
    [_infoAccessor readWithBlock:^id{
        NSMutableArray<ATBidInfo*>* bidInfoToResave = [NSMutableArray<ATBidInfo*> array];
        NSDictionary<NSString*, NSMutableDictionary<NSString*, ATBidInfo*>*>* placementEntry = weakSelf.info[placementID];
        if(placementEntry != nil){
            [placementEntry enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableDictionary<NSString*, ATBidInfo*> * _Nonnull reqIDEntry, BOOL * _Nonnull midStop) {
                NSMutableArray<NSString*>* keysToRemove = [NSMutableArray<NSString*> array];
                [unitGroupsToInspect enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull ug, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (reqIDEntry[ug.unitID] != nil && reqIDEntry[ug.unitID].isValid) {
                        [unitGroups addObject:ug];
                        [bidInfoToResave addObject:reqIDEntry[ug.unitID]];
                        [keysToRemove addObject:ug.unitID];
                    }
                }];
                [s2sUnitGroupsToInspect enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull ug, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (reqIDEntry[ug.unitID] != nil && reqIDEntry[ug.unitID].isValid) {
                        [unitGroups addObject:ug];
                        [bidInfoToResave addObject:reqIDEntry[ug.unitID]];
                        [keysToRemove addObject:ug.unitID];
                    }
                }];
                [reqIDEntry removeObjectsForKeys:keysToRemove];
            }];
        }
       
        //todo get adx bidinfo from disk
        [s2sUnitGroupsToInspect enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull ug, NSUInteger idx, BOOL * _Nonnull stop) {
            if (weakSelf.diskBidInfoStorage[ug.unitID]!=nil && !weakSelf.diskBidInfoStorage[ug.unitID].isExpired && ![bidInfoToResave containsObject:weakSelf.diskBidInfoStorage[ug.unitID]]) {
                [unitGroups addObject:ug];
                [bidInfoToResave addObject:weakSelf.diskBidInfoStorage[ug.unitID]];
            }
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
        if(info != nil){
            [info invalidate];
            [weakSelf removeDiskBidInfo:info];
        }
    }];
}

-(ATBidInfo*) bidInfoForPlacementID:(NSString*)placementID unitGroupModel:(ATUnitGroupModel*)unitGroupModel requestID:(NSString*)requestID {
    __weak typeof(self) weakSelf = self;
    return [_infoAccessor readWithBlock:^id{ return weakSelf.info[placementID][requestID][unitGroupModel.unitID]; }];
}

-(BOOL) checkAdxBidInfoExpireForUnitGroupModel:(ATUnitGroupModel*)unitGroupModel {
    __weak typeof(self) weakSelf = self;
    ATBidInfo* bidInfo = (ATBidInfo*)[_infoAccessor readWithBlock:^id{
        return weakSelf.diskBidInfoStorage[unitGroupModel.unitID];
    }];
    return bidInfo == nil || bidInfo.isExpired;
}

+(NSString *) priceForUnitGroup:(ATUnitGroupModel*)unitGroupModel placementID:(NSString*)placementID requestID:(NSString*)requestID {
    
    // 兼容一下旧数据,转换为字符串格式
    if (unitGroupModel.headerBidding) {
        NSString *price = [NSString stringWithFormat:@"%@", [[ATBidInfoManager sharedManager] bidInfoForPlacementID:placementID unitGroupModel:unitGroupModel requestID:requestID].price];
        return price ? price : @"0";
    }
    return unitGroupModel.price ? [NSString stringWithFormat:@"%@",unitGroupModel.price] : @"0";
}
@end
