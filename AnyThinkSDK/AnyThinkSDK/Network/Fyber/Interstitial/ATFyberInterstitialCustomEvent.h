//
//  ATFyberInterstitialCustomEvent.h
//  AnyThinkFyberInterstitialAdapter
//
//  Created by Topon on 2020/4/9.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATInterstitialCustomEvent.h"
#import "ATFyberInterstitialAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATFyberInterstitialCustomEvent : ATInterstitialCustomEvent<IAVideoContentDelegate,IAMRAIDContentDelegate,IAUnitDelegate>
@property (weak, nonatomic) UIViewController *viewController;
@property(nonatomic) id<ATIAFullscreenUnitController> fullscreenUnitController;

@end

NS_ASSUME_NONNULL_END
