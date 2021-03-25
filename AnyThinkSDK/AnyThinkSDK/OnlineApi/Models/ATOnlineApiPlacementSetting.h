//
//  ATOnlineApiPlacementSetting.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/19.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <AnyThinkSDK/AnyThinkSDK.h>


@interface ATOnlineApiPlacementSetting : ATOfferSetting

-(instancetype) initWithPlacementDictionary:(NSDictionary *)placementDictionary infoDictionary:(NSDictionary *)infoDictionary  placementID:(NSString*)placementID;

+(instancetype) mockSetting;

@end

