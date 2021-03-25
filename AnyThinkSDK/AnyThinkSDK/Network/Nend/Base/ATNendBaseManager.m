//
//  ATNendBaseManager.m
//  AnyThinkNendAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATNendBaseManager.h"

@implementation ATNendBaseManager
+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameNend]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameNend];
            [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameNend];
        }
    });
}
@end
