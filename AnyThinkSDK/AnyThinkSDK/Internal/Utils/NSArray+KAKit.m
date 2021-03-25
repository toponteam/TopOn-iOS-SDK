//
//  NSArray+KAKit.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/15.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "NSArray+KAKit.h"

@implementation NSArray (KAKit)

- (instancetype)optional {
    return self ? self : @[];
}
@end
