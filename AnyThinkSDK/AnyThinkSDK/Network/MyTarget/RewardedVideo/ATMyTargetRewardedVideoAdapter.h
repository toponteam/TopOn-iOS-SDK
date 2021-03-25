//
//  ATMyTargetRewardedVideoAdapter.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/12/25.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ATMyTargetRewardedVideoCustomEvent;
@interface ATMyTargetRewardedVideoAdapter : NSObject

@property(nonatomic, readonly) ATMyTargetRewardedVideoCustomEvent *customEvent;

@end

NS_ASSUME_NONNULL_END
