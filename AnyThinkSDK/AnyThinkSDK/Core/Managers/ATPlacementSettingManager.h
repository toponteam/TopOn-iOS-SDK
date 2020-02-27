//
//  ATPlacementSettingManager.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 09/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ATUnitGroupModel;
@class ATPlacementModel;
@interface ATPlacementSettingManager : NSObject
+(instancetype) sharedManager;
-(ATPlacementModel*) placementSettingWithPlacementID:(NSString*)placementID;
-(void) addNewPlacementSetting:(ATPlacementModel*)placementModel;
-(void) clearAllPlacementSettings;
-(void) requestPlacementSettingWithPlacementID:(NSString*)placementID customData:(NSDictionary*)customData completion:(void(^)(ATPlacementModel *placementModel, NSError *error))completion;
-(void) addCappedMyOfferID:(NSString*)offerID;
-(void) removeCappedMyOfferID:(NSString*)offerID;
+(BOOL) myOfferExhaustedInPlacementModel:(ATPlacementModel*)placementModel;
@end

@interface ATPlacementSettingManager(UpStatus)
/*
 * Returns NO if status's NO or status's YES&outdated(in which case error's not nil)
 */
-(BOOL) statusForPlacementID:(NSString*)placementID error:(NSError**)error;
-(void) setStatus:(BOOL)status forPlacementID:(NSString*)placementID;
-(void) clearAllStatus;
@end

@interface ATPlacementSettingManager(LastRequestID)
/*
 Returns the latest request id for the specified placement
 */
-(NSString*)latestRequestIDForPlacementID:(NSString*)placementID;
-(void) setLatestRequestID:(NSString*)requestID forPlacementID:(NSString*)placementID;
-(NSString*)sessionIDForPlacementID:(NSString*)placementID;
@end
