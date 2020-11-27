//
//  ATHeliumInterstitialCustomEvent.m
//  AnyThinkChartboostInterstitialAdapter
//
//  Created by stephen on 7/9/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATHeliumInterstitialCustomEvent.h"
#import "ATHeliumInterstitialAdapter.h"

@interface ATHeliumInterstitialCustomEvent()
@property (nonatomic, weak) ATHeliumInterstitialAdapter *adapter;
@end
@implementation ATHeliumInterstitialCustomEvent

- (NSString *)networkUnitId {
    return self.serverInfo[@"placement_name"];
}

@end
