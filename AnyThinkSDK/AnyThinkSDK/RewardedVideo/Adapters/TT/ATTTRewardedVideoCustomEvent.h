//
//  ATTTRewardedVideoCustomEvent.h
//  AnyThinkTTRewardedVideoAdapter
//
//  Created by Martin Lau on 14/08/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATRewardedVideoCustomEvent.h"
#import "ATTTRewardedVideoAdapter.h"
@interface ATTTRewardedVideoCustomEvent : ATRewardedVideoCustomEvent<BURewardedVideoAdDelegate>
@property (nonatomic) BOOL isFailed;
@end
