//
//  ATRewardedVideoManager.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 28/06/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATRewardedVideoManager.h"
#import "ATCapsManager.h"
#import "ATThreadSafeAccessor.h"
#import "ATRewardedVideo.h"
#import "ATPlacementModel.h"
#import "ATUnitGroupModel.h"
#import "ATRewardedVideo.h"
#import "ATRewardedVideoAdapter.h"
#import "ATAdStorageUtility.h"

NSString *const kRewardedVideoAssetsUnitIDKey = @"unit_id";
NSString *const kRewardedVideoAssetsCustomEventKey = @"custom_event";
@interface ATRewardedVideoManager()
@property(nonatomic, readonly) ATSerialThreadSafeAccessor *videoStorageAccessor;
@property(nonatomic, readonly) NSMutableDictionary *videoStorage;
@property(nonatomic, readonly) NSMutableDictionary *statusStorage;

@property(nonatomic, readonly) ATThreadSafeAccessor *eventStorageAccessor;
@property(nonatomic, readonly) NSMutableDictionary *eventStorage;

@property(nonatomic, readonly) ATThreadSafeAccessor *firstLoadFlagStorageAccessor;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSNumber*> *firstLoadFlagStorage;
@end

static NSString *const kOffersKey = @"offers";
static NSString *const kRequestIDKey = @"request_id";
@implementation ATRewardedVideoManager
+(instancetype) sharedManager {
    static ATRewardedVideoManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATRewardedVideoManager alloc] init];
    });
    return sharedManager;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _videoStorageAccessor = [ATSerialThreadSafeAccessor new];
        _videoStorage = [NSMutableDictionary dictionary];
        _statusStorage = [NSMutableDictionary new];
        
        _eventStorageAccessor = [ATThreadSafeAccessor new];
        _eventStorage = [NSMutableDictionary dictionary];
        
        _firstLoadFlagStorageAccessor = [ATThreadSafeAccessor new];
        _firstLoadFlagStorage = [NSMutableDictionary<NSString*, NSNumber*> dictionary];
    }
    return self;
}

#pragma mark - video management
-(NSInteger) highestPriorityOfShownAdInPlacementID:(NSString *)placementID requestID:(NSString *)requestID {
    __weak typeof(self) weakSelf = self;
    return [[_videoStorageAccessor readWithBlock:^id{ return @([ATAdStorageUtility highestPriorityOfShownAdInStorage:weakSelf.videoStorage placementID:placementID requestID:requestID]);}] integerValue];
}

-(void) addAdWithADAssets:(NSDictionary*)assets withPlacementSetting:(ATPlacementModel*)placementModel unitGroup:(ATUnitGroupModel*)unitGroup requestID:(NSString*)requestID {
    ATRewardedVideo *video = [[ATRewardedVideo alloc] initWithPriority:[placementModel.unitGroups indexOfObject:unitGroup] placementModel:placementModel requestID:requestID assets:assets unitGroup:unitGroup];
    __weak typeof(self) weakSelf = self;
    [_videoStorageAccessor writeWithBlock:^{
        [ATAdStorageUtility saveAd:video toStorage:weakSelf.videoStorage requestID:video.requestID];
        [ATAdStorageUtility saveAd:video toStatusStorage:weakSelf.statusStorage];
    }];
}

-(BOOL) inspectAdSourceStatusWithPlacementModel:(ATPlacementModel*)placementModel activeUnitGroups:(NSArray<ATUnitGroupModel*>*)activeUnitGroups unitGroup:(ATUnitGroupModel*)unitGroup requestID:(NSString*)requestID extraInfo:(NSArray<NSDictionary*>*__autoreleasing*)extraInfo {
    __weak typeof(self) weakSelf = self;
    return [[_videoStorageAccessor readWithBlock:^id{
        BOOL status = [ATAdStorageUtility adSourceStatusInStorage:weakSelf.statusStorage placementModel:placementModel unitGroup:unitGroup];
        if (status) { [ATAdStorageUtility renewOffersWithPlacementModel:placementModel activeUnitGroups:activeUnitGroups requestID:requestID inStatusStorage:weakSelf.statusStorage offerStorate:weakSelf.videoStorage extraInfo:extraInfo]; }
        return @(status);
    }] boolValue];
}

-(BOOL) adSourceStatusInPlacementModel:(ATPlacementModel*)placementModel unitGroup:(ATUnitGroupModel*)unitGroup {
    __weak typeof(self) weakSelf = self;
    return [[_videoStorageAccessor readWithBlock:^id{ return @([ATAdStorageUtility adSourceStatusInStorage:weakSelf.statusStorage placementModel:placementModel unitGroup:unitGroup]); }] boolValue];
}

