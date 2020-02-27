//
//  UIViewController+PresentationAndDismissalSwizzling.h
//  ATSDKDemo
//
//  Created by Martin Lau on 2019/5/20.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kATUIViewControllerPresentationNotification;
extern NSString *const kATUIViewControllerDismissalNotification;
extern NSString *const kATUIViewControllerPresentationDismissalNotificationUserInfoPresentingViewControllerKey;
extern NSString *const kATUIViewControllerPresentationDismissalNotificationUserInfoPresentedViewControllerKey;
@interface UIViewController (PresentationAndDismissalSwizzling)
+(void) swizzleMethods;
@end
