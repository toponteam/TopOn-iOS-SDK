//
//  ATNativeADOfferManager.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 12/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATNativeADOfferManager.h"
#import "Utilities.h"
#import "ATThreadSafeAccessor.h"
#import "ATPlacementModel.h"
#import "ATNativeADCache.h"
#import "ATUnitGroupModel.h"
#import "ATAPI+Internal.h"
#import "ATCapsManager.h"
#import "ATAdStorageUtility.h"
#import "ATWaterfallManager.h"

@interface ATNativeADOfferManager()
@property(nonatomic, readonly) ATSerialThreadSafeAccessor *offerCacheAccessor;
@property(nonatomic, readonly) NSMutableDictionary *offers;
@property(nonatomic, readonly) NSMutableDictionary *statusStorage;
@end

@implementation ATNativeADOfferManager
#pragma mark - init
+(instancetype) sharedManager {
    static ATNativeADOfferManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATNativeADOfferManager alloc] init];
    });
    return sharedManager;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _offerCacheAccessor = [ATSerialThreadSafeAccessor new];
        _offers = [NSMutableDictionary dictionary];
        _statusStorage = [NSMutableDictionary new];
    }
    return self;
}
#pragma mark - offer management
-(NSInteger) highestPriorityOfShownAdInPlacementID:(NSString *)placementID requestID:(NSString *)requestID {
    return [[_offerCacheAccessor readWithBlock:^id{ return @([ATAdStorageUtility highestPriorityOfShownAdInStorage:_offers placementID:placementID requestID:requestID]);}] integerValue];
}

-(BOOL) offerExhaustedInPlacementID:(NSString*)placementID unitGroupID:(NSString*)unitGroupID {
    return [[_offerCacheAccessor readWithBlock:^id{ return @([ATAdStorageUtility lastOfferShownForPlacementID:placementID unitGroupID:unitGroupID inStorage:_offers]);}] integerValue];
}

-(void) addAdWithADAssets:(NSDictionary*)assets withPlacementSetting:(ATPlacementModel*)placementModel unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall*)finalWaterfall requestID:(NSString*)requestID {
    ATNativeADCache *offerCache = [[ATNativeADCache alloc] initWithPriority:[finalWaterfall.unitGroups indexOfObject:unitGroup] placementModel:placementModel requestID:requestID assets:assets unitGroup:unitGroup finalWaterfall:finalWaterfall];
    __weak typeof(self) weakSelf = self;
    [_offerCacheAccessor writeWithBlock:^{
        NSDictionary *__block discardedOffers = [ATAdStorageUtility saveAd:offerCache finalWaterfall:finalWaterfall toStorage:weakSelf.offers requestID:offerCache.requestID];
        [ATAdStorageUtility saveAd:offerCache toStatusStorage:weakSelf.statusStorage];
        dispatch_async(dispatch_get_main_queue(), ^{
            discardedOffers = nil;
        });
    }];
}

-(BOOL) inspectAdSourceStatusWithPlacementModel:(ATPlacementModel*)placementModel unitGroup:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall*)finalWaterfall requestID:(NSString*)requestID extraInfo:(NSArray<NSDictionary*>*__autoreleasing*)extraInfo {
    __weak typeof(self) weakSelf = self;
    return [[_offerCacheAccessor readWithBlock:^id{
        BOOL status = [ATAdStorageUtility adSourceStatusInStorage:weakSelf.statusStorage placementModel:placementModel unitGroup:unitGroup];
        if (status) { [ATAdStorageUtility renewOffersWithPlacementModel:placementModel finalWaterfall:finalWaterfall requestID:requestID inStatusStorage:weakSelf.statusStorage offerStorate:weakSelf.offers extraInfo:extraInfo]; }
        return @(status);
    }] boolValue];
}

-(BOOL) adSourceStatusInPlacementModel:(ATPlacementModel*)placementModel unitGroup:(ATUnitGroupModel*)unitGroup {
    __weak typeof(self) weakSelf = self;
    return [[_offerCacheAccessor readWithBlock:^id{ return @([ATAdStorageUtility adSourceStatusInStorage:weakSelf.statusStorage placementModel:placementModel unitGroup:unitGroup]); }] boolValue];
}

-(void) invalidateStatusForAd:(id<ATAd>)ad {
    __weak typeof(self) weakSelf = self;
    [_offerCacheAccessor writeWithBlock:^{ [ATAdStorageUtility invalidateStatusForAd:ad inStatusStorage:weakSelf.statusStorage]; }];
}

-(ATNativeADCache*)nativeAdWithPlacementID:(NSString*)placementID extra:(NSDictionary*__autoreleasing*)extra {
    return [self nativeAdWithPlacementID:placementID invalidateStatus:NO extra:extra];
}

-(ATNativeADCache*)nativeAdWithPlacementID:(NSString*)placementID invalidateStatus:(BOOL)invalidateStatus extra:(NSDictionary*__autoreleasing*)extra {
    __weak typeof(self) weakSelf = self;
    return [_offerCacheAccessor readWithBlock:^id{
        ATNativeADCache *cache = [ATAdStorageUtility adInStorage:weakSelf.offers statusStorage:weakSelf.statusStorage forPlacementID:placementID caller:invalidateStatus ? ATAdManagerReadyAPICallerShow : ATAdManagerReadyAPICallerReady extra:extra];
        if (invalidateStatus) { [ATAdStorageUtility invalidateStatusForAd:cache inStatusStorage:weakSelf.statusStorage]; }
        return cache;
        
    }];
}

-(NSArray<id<ATAd>>*) adsWithPlacementID:(NSString*)placementID {
    NSMutableArray<id<ATAd>>* ads = [NSMutableArray<id<ATAd>> array];
    ATNativeADCache *nativeAd = [[ATNativeADOfferManager sharedManager] nativeAdWithPlacementID:placementID extra:nil];
    if (nativeAd != nil) { [ads addObject:nativeAd]; }
    return ads;
}

-(void) clearCahceForPlacementID:(NSString*)placementID {
    [_offerCacheAccessor writeWithBlock:^{
        [_offers removeObjectForKey:placementID];
    }];
}

-(void) removeAdForPlacementID:(NSString*)placementID unitGroupID:(NSString*)unitGroupID {
    [_offerCacheAccessor writeWithBlock:^{ [ATAdStorageUtility removeAdForPlacementID:placementID unitGroupID:unitGroupID inStorage:_offers]; }];
}

-(void) removeCahceForPlacementID:(NSString*)placementID unitGroupModel:(ATUnitGroupModel*)unitGroupModel {
    [_offerCacheAccessor writeWithBlock:^{ [ATAdStorageUtility removeAdForPlacementID:placementID unitGroupModel:unitGroupModel inStorage:_offers statusStorage:_statusStorage]; }];
}

-(void) clearCache {
    __weak typeof(self) weakSelf = self;
    [_offerCacheAccessor writeWithBlock:^{ [weakSelf.offers removeAllObjects]; }];
}
@end
