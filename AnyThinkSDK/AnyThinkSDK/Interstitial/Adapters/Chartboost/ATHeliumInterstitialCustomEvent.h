//
//  ATHeliumInterstitialCustomEvent.h
//  AnyThinkChartboostInterstitialAdapter
//
//  Created by stephen on 7/9/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATInterstitialCustomEvent.h"
#import "ATHeliumInterstitialAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATHeliumInterstitialCustomEvent : ATInterstitialCustomEvent
@property(nonatomic, weak) id<HeliumInterstitialAd> interstitialAd;
@property(nonatomic, weak) ATPlacementModel *placementModel;
@property(nonatomic, weak) ATUnitGroupModel *unitGroupModel;
@property(nonatomic, copy) void(^BidCompletionBlock)(ATBidInfo *bidInfo, NSError *error);
@end

NS_ASSUME_NONNULL_END
