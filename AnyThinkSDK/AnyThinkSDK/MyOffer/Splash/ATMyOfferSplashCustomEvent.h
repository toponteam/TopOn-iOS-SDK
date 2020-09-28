//
//  ATMyOfferSplashCustomEvent.h
//  AnyThinkMyOffer
//
//  Created by stephen on 8/7/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <AnyThinkSplash/AnyThinkSplash.h>
#import "ATMyOfferSplashAdapter.h"
#import "ATMyOfferSplashDelegate.h"

@interface ATMyOfferSplashCustomEvent : ATSplashCustomEvent<ATMyOfferSplashDelegate>
@property(nonatomic) UIWindow *window;
@property(nonatomic) UIView *containerView;
@property(nonatomic, weak) UIView *splashView;
@end
