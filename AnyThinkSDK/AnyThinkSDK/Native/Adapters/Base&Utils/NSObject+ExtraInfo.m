//
//  NSObject+ExtraInfo.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 03/05/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "NSObject+ExtraInfo.h"
#import <objc/runtime.h>
static char* unit_id_key;
@implementation NSObject (ExtraInfo)
-(NSString*)unitID {
    return objc_getAssociatedObject(self, unit_id_key);
}

-(void) setUnitID:(NSString *)unitID {
    objc_setAssociatedObject(self, unit_id_key, unitID, OBJC_ASSOCIATION_RETAIN);
}
@end
