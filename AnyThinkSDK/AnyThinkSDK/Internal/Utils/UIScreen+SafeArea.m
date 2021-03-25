//
//  UIScreen+SafeArea.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/28.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "UIScreen+SafeArea.h"
@implementation UIScreen (SafeArea)

+(UIEdgeInsets)safeAreaInsets {
    if (@available(iOS 11.0, *)) {
        return ([[UIApplication sharedApplication].keyWindow respondsToSelector:@selector(safeAreaInsets)] ? [UIApplication sharedApplication].keyWindow.safeAreaInsets : UIEdgeInsetsZero);
    }
    return UIEdgeInsetsZero;
}

@end
