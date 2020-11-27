//
//  ATOfferSetting.h
//  AnyThinkSDK
//
//  Created by stephen on 26/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATModel.h"

@interface ATOfferSetting : ATModel
-(instancetype) initWithDictionary:(NSDictionary *)dictionary;

@property(nonatomic, readwrite) NSString *placementID;
@property(nonatomic, readwrite) NSInteger format;
@property(nonatomic, readwrite) ATVideoClickable videoClickable;
@property(nonatomic, readwrite) NSTimeInterval resourceDownloadTimeout;
@property(nonatomic, readwrite) NSTimeInterval bannerAppearanceInterval;
@property(nonatomic, readwrite) ATEndCardClickable endCardClickable;
@property(nonatomic, readwrite) BOOL unMute;
@property(nonatomic, readwrite) NSTimeInterval closeButtonAppearanceInterval;
@property(nonatomic, readwrite) ATLoadStorekitTime storekitTime;



@end


