//
//  ATAdcolonyBaseManager.m
//  AnyThinkAdColonyAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATAdcolonyBaseManager.h"

@implementation ATAdcolonyBaseManager
+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"AdColony") getSDKVersion] forNetwork:kNetworkNameAdColony];
    });
}
@end
