//
//  NSObject+KAKit.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/16.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "NSObject+KAKit.h"
#import "NSArray+KAKit.h"
#import "NSDictionary+KAKit.h"
#import "NSString+KAKit.h"

static NSString *const kTimerUserInfoBlockKey = @"com.anythink.adx_splash_timer_block";

@implementation NSObject (KAKit)

- (BOOL)isDictionary {
    return [self isKindOfClass:[NSDictionary class]];
}

- (BOOL)isString {
    return [self isKindOfClass:[NSString class]];
}

- (BOOL)isArray {
    return [self isKindOfClass:[NSArray class]];
}

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)interval target:(id)target repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block {
    return [NSTimer scheduledTimerWithTimeInterval:interval target:target selector:@selector(timerHandler_anythink_myoffer:) userInfo:@{kTimerUserInfoBlockKey:[block copy]} repeats:repeats];
}

- (void)timerHandler_anythink_myoffer:(NSTimer *)timer {
    void (^block)(NSTimer*) = timer.userInfo[kTimerUserInfoBlockKey];
    if (block != nil) {
        block(timer);
    }
}

- (id)optional {
    if (self.isArray) {
        return (NSArray *)self.optional;
    }
    
    if (self.isString) {
        return (NSString *)self.optional;
    }
    
    if (self.isDictionary) {
        return (NSDictionary *)self.optional;
    }
    return self;
}


@end
