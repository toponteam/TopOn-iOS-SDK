//
//  ATHeliumRewardedVideoCustomEvent.m
//  AnyThinkChartboostRewardedVideoAdapter
//
//  Created by stephen on 7/9/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATHeliumRewardedVideoCustomEvent.h"
#import "ATHeliumRewardedVideoAdapter.h"
#import "Utilities.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI.h"
#import "ATBidInfo.h"



@interface ATHeliumRewardedVideoCustomEvent()
@property (nonatomic, weak) ATHeliumRewardedVideoAdapter *adapter;
@end
@implementation ATHeliumRewardedVideoCustomEvent



- (NSString *)networkUnitId {
    return self.serverInfo[@"placement_name"];
}

@end
