//
//  ATAdStorageUtility.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 2019/2/22.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATAd.h"
#import "ATAdManager+Internal.h"
#import "ATWaterfallManager.h"
typedef NS_ENUM(NSInteger, ATAdNotReadyReason) {
    ATAdNotReadyReasonStatusFalse = 0,
    ATAdNotReadyReasonStatusExpired = 1,
    ATAdNotReadyReasonNoReadyAd = 1,
    ATAdNotReadyReasonAdAllExpired = 1
};
/**
 *Methods defined in this class are not thread-safe; Calls have to provide accessors themselves.
 */
@interface ATAdStorageUtility : NSObject
+(NSDictionary<NSString*, NSArray<id<ATAd>>*>*) saveAd:(id<ATAd>)ad finalWaterfall:(ATWaterfall*)finalWaterfall toStorage:(NSMutableDictionary*)storage requestID:(NSString*)requestID;

+(id<ATAd>) adInStorage:(NSMutableDictionary*)storage statusStorage:(NSMutableDictionary*)statusStorage forPlacementID:(NSString*)placementID caller:(ATAdManagerReadyAPICaller)caller extra:(NSDictionary* __autoreleasing*)extra;

+(void) clearPlacementContainingAd:(id<ATAd>)ad fromStorage:(NSMutableDictionary*)storage;

+(void) removeAdForPlacementID:(NSString*)placementID unitGroupID:(NSString*)unitGroupID inStorage:(NSMutableDictionary*)storage;

+(BOOL) lastOfferShownForPlacementID:(NSString*)placementID unitGroupID:(NSString*)unitGroupID inStorage:(NSMutableDictionary*)storage;

+(NSInteger) highestPriorityOfShownAdInStorage:(NSMutableDictionary*)storage placementID:(NSString*)placementID requestID:(NSString*)requestID;

+(BOOL) validateCapsForUnitGroup:(ATUnitGroupModel*)unitGroup placementID:(NSString*)placementID;
+(BOOL) validatePacingForUnitGroup:(ATUnitGroupModel*)unitGroup placementID:(NSString*)placementID;
+(void) removeAdForPlacementID:(NSString*)placementID unitGroupModel:(ATUnitGroupModel*)unitGroupModel inStorage:(NSMutableDictionary*)storage statusStorage:(NSMutableDictionary*)statusStorage;
@end

@interface ATAdStorageUtility(AdSourceStatus)
/*
 *
 */
+(void) saveAd:(id<ATAd>)ad toStatusStorage:(NSMutableDictionary*)storage;
+(void) invalidateStatusForAd:(id<ATAd>)ad inStatusStorage:(NSMutableDictionary*)statusStorage;
+(BOOL) adSourceStatusInStorage:(NSDictionary*)storage placementModel:(ATPlacementModel*)placementModel unitGroup:(ATUnitGroupModel*)unitGroup;
+(void) renewOffersWithPlacementModel:(ATPlacementModel*)placementModel finalWaterfall:(ATWaterfall*)finalWaterfall requestID:(NSString*)requestID inStatusStorage:(NSMutableDictionary*)statusStorage offerStorate:(NSMutableDictionary*)offerStorage extraInfo:(NSArray<NSDictionary*>*__autoreleasing*)extraInfo;
@end
