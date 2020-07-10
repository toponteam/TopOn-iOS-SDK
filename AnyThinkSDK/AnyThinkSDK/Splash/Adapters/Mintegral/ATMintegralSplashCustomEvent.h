//
//  ATMintegralSplashCustomEvent.h
//  AnyThinkMintegralSplashAdapter
//
//  Created by Martin Lau on 2020/6/9.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATSplashCustomEvent.h"
#import "ATMintegralSplashAdapter.h"
@interface ATMintegralSplashCustomEvent : ATSplashCustomEvent<MTGSplashADDelegate>
@property(nonatomic, weak) UIWindow *window;
@property(nonatomic, weak) UIView *containerView;
@property(nonatomic) NSDate *loadStartingDate;
@property(nonatomic) NSTimeInterval timeRemaining;
@end
