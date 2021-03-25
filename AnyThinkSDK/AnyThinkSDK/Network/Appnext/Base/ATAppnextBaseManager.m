//
//  ATAppnextBaseManager.m
//  AnyThinkAppnextAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATAppnextBaseManager.h"

@implementation ATAppnextBaseManager
+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"AppnextSDKApi") getSDKVersion] forNetwork:kNetworkNameAppnext];
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameAppnext]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameAppnext];
        }
    });
}
@end
