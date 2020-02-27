//
//  UIViewController+AdObjectAssociation.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 2018/10/17.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "UIViewController+AdObjectAssociation.h"
#import <objc/runtime.h>
@implementation UIViewController (AdObjectAssociation)
static NSString *const kAdKey = @"com.anythink.AD";
-(void) setAd:(id)ad {
    if (ad != nil) objc_setAssociatedObject(self, (__bridge_retained void*)kAdKey, ad, OBJC_ASSOCIATION_RETAIN);
}

-(id)ad {
    return objc_getAssociatedObject(self, (__bridge_retained void*)kAdKey);
}
@end
