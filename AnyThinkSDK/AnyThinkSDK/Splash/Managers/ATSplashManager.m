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
#import "ATWaterfallManager.h"
#import "ATPlacementSettingManager.h"
#import "ATGeneralAdAgentEvent.h"
#import "ATAdStorageUtility.h"
NSString *const kATSplashExtraContainerViewKey = @"container_view";
NSString *const kATSplashExtraWindowKey = @"window";
NSString *const kATSplashExtraWindowSceneKey = @"windowScene";
NSString *const kATSplashExtraLoadingStartDateKey = @"loading_start_date";

@interface ATSplashManager()

@property(nonatomic, readonly) ATSerialThreadSafeAccessor *storageAccessor;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSDictionary*> *storage;
@property(nonatomic, readonly) NSMutableDictionary *splashStorage;

// splash which loads without a placement setting
@property(nonatomic, readonly) NSMutableDictionary *splashWithoutSetting;
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
        _splashStorage = [NSMutableDictionary new];
        _splashWithoutSetting = [NSMutableDictionary new];
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
-(void) addAdWithADAssets:(NSDictionary*)assets withPlacementSetting:(ATPlacementModel*)placementModel unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall*)finalWaterfall requestID:(NSString*)requestID {
    ATSplash *splash = [[ATSplash alloc] initWithPriority:[finalWaterfall.unitGroups indexOfObject:unitGroup] placementModel:placementModel requestID:requestID assets:assets unitGroup:unitGroup finalWaterfall:finalWaterfall];
//    splash.showTimes = 1;
//    //track show to avoid error for generate custom event ad object async
//    [splash.customEvent saveShowAPIContext];
//
//    //to do
////    if ([splash.customEvent isKindOfClass:[ATMyOfferSplashCustomEvent class]]) {
//        [splash.customEvent trackShow];
////    }
    
    [_storageAccessor writeWithBlock:^{

//        weakSelf.storage[placementModel.placementID] = @{kStorageRequestIDKey:requestID, kStorageSplashKey:splash};
        [ATAdStorageUtility saveAd:splash finalWaterfall:finalWaterfall toStorage:self.splashStorage requestID:splash.requestID];
        [ATAdStorageUtility saveAd:splash toStatusStorage:self.storage];
    }];
}

- (void)saveAdWithoutPlacementSetting:(ATSplash *)splash extra:(NSDictionary *)extra placementID:(NSString *)placementID {
    NSDictionary *splashInfo = @{@"splash":splash,@"extra":extra != nil ? extra : @{}};
    [self.splashWithoutSetting setValue:splashInfo forKey:placementID];
}

// MARK:- ready
//- (ATSplash *)splashReadyWithoutPlacement:(NSString *)placementID {
//    return [_storageAccessor readWithBlock:^id{
//        return [self.storage[placementID] valueForKey:kStorageSplashKey];
//    }];
//}

- (ATSplash *)splashForPlacementID:(NSString*)placementID invalidateStatus:(BOOL)invalidateStatus extra:(NSDictionary* __autoreleasing*)extra {
    
    if ([self.splashWithoutSetting.allKeys containsObject:placementID]) {
        *extra = self.splashWithoutSetting[placementID][@"extra"];
        return self.splashWithoutSetting[placementID][@"splash"];
    }
    
    __weak typeof(self) weakSelf = self;
    return [_storageAccessor readWithBlock:^id{
    
        ATSplash *splash = [ATAdStorageUtility adInStorage:weakSelf.splashStorage statusStorage:weakSelf.storage forPlacementID:placementID caller:invalidateStatus ? ATAdManagerReadyAPICallerShow : ATAdManagerReadyAPICallerReady extra:extra];
        if (invalidateStatus) {
            [ATAdStorageUtility invalidateStatusForAd:splash inStatusStorage:weakSelf.storage];
        }
        return splash;
    }];
}
// MARK:-
- (void)ckearDefaultSplash {
//    [_storageAccessor writeWithBlock:^{
        [self.splashWithoutSetting removeAllObjects];
//    }];
}

-(BOOL) adSourceStatusInPlacementModel:(ATPlacementModel*)placementModel unitGroup:(ATUnitGroupModel*)unitGroup {
    __weak typeof(self) weakSelf = self;
    return [[_storageAccessor readWithBlock:^id{
        return @([ATAdStorageUtility adSourceStatusInStorage:weakSelf.storage placementModel:placementModel unitGroup:unitGroup]); }] boolValue];
}

-(void) invalidateStatusForAd:(id<ATAd>)ad {
    __weak typeof(self) weakSelf = self;
    [_storageAccessor writeWithBlock:^{
        [ATAdStorageUtility invalidateStatusForAd:ad inStatusStorage:weakSelf.storage];
    }];
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
    
    if ([self.splashWithoutSetting.allKeys containsObject:placementID]) {
        [self.splashWithoutSetting setValue:nil forKey:placementID];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [_storageAccessor writeWithBlock:^{
        [weakSelf.splashStorage removeObjectForKey:placementID];
        
    }];
}

-(void) clearCache {
    __weak typeof(self) weakSelf = self;
    [_storageAccessor writeWithBlock:^{
        [weakSelf.splashStorage removeAllObjects];
        
    }];
}

- (BOOL)inspectAdSourceStatusWithPlacementModel:(ATPlacementModel *)placementModel unitGroup:(ATUnitGroupModel *)unitGroup finalWaterfall:(ATWaterfall *)finalWaterfall requestID:(NSString *)requestID extraInfo:(NSArray<NSDictionary *> *__autoreleasing *)extraInfo {
    __weak typeof(self) weakSelf = self;
    return [[_storageAccessor readWithBlock:^id{
        BOOL status = [ATAdStorageUtility adSourceStatusInStorage:weakSelf.storage placementModel:placementModel unitGroup:unitGroup];
        
        if (status) { [ATAdStorageUtility renewOffersWithPlacementModel:placementModel finalWaterfall:finalWaterfall requestID:requestID inStatusStorage:weakSelf.storage offerStorate:weakSelf.splashStorage extraInfo:extraInfo]; }
        return @(status);
    }] boolValue];
}

- (void)removeAdForPlacementID:(NSString *)placementID unitGroupID:(NSString *)unitGroupID {
    [_storageAccessor writeWithBlock:^{
        [ATAdStorageUtility removeAdForPlacementID:placementID unitGroupID:unitGroupID inStorage:_splashStorage];
    }];

}

- (ATSplash *)splashWithPlacementID:(NSString*)placementID unitGroupID:(NSString*)unitGroupID {
    __weak typeof(self) weakSelf = self;
    NSArray<ATSplash *>* splashs = (NSArray<ATSplash *>*)[_storageAccessor readWithBlock:^id{
        return weakSelf.splashStorage[placementID][@"splash"];
    }];
    __block ATSplash *splash = nil;
    [splashs enumerateObjectsUsingBlock:^(ATSplash * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.unitGroup.unitGroupID isEqualToString:unitGroupID]) {
            splash = obj;
            *stop = YES;
        }
    }];
    return splash;
}

@end
