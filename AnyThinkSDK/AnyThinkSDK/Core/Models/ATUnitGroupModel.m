//
//  ATUnitGroupModel.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 11/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATUnitGroupModel.h"
#import "ATAdAdapter.h"
#import "Utilities.h"
#import "ATAPI+Internal.h"

extern NSString *const kUnitGroupBidInfoPriceKey;
extern NSString *const kUnitGroupBidInfoBidTokenKey;
extern NSString *const kUnitGroupBidInfoBidTokenExpireDateKey;
extern NSString *const kUnitGroupBidInfoBidTokenUsedFlagKey;


@interface ATUnitGroupModel()
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
        _networkName = dictionary[@"nw_firm_name"];
        if (_networkName.length == 0) {
            _networkName = [ATUnitGroupModel networkNameWithNetworkFirmID:_networkFirmID];
        }
        _networkRequestNum = [dictionary[@"nw_req_num"] integerValue];
        _networkDataTimeout = [dictionary[@"n_d_t"] doubleValue];
        _networkTimeout = [dictionary[@"nw_timeout"] doubleValue] / 1000.0f;
        _skipIntervalAfterLastLoadingFailure = [dictionary[@"nx_req_time"] doubleValue] / 1000.0f;
        _skipIntervalAfterLastBiddingFailure = [dictionary[@"bid_fail_interval"] doubleValue] / 1000.0f;
        _showingInterval = [dictionary[@"pacing"] doubleValue];
        _unitGroupID = [NSString stringWithFormat:@"%@", dictionary[@"ug_id"]];
        _unitID = [NSString stringWithFormat:@"%@", dictionary[@"unit_id"]];
        _price = [[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%lf",[[NSString stringWithFormat:@"%@",dictionary[@"ecpm"]] doubleValue]]] stringValue];
        _canAutoReady = [dictionary[@"irrf_sw"] integerValue] == 2;
        
        if (dictionary[@"cy_ecpm"]) {
            _ecpmByCurrency = [[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",dictionary[@"cy_ecpm"]]] stringValue];
        }

        _ecpmLevel = [dictionary[@"ecpm_level"] integerValue];
        _content = [NSJSONSerialization JSONObjectWithData:[dictionary[@"content"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        _adSize = [Utilities sizeFromString:[_content[@"size"] length] > 0 ? _content[@"size"] : [ATUnitGroupModel defaultSizeWithNetworkFirmID:_networkFirmID]];
        int value = [_content[@"zoomoutad_sw"]intValue];
        _splashZoomOut = value == 2;
        _headerBiddingRequestTimeout = [dictionary[@"hb_timeout"] doubleValue];
        _bidTokenTime = [dictionary[@"hb_t_c_t"] doubleValue] / 1000.0f;
        _headerBidding = [dictionary[@"header_bidding"] boolValue];
        _clickTkAddress = dictionary[@"t_c_u"];
        _clickTkDelayMin = [dictionary[@"t_c_u_min_t"] integerValue];
        _clickTkDelayMax = [dictionary[@"t_c_u_max_t"] integerValue];
        _statusTime = [dictionary[@"l_s_t"] doubleValue] / 1000.0f;
        _postsNotificationOnShow = [dictionary[@"s_sw"] boolValue];
        _postsNotificationOnClick = [dictionary[@"c_sw"] boolValue];
        NSString *precision = dictionary[@"precision"];
        _precision = _headerBidding ? @"exact" : ([precision isKindOfClass:[NSString class]] && [precision length] > 0 ? precision : @"publisher_defined");
    }
    return self;
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
    return [NSString stringWithFormat:@"%@", @{@"unit_group_id":_unitGroupID != nil ? _unitGroupID : @"", @"network_firm_id":@(_networkFirmID), @"adapter_class":_adapterClassString, @"ad_source_id":_unitID, @"price":_price}];
}

+(NSString*)networkNameWithNetworkFirmID:(NSInteger)nwFirmID {
    return [ATAPI networkNameMap][@(nwFirmID)] != nil ? [ATAPI networkNameMap][@(nwFirmID)] : @"";
}

@end
