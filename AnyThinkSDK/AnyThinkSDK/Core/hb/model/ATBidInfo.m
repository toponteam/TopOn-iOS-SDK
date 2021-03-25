//
//  ATBidInfo.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 2020/4/27.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATBidInfo.h"
#import "Utilities.h"

@interface ATBidInfo()
@property(nonatomic, readonly) BOOL used;
@end

@implementation ATBidInfo
+(instancetype) bidInfoWithPlacementID:(NSString*)placementID unitGroupUnitID:(NSString*)unitGroupUnitID token:(NSString*)token price:(NSString*)price expirationInterval:(NSTimeInterval)expirationInterval customObject:(id)customObject {
    return [[ATBidInfo alloc] initWithPlacementID:placementID unitGroupUnitID:unitGroupUnitID token:token price:price expirationInterval:expirationInterval customObject:customObject];
}

-(instancetype) initWithPlacementID:(NSString*)placementID unitGroupUnitID:(NSString*)unitGroupUnitID token:(NSString*)token price:(NSString*)price expirationInterval:(NSTimeInterval)expirationInterval customObject:(id)customObject {
    self = [super init];
    if (self != nil) {
        _placementID = placementID;
        _unitGroupUnitID = unitGroupUnitID;
        _bidId = token;
        _price = [price fixECPMLoseWithPrice];
        _expireDate = [[NSDate date] dateByAddingTimeInterval:expirationInterval];
        _customObject = customObject;
    }
    return self;
}

-(instancetype) initWithDictionary:(NSDictionary*)dictionary placementID:(NSString*)placementID unitGroupUnitID:(NSString*)unitGroupUnitID expirationInterval:(NSTimeInterval)expirationInterval {
    self = [super init];
    if (self != nil) {
        _placementID = placementID;
        _bidId = dictionary[@"bid_id"];
        _price = [[NSString stringWithFormat:@"%@", dictionary[@"price"]] fixECPMLoseWithPrice];
        _lURL = dictionary[@"lurl"];
        _nURL = dictionary[@"nurl"];
        _unitGroupUnitID = unitGroupUnitID;
        NSTimeInterval expire = [dictionary[@"expire"] doubleValue];
        _networkFirmID = [dictionary[@"nw_firm_id"] integerValue];
        if(_networkFirmID == ATNetworkFirmIdADX){
            //for adx
            _expireDate = [[NSDate date] dateByAddingTimeInterval:expire/1000.0f];
            _offerDataDict = dictionary[@"offer_data"];
        }else{
            //use setting
            _expireDate = [[NSDate date] dateByAddingTimeInterval:expirationInterval];
        }
    }
    return self;
}

-(instancetype) initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self != nil) {
        _placementID = dictionary[@"at_placement_id"];
        _bidId = dictionary[@"bid_id"];
        _price = [NSString stringWithFormat:@"%@", dictionary[@"price"]];
        _lURL = dictionary[@"lurl"];
        _nURL = dictionary[@"nurl"];
        _unitGroupUnitID = dictionary[@"at_unit_id"];
        //second
        NSTimeInterval expireTimestamp = [dictionary[@"expire_timestamp"] doubleValue];
        _networkFirmID = [dictionary[@"nw_firm_id"] integerValue];
        _expireDate = [NSDate dateWithTimeIntervalSince1970:expireTimestamp];
        _offerDataDict = dictionary[@"offer_data"];
    }
    return self;
}

-(NSDictionary *) serializationToDictionary {
    return @{@"at_placement_id":_placementID, @"bid_id":_bidId, @"price":_price, @"lurl":_lURL,  @"at_unit_id":_unitGroupUnitID, @"expire_timestamp":@([_expireDate timeIntervalSince1970]), @"nw_firm_id":@(_networkFirmID),@"offer_data":_offerDataDict != nil ? _offerDataDict : @{}};
}

-(BOOL) isValid {
    return [_expireDate timeIntervalSinceDate:[NSDate date]] > 0 && !_used;
}

-(BOOL) isExpired {
    return [_expireDate timeIntervalSinceDate:[NSDate date]] <= 0;
}


-(void) invalidate {
    _used = YES;
}
@end
