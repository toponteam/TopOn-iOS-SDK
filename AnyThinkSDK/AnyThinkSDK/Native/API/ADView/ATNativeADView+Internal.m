//
//  ATNativeADView+Internal.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 03/05/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATNativeADView+Internal.h"
#import <objc/runtime.h>

static char *custom_event_key;
@implementation ATNativeADView (Internal)
-(ATNativeADCustomEvent*)customEvent {
    return objc_getAssociatedObject(self, custom_event_key);
}

-(void) setCustomEvent:(ATNativeADCustomEvent *)customEvent {
    objc_setAssociatedObject(self, custom_event_key, customEvent, OBJC_ASSOCIATION_RETAIN);
}
@end
