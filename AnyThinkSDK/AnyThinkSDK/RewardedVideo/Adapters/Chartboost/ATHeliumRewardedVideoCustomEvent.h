//
//  ATHeliumRewardedVideoCustomEvent.h
//  AnyThinkChartboostRewardedVideoAdapter
//
//  Created by stephen on 7/9/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATRewardedVideoCustomEvent.h"
#import "ATHeliumRewardedVideoAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATHeliumRewardedVideoCustomEvent : ATRewardedVideoCustomEvent
@property(nonatomic, weak) id<HeliumRewardedAd> rewardedAd;
@property(nonatomic, weak) ATPlacementModel *placementModel;
@property(nonatomic, weak) ATUnitGroupModel *unitGroupModel;
@property(nonatomic, copy) void(^BidCompletionBlock)(ATBidInfo *bidInfo, NSError *error);
@end

NS_ASSUME_NONNULL_END
