//
//  NSData+KAKit.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/16.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "NSData+KAKit.h"

@implementation NSData (KAKit)

- (NSDictionary *)dictionary {
    id some = [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingMutableContainers error:nil];
    if ([some isKindOfClass:[NSDictionary  class]]) {
        return some;
    }
    return nil;
}
@end
