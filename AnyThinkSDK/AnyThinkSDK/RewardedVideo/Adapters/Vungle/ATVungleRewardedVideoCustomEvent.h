//
//  ATVungleRewardedVideoCustomEvent.h
//  AnyThinkVungleRewardedVideoAdapter
//
//  Created by Martin Lau on 11/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATRewardedVideoCustomEvent.h"
#import "ATVungleRewardedVideoAdapter.h"
@interface ATVungleRewardedVideoCustomEvent : ATRewardedVideoCustomEvent<ATVungleSDKDelegate>
@property(nonatomic, weak) ATVungleRewardedVideoAdapter *adapter;
-(void) handlerPlayError:(NSError*)error;
@end
