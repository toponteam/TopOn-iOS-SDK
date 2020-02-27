//
//  NSObject+ATAdExpiration.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 2019/2/21.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "NSObject+ATAdExpiration.h"
#import "ATAd.h"
#import "ATUnitGroupModel.h"
@implementation NSObject (ATAdExpiration)
-(BOOL) expired {
    if ([self respondsToSelector:@selector(expireDate)]) {
        return [((id<ATAd>)self).expireDate timeIntervalSinceDate:[NSDate date]] < 0;
    } else {
        return NO;
    }
}
@end
