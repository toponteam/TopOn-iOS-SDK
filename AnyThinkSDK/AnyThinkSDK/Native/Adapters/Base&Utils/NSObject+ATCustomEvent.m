//
//  NSObject+ATCustomEvent.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 25/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "NSObject+ATCustomEvent.h"
#import <objc/runtime.h>
static char *custom_event_key;
@implementation NSObject (ATCustomEvent)
-(void) setCustomEvent:(id)customEvent {
    objc_setAssociatedObject(self, custom_event_key, customEvent, OBJC_ASSOCIATION_RETAIN);
}

-(id) customEvent {
    return objc_getAssociatedObject(self, custom_event_key);
}
@end
