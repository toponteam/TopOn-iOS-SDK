//
//  ATChartboostRewardedVideoCustomEvent.h
//  AnyThinkChartboostRewardedVideoAdapter
//
//  Created by Martin Lau on 10/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATRewardedVideoCustomEvent.h"
#import "ATChartboostRewardedVideoAdapter.h"
@interface ATChartboostRewardedVideoCustomEvent : ATRewardedVideoCustomEvent<CHBRewardedDelegate>
@property(nonatomic, weak) id<ATCHBRewarded> rewardedVideoAd;
@end
