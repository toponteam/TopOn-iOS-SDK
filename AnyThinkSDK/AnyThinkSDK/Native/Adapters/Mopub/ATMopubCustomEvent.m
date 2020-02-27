//
//  ATMopubCustomEvent.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 16/05/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMopubCustomEvent.h"

@implementation ATMopubCustomEvent
- (UIViewController *)viewControllerForPresentingModalView {
    return [UIApplication sharedApplication].delegate.window.rootViewController;
}
@end
