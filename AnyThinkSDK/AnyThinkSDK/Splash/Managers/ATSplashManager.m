//
//  ATSplashManager.m
//  AnyThinkSplash
//
//  Created by Martin Lau on 2018/12/20.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATSplashManager.h"
#import "ATAd.h"
#import "ATThreadSafeAccessor.h"
#import "ATSplash.h"
#import "ATCapsManager.h"
#import "Utilities.h"
#import "ATPlacementModel.h"
#import "ATUnitGroupModel.h"
#import "ATSplashCustomEvent.h"
#import "ATSplashDelegate.h"
NSString *const kATSplashExtraContainerViewKey = @"container_view";
NSString *const kATSplashExtraWindowKey = @"window";
NSString *const kATSplashExtraWindowSceneKey = @"windowScene";
NSString *const kATSplashExtraLoadingStartDateKey = @"loading_start_date";
@interface ATSplashManager()
@property(nonatomic, readonly) ATSerialThreadSafeAccessor *storageAccessor;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSDictionary*> *storage;
@end

@implementation ATSplashManager
+(instancetype) sharedManager {
    static ATSplashManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATSplashManager alloc] init];
    });
    return sharedManager;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _storage = [NSMutableDictionary<NSString*, NSDictionary*> dictionary];
        _storageAccessor = [ATSerialThreadSafeAccessor new];
    }
    return self;
}

-(NSInteger) highestPriorityOfShownAdInPlacementID:(NSString*)placementID requestID:(NSString*)requestID {
    return NSNotFound;
}

/*
 The structure of the storage is as follows:
 {
    placement_id: {
         splash:offer,
         request_id:request_id
     }
 }
 */
static NSString *const kStorageRequestIDKey = @"request_id";
static NSString *const kStorageSplashKey = @"splash";
-(void) addAdWithADAssets:(NSDictionary*)assets withPlacementSetting:(ATPlacementModel*)placementModel unitGroup:(ATUnitGroupModel*)unitGroup requestID:(NSString*)requestID {
    __weak typeof(self) weakSelf = self;
    ATSplash *splash = [[ATSplash alloc] initWithPriority:[placementModel.unitGroups indexOfObject:unitGroup] placementModel:placementModel requestID:requestID assets:assets unitGroup:unitGroup];
    splash.showTimes = 1;
    [splash.customEvent trackShow];
    [_storageAccessor writeWithBlock:^{ weakSelf.storage[placementModel.placementID] = @{kStorageRequestIDKey:requestID, kStorageSplashKey:splash}; }];
}

-(BOOL) adSourceStatusInPlacementModel:(ATPlacementModel*)placementModel unitGroup:(ATUnitGroupModel*)unitGroup {
    return NO;
}

-(NSArray<id<ATAd>>*) adsWithPlacementID:(NSString*)placementID {
    __weak typeof(self) weakSelf = self;
    NSMutableArray<ATSplash*>* ads = [NSMutableArray<ATSplash*> array];
    return [_storageAccessor readWithBlock:^id{
        if ([weakSelf.storage[placementID][kStorageSplashKey] isKindOfClass:[ATSplash class]] && ((ATSplash*)weakSelf.storage[placementID][kStorageSplashKey]).showTimes < 1) { [ads addObject:weakSelf.storage[placementID][kStorageSplashKey]]; }
        return ads;
    }];
}

-(void) clearCahceForPlacementID:(NSString *)placementID {
    __weak typeof(self) weakSelf = self;
    [_storageAccessor writeWithBlock:^{ [weakSelf.storage removeObjectForKey:placementID]; }];
}

-(void) clearCache {
    __weak typeof(self) weakSelf = self;
    [_storageAccessor writeWithBlock:^{ [weakSelf.storage removeAllObjects]; }];
}
@end
