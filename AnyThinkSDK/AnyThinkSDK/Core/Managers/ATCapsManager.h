//
//  ATCapsManager.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 28/06/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATAd.h"
@interface ATCapsManager : NSObject
+(instancetype)sharedManager;
/**
 The following caps accessing methods are thread-safe.
 */

-(void) increaseCapWithPlacementID:(NSString*)placementID unitGroupID:(NSString*)unitGroupID requestID:(NSString*)requestID;
-(NSInteger) capByDayWithPlacementID:(NSString*)placementID unitGroupID:(NSString*)unitGroupID requestID:(NSString*)requestID;
-(NSInteger) capByHourWithPlacementID:(NSString*)placementID unitGroupID:(NSString*)unitGroupID requestID:(NSString*)requestID;
/**
 
 */

-(NSInteger) capByDayWithPlacementID:(NSString*)placementID;
-(NSInteger) capByHourWithPlacementID:(NSString*)placementID;

/**
 
 */
-(void) setLastShowTimeWithPlacementID:(NSString*)placementID unitGroupID:(NSString*)unitGroupID;
-(NSDate*) lastShowTimeOfPlacementID:(NSString*)placementID;
-(NSDate*) lastShowTimeOfPlacementID:(NSString *)placementID unitGroupID:(NSString*)unitGroupID;

-(void) setShowFlagForPlacementID:(NSString*)placementID requestID:(NSString*)requestID;
-(BOOL) showFlagForPlacementID:(NSString*)placementID requestID:(NSString*)requestID;

+(BOOL)validateCapsForPlacementModel:(ATPlacementModel*)placementModel;
+(BOOL)validatePacingForPlacementModel:(ATPlacementModel*)placementModel;
@end

@interface NSObject(ATAdValidation)
-(BOOL) adValid;
@end

@interface ATUnitGroupModel(ATAdValidation)
-(BOOL) unitGroupValid:(NSString*)placementID;
@end

@interface ATPlacementModel(ATAdValidation)
-(BOOL) placementValid;
@end
