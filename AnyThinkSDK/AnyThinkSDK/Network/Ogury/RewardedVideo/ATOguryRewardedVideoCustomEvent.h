//
//  ATOguryRewardedVideoCustomEvent.h
//  AnyThinkOguryRewardedVideoAdapter
//
//  Created by Topon on 2019/11/27.
//  Copyright © 2019 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATOguryRewardedVideoAdapter.h"
#import "ATRewardedVideoCustomEvent.h"

@interface ATOguryRewardedVideoCustomEvent :ATRewardedVideoCustomEvent<ATOguryAdsOptinVideoDelegate>
@property (nonatomic,strong)id<ATOguryAdsOptinVideo> OguryAd;
@end


