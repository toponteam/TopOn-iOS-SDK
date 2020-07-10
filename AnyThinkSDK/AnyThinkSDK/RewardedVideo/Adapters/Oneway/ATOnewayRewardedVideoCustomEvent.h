//
//  ATOnewayRewardedVideoCustomEvent.h
//  AnyThinkOnewayRewardedVideoAdapter
//
//  Created by Martin Lau on 30/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATRewardedVideoCustomEvent.h"
#import "ATOnewayRewardedVideoAdapter.h"

@interface ATOnewayRewardedVideoCustomEvent : ATRewardedVideoCustomEvent<oneWaySDKRewardedAdDelegate>
-(void) showWithTag:(NSString*)tag;
@end
