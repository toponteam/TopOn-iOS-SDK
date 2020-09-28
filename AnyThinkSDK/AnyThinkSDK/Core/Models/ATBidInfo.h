//
//  ATBidInfo.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 2020/4/27.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATBidInfo : NSObject
@property(nonatomic, readonly) NSString *token;
@property(nonatomic, readonly) double price;
@property(nonatomic, readonly) id customObject;
@property(nonatomic, readonly) NSString *placementID;
@property(nonatomic, readonly) NSString *unitGroupUnitID;
@property(nonatomic, readonly) NSInteger networkFirmID;
@property(nonatomic, readonly) NSString *lURL;
@property(nonatomic, readonly) NSString *nURL;
@property(nonatomic, readonly, getter=isValid) BOOL valid;
+(instancetype) bidInfoWithPlacementID:(NSString*)placementID unitGroupUnitID:(NSString*)unitGroupUnitID token:(NSString*)token price:(double)price expirationInterval:(NSTimeInterval)expirationInterval customObject:(id)customObject;
-(instancetype) initWithDictionary:(NSDictionary*)dictionary placementID:(NSString*)placementID unitGroupUnitID:(NSString*)unitGroupUnitID expirationInterval:(NSTimeInterval)expirationInterval;
-(void) invalidate;
@end
