//
//  ATFyberRewardedVideoCustomEvent.h
//  AnyThinkFyberRewardedVideoAdapter
//
//  Created by Topon on 2020/4/9.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATRewardedVideoCustomEvent.h"
#import "ATFyberRewardedVideoAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATFyberRewardedVideoCustomEvent : ATRewardedVideoCustomEvent<IAVideoContentDelegate,IAUnitDelegate,IAMRAIDContentDelegate>
@property (weak, nonatomic) UIViewController *viewController;
@property (nonatomic) id<ATIAFullscreenUnitController> fullscreenUnitController;
@end

NS_ASSUME_NONNULL_END
