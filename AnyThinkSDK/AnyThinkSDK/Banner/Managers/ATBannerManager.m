//
//  ATBannerManager.m
//  AnyThinkBanner
//
//  Created by Martin Lau on 18/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATBannerManager.h"
#import "ATAd.h"
#import "ATThreadSafeAccessor.h"
#import "ATBanner.h"
#import "ATCapsManager.h"
#import "Utilities.h"
#import "ATAdStorageUtility.h"
#import "ATWaterfallManager.h"
NSString *const kBannerAssetsUnitIDKey = @"unit_id";
NSString *const kBannerAssetsBannerViewKey = @"banner_view";
NSString *const kBannerAssetsCustomEventKey = @"custom_event";

NSString *const kBannerPresentModalViewControllerNotification = @"com.anythink.kBannerPresentModalViewControllerNotification";
NSString *const kBannerDismissModalViewControllerNotification = @"com.anythink.kBannerDismissModalViewControllerNotification";
NSString *const kBannerNotificationUserInfoRequestIDKey = @"request_id";
@interface ATBannerManager()
@property(nonatomic, readonly) NSMutableDictionary *statusStorage;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSMutableDictionary<NSString*, id>*>*bannerStorage;
@property(nonatomic, readonly) ATSerialThreadSafeAccessor *bannerStorageAccessor;
@end
@implementation ATBannerManager
+(instancetype) sharedManager {
    static ATBannerManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATBannerManager alloc] init];
    });
    return sharedManager;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _statusStorage = [NSMutableDictionary new];
        _bannerStorage = [NSMutableDictionary<NSString*, NSMutableDictionary<NSString*, id>*> dictionary];
        _bannerStorageAccessor = [ATSerialThreadSafeAccessor new];
    }
    return self;
}

-(NSInteger) highestPriorityOfShownAdInPlacementID:(NSString *)placementID requestID:(NSString *)requestID {
    __weak typeof(self) weakSelf = self;
    return [[_bannerStorageAccessor readWithBlock:^id{ return @([ATAdStorageUtility highestPriorityOfShownAdInStorage:weakSelf.bannerStorage placementID:placementID requestID:requestID]);}] integerValue];
}

/*
 The structure of offer storage is as follows:
 {
     placement_id:{
         unit_group_id_1:banner,
         unit_group_id_2:banner
         @"request_id":request_id
     },
     //Other placements follow.
 }
 */

static NSString *const kBannerStorageRequestIDKey = @"request_id";
-(void) addAdWithADAssets:(NSDictionary*)assets withPlacementSetting:(ATPlacementModel*)placementModel unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall*)finalWaterfall requestID:(NSString*)requestID {
    ATBanner *banner = [[ATBanner alloc] initWithPriority:[finalWaterfall.unitGroups indexOfObject:unitGroup] placementModel:placementModel requestID:requestID assets:assets unitGroup:unitGroup finalWaterfall:finalWaterfall];
    __weak typeof(self) weakSelf = self;
    [_bannerStorageAccessor writeWithBlock:^{
        [ATAdStorageUtility saveAd:banner finalWaterfall:finalWaterfall toStorage:weakSelf.bannerStorage requestID:banner.requestID];
        [ATAdStorageUtility saveAd:banner toStatusStorage:weakSelf.statusStorage];
    }];
}

-(ATBanner*) bannerForPlacementID:(NSString*)placementID invalidateStatus:(BOOL)invalidateStatus extra:(NSDictionary* __autoreleasing*)extra {
    __weak typeof(self) weakSelf = self;
    return [_bannerStorageAccessor readWithBlock:^id{
        ATBanner *banner = [ATAdStorageUtility adInStorage:weakSelf.bannerStorage statusStorage:weakSelf.statusStorage forPlacementID:placementID caller:invalidateStatus ? ATAdManagerReadyAPICallerShow : ATAdManagerReadyAPICallerReady extra:extra];
        if (invalidateStatus) { [ATAdStorageUtility invalidateStatusForAd:banner inStatusStorage:weakSelf.statusStorage]; }
        return banner;
    }];
}

-(BOOL) inspectAdSourceStatusWithPlacementModel:(ATPlacementModel*)placementModel unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall*)finalWaterfall requestID:(NSString*)requestID extraInfo:(NSArray<NSDictionary*>*__autoreleasing*)extraInfo {
    __weak typeof(self) weakSelf = self;
    return [[_bannerStorageAccessor readWithBlock:^id{
        BOOL status = [ATAdStorageUtility adSourceStatusInStorage:weakSelf.statusStorage placementModel:placementModel unitGroup:unitGroup];
        if (status) { [ATAdStorageUtility renewOffersWithPlacementModel:placementModel finalWaterfall:finalWaterfall requestID:requestID inStatusStorage:weakSelf.statusStorage offerStorate:weakSelf.bannerStorage extraInfo:extraInfo]; }
        return @(status);
    }] boolValue];
}

-(BOOL) adSourceStatusInPlacementModel:(ATPlacementModel*)placementModel unitGroup:(ATUnitGroupModel*)unitGroup {
    __weak typeof(self) weakSelf = self;
    return [[_bannerStorageAccessor readWithBlock:^id{ return @([ATAdStorageUtility adSourceStatusInStorage:weakSelf.statusStorage placementModel:placementModel unitGroup:unitGroup]); }] boolValue];
}

-(void) invalidateStatusForAd:(id<ATAd>)ad {
    __weak typeof(self) weakSelf = self;
    [_bannerStorageAccessor writeWithBlock:^{ [ATAdStorageUtility invalidateStatusForAd:ad inStatusStorage:weakSelf.statusStorage]; }];
}

-(ATBanner*) bannerForPlacementID:(NSString*)placementID extra:(NSDictionary* __autoreleasing*)extra {
    return [self bannerForPlacementID:placementID invalidateStatus:NO extra:extra];
}

-(NSArray<id<ATAd>>*) adsWithPlacementID:(NSString*)placementID {
    ATBanner *banner = [[ATBannerManager sharedManager] bannerForPlacementID:placementID extra:nil];
    if (banner != nil) { return @[banner]; }
    else { return nil; }
}

-(void) removeCacheContainingBanner:(ATBanner *)banner {
    __weak typeof(self) weakSelf = self;
    [_bannerStorageAccessor writeWithBlock:^{
        [ATAdStorageUtility removeAdForPlacementID:banner.placementModel.placementID unitGroupID:banner.unitGroup.unitGroupID inStorage:weakSelf.bannerStorage];
//        [ATAdStorageUtility clearPlacementContainingAd:banner fromStorage:weakSelf.bannerStorage];
        
    }];
}

-(void) clearCahceForPlacementID:(NSString *)placementID {
    [_bannerStorageAccessor writeWithBlock:^{
        [_bannerStorage removeObjectForKey:placementID];
    }];
}

-(void) clearCache {
    __weak typeof(self) weakSelf = self;
    [_bannerStorageAccessor writeWithBlock:^{ [weakSelf.bannerStorage removeAllObjects]; }];
}
@end
