//
//  NSObject+KAKit.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/16.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (KAKit)
- (BOOL)isDictionary;
- (BOOL)isString;
- (BOOL)isArray;
- (id)optional;

- (void)timerHandler_anythink_myoffer:(NSTimer*)timer;

//todo
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)interval target:(id)target repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block;

@end