-(void) invalidateStatusForAd:(id<ATAd>)ad {
    __weak typeof(self) weakSelf = self;
    [_videoStorageAccessor writeWithBlock:^{ [ATAdStorageUtility invalidateStatusForAd:ad inStatusStorage:weakSelf.statusStorage]; }];
}

-(ATRewardedVideo*) rewardedVideoForPlacementID:(NSString*)placementID invalidateStatus:(BOOL)invalidateStatus extra:(NSDictionary*__autoreleasing*)extra {
    __weak typeof(self) weakSelf = self;
    return [_videoStorageAccessor readWithBlock:^id{
        ATRewardedVideo *video = [ATAdStorageUtility adInStorage:weakSelf.videoStorage statusStorage:weakSelf.statusStorage forPlacementID:placementID extra:extra];
        if (invalidateStatus) { [ATAdStorageUtility invalidateStatusForAd:video inStatusStorage:weakSelf.statusStorage]; }
        return video;
    }];
}

-(ATRewardedVideo*) rewardedVideoForPlacementID:(NSString*)placementID extra:(NSDictionary* __autoreleasing*)extra {
    return [self rewardedVideoForPlacementID:placementID invalidateStatus:NO extra:extra];
}

-(NSArray<id<ATAd>>*) adsWithPlacementID:(NSString*)placementID {
    NSMutableArray<id<ATAd>>* ads = [NSMutableArray<id<ATAd>> array];
    ATRewardedVideo *rv = [[ATRewardedVideoManager sharedManager] rewardedVideoForPlacementID:placementID extra:nil];
    if (rv != nil) { [ads addObject:rv]; }
    return ads;
}

-(void) clearCache {
    __weak typeof(self) weakSelf = self;
    [_videoStorageAccessor writeWithBlock:^{ [weakSelf.videoStorage removeAllObjects]; }];
}

-(NSDictionary<NSNumber*, NSNumber*>*)placementStatusWithPlacementID:(NSString*)placementID {
    __weak typeof(self) weakSelf = self;
    return [_videoStorageAccessor readWithBlock:^id{
        NSMutableDictionary *status = [NSMutableDictionary<NSNumber*, NSNumber*> dictionary];
        NSDictionary<NSString*, ATRewardedVideo*>* placementVideos = weakSelf.videoStorage[placementID][kOffersKey];
        [placementVideos enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, ATRewardedVideo * _Nonnull obj, BOOL * _Nonnull stop) {
            ATAdSourceStatus objStatus = ATAdSourceStatusInvalid;
            if (![obj adValid]) {
                objStatus = ATAdSourceStatusInvalid;
            } else if (![obj.unitGroup.adapterClass adReadyWithCustomObject:obj.customObject info:obj.unitGroup.content]) {
                objStatus = ATAdSourceStatusOfferNotReady;
            } else if ([obj expired]) {
                objStatus = ATAdSourceStatusOfferExpired;
            }
            status[@(obj.priority)] = @(objStatus);
        }];
        return status;
    }];
}

-(void) clearCahceForPlacementID:(NSString*)placementID {
    [_videoStorageAccessor writeWithBlock:^{ [_videoStorage removeObjectForKey:placementID]; }];
}

-(void) removeAdForPlacementID:(NSString*)placementID unitGroupID:(NSString*)unitGroupID {
    [_videoStorageAccessor writeWithBlock:^{ [ATAdStorageUtility removeAdForPlacementID:placementID unitGroupID:unitGroupID inStorage:_videoStorage]; }];
}
#pragma mark - event management
-(void) setCustomEvent:(id)event forKey:(NSString*)key {
    __weak typeof(self) weakSelf = self;
    if (event != nil && key != nil) [_eventStorageAccessor writeWithBlock:^{ weakSelf.eventStorage[key] = event; }];
}

-(void) removeCustomEventForKey:(NSString *)key {
    __weak typeof(self) weakSelf = self;
    if (key != nil) [_eventStorageAccessor writeWithBlock:^{ [weakSelf.eventStorage removeObjectForKey:key]; }];
}

-(id) customEventForKey:(NSString*)key {
    __weak typeof(self) weakSelf = self;
    return [_eventStorageAccessor readWithBlock:^id{ return weakSelf.eventStorage[key]; }];
}

-(void) setFirstLoadFlagForNetwork:(NSString*)network {
    __weak typeof(self) weakSelf = self;
    if ([network isKindOfClass:[NSString class]] && [network length] > 0) [_firstLoadFlagStorageAccessor writeWithBlock:^{ weakSelf.firstLoadFlagStorage[network] = @YES; }];
}

-(BOOL) firstLoadFlagForNetwork:(NSString*)network {
    __weak typeof(self) weakSelf = self;
    if ([network isKindOfClass:[NSString class]] && [network length] > 0) return [[_firstLoadFlagStorageAccessor readWithBlock:^id{ return weakSelf.firstLoadFlagStorage[network]; }] boolValue];
    else return NO;
}
@end
