//
//  ATBidInfo.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 2020/4/27.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATBidInfo.h"

@interface ATBidInfo()
@property(nonatomic, readonly) NSDate *expireDate;
@property(nonatomic, readonly) BOOL used;
@end

@implementation ATBidInfo
+(instancetype) bidInfoWithPlacementID:(NSString*)placementID unitGroupUnitID:(NSString*)unitGroupUnitID token:(NSString*)token price:(double)price expirationInterval:(NSTimeInterval)expirationInterval customObject:(id)customObject {
    return [[ATBidInfo alloc] initWithPlacementID:placementID unitGroupUnitID:unitGroupUnitID token:token price:price expirationInterval:expirationInterval customObject:customObject];
}

-(instancetype) initWithPlacementID:(NSString*)placementID unitGroupUnitID:(NSString*)unitGroupUnitID token:(NSString*)token price:(double)price expirationInterval:(NSTimeInterval)expirationInterval customObject:(id)customObject {
    self = [super init];
    if (self != nil) {
        _placementID = placementID;
        _unitGroupUnitID = unitGroupUnitID;
        _token = token;
        _price = price;
        _expireDate = [[NSDate date] dateByAddingTimeInterval:expirationInterval];
        _customObject = customObject;
    }
    return self;
}

-(instancetype) initWithDictionary:(NSDictionary*)dictionary placementID:(NSString*)placementID unitGroupUnitID:(NSString*)unitGroupUnitID expirationInterval:(NSTimeInterval)expirationInterval {
    self = [super init];
    if (self != nil) {
        _placementID = placementID;
        _token = dictionary[@"bid_id"];
        _price = [dictionary[@"price"] doubleValue];
        _lURL = dictionary[@"lurl"];
        _nURL = dictionary[@"nurl"];
        _unitGroupUnitID = unitGroupUnitID;
        _expireDate = [[NSDate date] dateByAddingTimeInterval:expirationInterval];
        _networkFirmID = [dictionary[@"nw_firm_id"] integerValue];
    }
    return self;
}

-(BOOL) isValid {
    return [_expireDate timeIntervalSinceDate:[NSDate date]] > 0 && !_used;
}

-(void) invalidate {
    _used = YES;
}
@end
