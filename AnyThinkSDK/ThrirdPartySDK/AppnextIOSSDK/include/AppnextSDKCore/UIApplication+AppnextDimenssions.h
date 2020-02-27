//
//  UIApplication+AppnextDimenssions.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 11/02/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (AppnextDimenssions)

+ (CGFloat) getStatusBarHeightNotHidden;
+ (CGFloat) getStatusBarHeight;
+ (CGSize) sizeInOrientation:(UIInterfaceOrientation)orientation;
+ (CGRect) rectInWindowBounds:(CGRect)windowBounds statusBarOrientation:(UIInterfaceOrientation)statusBarOrientation statusBarHeight:(CGFloat)statusBarHeight;
+ (NSArray *) getApplicationSupportedUIInterfaceOrientations;
+ (UIInterfaceOrientationMask) getApplicationSupportedUIInterfaceOrientationMask;

@end
