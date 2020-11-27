//
//  ATADXRewardedVideoCustomEvent.h
//  AnyThinkSDK
//
//  Created by stephen on 20/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATRewardedVideoCustomEvent.h"
#import "ATADXRewardedVideoAdapter.h"
#import "ATADXAdLoadingDelegate.h"
#import "ATADXRewardedVideoDelegate.h"
#import "ATPlacementModel.h"
#import "ATUnitGroupModel.h"


@interface ATADXRewardedVideoCustomEvent : ATRewardedVideoCustomEvent <ATADXRewardedVideoDelegate, ATADXAdLoadingDelegate>

@property(nonatomic, readwrite) ATPlacementModel *placementModel;
@property(nonatomic, readwrite) ATUnitGroupModel *unitGroupModel;
@property(nonatomic) NSString *price;
@end
