//
//  ATUnitGroupModel.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 11/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATUnitGroupModel.h"

extern NSString *const kUnitGroupBidInfoPriceKey;
extern NSString *const kUnitGroupBidInfoBidTokenKey;
extern NSString *const kUnitGroupBidInfoBidTokenExpireDateKey;
extern NSString *const kUnitGroupBidInfoBidTokenUsedFlagKey;
CGSize sizeFromString(NSString *sizeStr) {
    CGSize size = CGSizeZero;
    NSArray<NSString*>* comp = [sizeStr componentsSeparatedByString:@"x"];
    if ([comp count] == 2 && [comp[0] respondsToSelector:@selector(doubleValue)] && [comp[1] respondsToSelector:@selector(doubleValue)]) { size = CGSizeMake([comp[0] doubleValue], [comp[1] doubleValue]); }
    return size;
}

@interface ATUnitGroupModel()
@property(nonatomic, readonly) dispatch_queue_t bid_info_access_queue;
@property (nonatomic, readonly) NSMutableDictionary<NSString*, NSDictionary*> *bidInfoByRequestID;
@end
@implementation ATUnitGroupModel
-(instancetype) initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self != nil) {
        _adapterClassString = dictionary[@"adapter_class"];
        _adapterClass = NSClassFromString(_adapterClassString);
        _capByDay = [dictionary[@"caps_d"] integerValue] == -1 ? NSIntegerMax : [dictionary[@"caps_d"] integerValue];
        _capByHour = [dictionary[@"caps_h"] integerValue] == -1 ? NSIntegerMax : [dictionary[@"caps_h"] integerValue];
        _networkCacheTime = [dictionary[@"nw_cache_time"] doubleValue];
        _networkFirmID = [dictionary[@"nw_firm_id"] integerValue];
        _networkRequestNum = [dictionary[@"nw_req_num"] integerValue];
        _networkDataTimeout = [dictionary[@"n_d_t"] doubleValue];
        _networkTimeout = [dictionary[@"nw_timeout"] doubleValue];
        _showingInterval = [dictionary[@"pacing"] doubleValue];
        _unitGroupID = [NSString stringWithFormat:@"%@", dictionary[@"ug_id"]];
        _unitID = [NSString stringWithFormat:@"%@", dictionary[@"unit_id"]];
        _price = [dictionary[@"ecpm"] doubleValue];
        _content = [NSJSONSerialization JSONObjectWithData:[dictionary[@"content"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        _adSize = sizeFromString([_content[@"size"] length] > 0 ? _content[@"size"] : [ATUnitGroupModel defaultSizeWithNetworkFirmID:_networkFirmID]);
        _headerBiddingRequestTimeout = [dictionary[@"hb_timeout"] doubleValue];
        _bidTokenTime = [dictionary[@"hb_t_c_t"] doubleValue] / 1000.0f;
        _bidInfoByRequestID = [NSMutableDictionary<NSString*, NSDictionary*> dictionary];
        _bid_info_access_queue = dispatch_queue_create("com.anythink.bidInfoAccessQueue", DISPATCH_QUEUE_SERIAL);
        _headerBidding = [dictionary[@"header_bidding"] boolValue];
        _clickTkAddress = dictionary[@"t_c_u"];
        _clickTkDelayMin = [dictionary[@"t_c_u_min_t"] integerValue];
        _clickTkDelayMax = [dictionary[@"t_c_u_max_t"] integerValue];
        _statusTime = [dictionary[@"l_s_t"] doubleValue] / 1000.0f;
        _postsNotificationOnShow = [dictionary[@"s_sw"] boolValue];
        _postsNotificationOnClick = [dictionary[@"c_sw"] boolValue];
    }
    return self;
}

-(NSString*)bidTokenWithRequestID:(NSString *)requestID {
    __block NSString *bidToken = nil;
    dispatch_sync(_bid_info_access_queue, ^{
        bidToken = _bidInfoByRequestID[requestID][kUnitGroupBidInfoBidTokenKey];
    });
    return bidToken;
}

-(NSDictionary*)latestBidInfo {
    __block NSDictionary *bidInfo = nil;
    dispatch_sync(_bid_info_access_queue, ^{
        __block NSTimeInterval interval = -1;
        NSDate *now = [NSDate date];
        [_bidInfoByRequestID enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
            NSTimeInterval curInterval = [obj[kUnitGroupBidInfoBidTokenExpireDateKey] timeIntervalSinceDate:now];
            if (![obj[kUnitGroupBidInfoBidTokenUsedFlagKey] boolValue] && curInterval > 0 && curInterval > interval) {
                bidInfo = obj;
                interval = curInterval;
            }
        }];
    });
    return bidInfo;
}

-(double) bidPriceWithRequestID:(NSString*)requestID {
    __block double bidPrice = .0f;
    dispatch_sync(_bid_info_access_queue, ^{
        bidPrice = [_bidInfoByRequestID[requestID][kUnitGroupBidInfoPriceKey] doubleValue];
    });
    return bidPrice;
}

-(void) updateBidInfoForRequestID:(NSString *)requestID {
    __typeof(self) weakSelf = self;
    if (requestID != nil) {
        dispatch_async(_bid_info_access_queue, ^{
            if (weakSelf.bidToken != nil) {
                __block NSString *latestRequestID = nil;
                [weakSelf.bidInfoByRequestID enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
                    if ([weakSelf.bidToken isEqualToString:obj[kUnitGroupBidInfoBidTokenKey]]) {
                        latestRequestID = key;
                        *stop = YES;
                    }
                }];
                if (latestRequestID != nil) {
                    weakSelf.bidInfoByRequestID[requestID] = weakSelf.bidInfoByRequestID[latestRequestID];
                    [weakSelf.bidInfoByRequestID removeObjectForKey:latestRequestID];
                } else {
                    weakSelf.bidInfoByRequestID[requestID] = @{kUnitGroupBidInfoBidTokenKey:weakSelf.bidToken, kUnitGroupBidInfoPriceKey:@(weakSelf.bidPrice), kUnitGroupBidInfoBidTokenExpireDateKey:[[NSDate date] dateByAddingTimeInterval:weakSelf.bidTokenTime]};
                }
                self->_price = self->_bidPrice;
                self->_bidPrice = .0f;
                self->_bidToken = nil;
            } else {
                [weakSelf.bidInfoByRequestID removeObjectForKey:requestID];
            }
        });
    }
}

-(void) setBidTokenUsedFlagForRequestID:(NSString*)requestID {
    __typeof(self) weakSelf = self;
    dispatch_async(_bid_info_access_queue, ^{
        NSMutableDictionary *bidInfo = [NSMutableDictionary dictionaryWithDictionary:weakSelf.bidInfoByRequestID[requestID]];
        bidInfo[kUnitGroupBidInfoBidTokenUsedFlagKey] = @YES;
        weakSelf.bidInfoByRequestID[requestID] = bidInfo;
    });
}

+(NSString*)defaultSizeWithNetworkFirmID:(NSInteger)networkFirmID {
    NSString *sizeStr = @"320x50";
    if (networkFirmID == 22) {
        sizeStr = @"375x56";
    } else if (networkFirmID == 15) {
        sizeStr = @"640x100";
    }
    return sizeStr;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"%@", @{@"unit_group_id":_unitGroupID != nil ? _unitGroupID : @"", @"network_firm_id":@(_networkFirmID), @"adapter_class":_adapterClassString, @"ad_source_id":_unitID}];
}
@end
