//
//  ATOfferSetting.m
//  AnyThinkSDK
//
//  Created by stephen on 26/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOfferSetting.h"

NSString *const kATOfferTrackerExtraLifeCircleID = @"life_circle_id";
NSString *const kATOfferTrackerExtraScene = @"scene";

NSString *const kATOfferTrackerGDTClickID = @"__CLICK_ID__";
NSString *const kATOfferTrackerGDTWidth = @"__WIDTH__";
NSString *const kATOfferTrackerGDTHeight = @"__HEIGHT__";
NSString *const kATOfferTrackerGDTDownX = @"__DOWN_X__";
NSString *const kATOfferTrackerGDTDownY = @"__DOWN_Y__";
NSString *const kATOfferTrackerGDTUpX = @"__UP_X__";
NSString *const kATOfferTrackerGDTUpY = @"__UP_Y__";
NSString *const kATOfferTrackerGDTRequestWidth = @"__REQ_WIDTH__";
NSString *const kATOfferTrackerGDTRequestHeight = @"__REQ_HEIGHT__";

NSString *const kATOfferTrackerRelativeDownX = @"__RE_DOWN_X__";
NSString *const kATOfferTrackerRelativeDownY = @"__RE_DOWN_Y__";
NSString *const kATOfferTrackerRelativeUpX = @"__RE_UP_X__";
NSString *const kATOfferTrackerRelativeUpY = @"__RE_UP_Y__";
NSString *const kATOfferTrackerTimestamp = @"__TS__";
NSString *const kATOfferTrackerMilliTimestamp = @"__TS_MSEC__";
NSString *const kATOfferTrackerEndTimestamp = @"__END_TS__";
NSString *const kATOfferTrackerEndMilliTimestamp = @"__END_TS_MSEC__";
NSString *const kATOfferTrackerVideoTimePlayed = @"__PLAY_SEC__";
NSString *const kATOfferTrackerVideoMilliTimePlayed = @"__PLAY_MSEC__";

@implementation ATOfferSetting
-(instancetype) initWithDictionary:(NSDictionary *)dictionary  {
    self = [super initWithDictionary:dictionary];
    
    return self;
}

@end
