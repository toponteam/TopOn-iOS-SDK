//
//  ATGDTSplashCustomEvent.h
//  AnyThinkGDTSplashAdapter
//
//  Created by Martin Lau on 2018/12/20.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATSplashCustomEvent.h"
#import "ATGDTSplashAdapter.h"

@interface ATGDTSplashCustomEvent : ATSplashCustomEvent<GDTSplashAdDelegate>
@property(nonatomic, weak) UIImageView *backgroundImageView;
@property(nonatomic) NSDate *loadStartDate;
@property(nonatomic) NSTimeInterval timeout;
@property(nonatomic, weak) UIWindow *window;
@property(nonatomic, weak) UIView *bottomView;
@property(nonatomic, weak) UIView *skipView;
@end
