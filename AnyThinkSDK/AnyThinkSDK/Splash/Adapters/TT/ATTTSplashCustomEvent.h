//
//  ATTTSplashCustomEvent.h
//  AnyThinkTTSplashAdapter
//
//  Created by Martin Lau on 2018/12/21.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATSplashCustomEvent.h"
#import "ATTTSplashAdapter.h"
#import <UIKit/UIKit.h>
@interface ATTTSplashCustomEvent : ATSplashCustomEvent<BUSplashAdDelegate>
@property(nonatomic, weak) UIView *containerView;
@property(nonatomic, weak) UIView *ttSplashView;
@property(nonatomic, weak) UIWindow *window;
@property(nonatomic, weak) UIImageView *backgroundImageView;
@property(nonatomic) NSDate *expireDate;
@end
