//
//  ATADXPlacementSetting.h
//  AnyThinkSDK
//
//  Created by stephen on 20/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOfferSetting.h"

@interface ATADXPlacementSetting : ATOfferSetting
-(instancetype) initWithPlacementDictionary:(NSDictionary *)placementDictionary infoDictionary:(NSDictionary *)infoDictionary  placementID:(NSString*)placementID;

@property(nonatomic, readwrite) ATClickMode clickMode;
@property(nonatomic, readwrite) ATLoadType loadType;
@property(nonatomic, readwrite) ATUserAgentType impressionUAType;
@property(nonatomic, readwrite) ATUserAgentType clickUAType;


+(instancetype) mockSetting;
@end
