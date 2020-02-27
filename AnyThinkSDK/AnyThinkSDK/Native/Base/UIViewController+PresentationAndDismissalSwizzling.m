//
//  UIViewController+PresentationAndDismissalSwizzling.m
//  ATSDKDemo
//
//  Created by Martin Lau on 2019/5/20.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "UIViewController+PresentationAndDismissalSwizzling.h"
#import <objc/runtime.h>
NSString *const kATUIViewControllerPresentationNotification = @"com.anythink.ViewControllerPresentation";
NSString *const kATUIViewControllerDismissalNotification = @"com.anythink.ViewControllerDismissal";
NSString *const kATUIViewControllerPresentationDismissalNotificationUserInfoPresentingViewControllerKey = @"presenting_view_controller";
NSString *const kATUIViewControllerPresentationDismissalNotificationUserInfoPresentedViewControllerKey = @"presented_view_controller";
@implementation UIViewController (PresentationAndDismissalSwizzling)
+(void) swizzleMethods {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethodWithSelector:@selector(presentViewController:animated:completion:) swizzledMethodSelector:@selector(ATSplash_presentViewController:animated:completion:) inClass:[UIViewController class]];
        [self swizzleMethodWithSelector:@selector(dismissViewControllerAnimated:completion:) swizzledMethodSelector:@selector(ATSplash_dismissViewControllerAnimated:completion:) inClass:[UIViewController class]];
    });
}

+(void) swizzleMethodWithSelector:(SEL)originalSel swizzledMethodSelector:(SEL)swizzledMethodSel inClass:(Class)inClass {
    if (originalSel != NULL && swizzledMethodSel != NULL && inClass != nil) {
        Method originalMethod = class_getInstanceMethod(inClass, originalSel);
        Method swizzledMethod = class_getInstanceMethod(inClass, swizzledMethodSel);
        
        BOOL didAddMethod = class_addMethod(inClass, originalSel, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(inClass, swizzledMethodSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    }
}

-(void)ATSplash_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    [[NSNotificationCenter defaultCenter] postNotificationName:kATUIViewControllerPresentationNotification object:nil userInfo:@{kATUIViewControllerPresentationDismissalNotificationUserInfoPresentingViewControllerKey:self, kATUIViewControllerPresentationDismissalNotificationUserInfoPresentedViewControllerKey:viewControllerToPresent}];
    [self ATSplash_presentViewController:viewControllerToPresent animated:flag completion:completion];
}

-(void) ATSplash_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [[NSNotificationCenter defaultCenter] postNotificationName:kATUIViewControllerDismissalNotification object:nil userInfo:@{kATUIViewControllerPresentationDismissalNotificationUserInfoPresentingViewControllerKey:self}];
    [self ATSplash_dismissViewControllerAnimated:flag completion:completion];
}
@end
