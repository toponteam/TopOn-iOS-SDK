//
//  UIView+AppnextOrientation.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 17/02/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AppnextOrientation)

- (BOOL) isInFront;

#pragma mark - Helper methods

BOOL interfaceOrientationsIsForSameAxis(UIInterfaceOrientation o1, UIInterfaceOrientation o2);
CGFloat interfaceOrientationAngleBetween(UIInterfaceOrientation o1, UIInterfaceOrientation o2);
CGFloat interfaceOrientationAngleOfOrientation(UIInterfaceOrientation orientation);
UIInterfaceOrientationMask interfaceOrientationMaskFromOrientation(UIInterfaceOrientation orientation);

@end
