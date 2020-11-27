//
//  ATMintegralRewardedVideoCustomEvent.h
//  AnyThinkMintegralRewardedVideoAdapter
//
//  Created by Martin Lau on 05/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATRewardedVideoCustomEvent.h"
#import "ATMintegralRewardedVideoAdapter.h"
@interface ATMintegralRewardedVideoCustomEvent : ATRewardedVideoCustomEvent<ATRVMTGRewardAdLoadDelegate, ATRVMTGRewardAdShowDelegate>
@property(nonatomic, weak) id rewardedVideoMgr;
@property(nonatomic) NSString *price;
@end
