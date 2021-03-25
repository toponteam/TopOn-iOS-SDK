//
//  ATPangleBaseManager.m
//  AnyThinkPangleAdapter
//
//  Created by Topon on 11/11/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATPangleBaseManager.h"
#import "ATAPI+Internal.h"
#import "ATAppSettingManager.h"
@implementation ATPangleBaseManager

+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameTT]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameTT];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"BUAdSDKManager") SDKVersion] forNetwork:kNetworkNameTT];
            [NSClassFromString(@"BUAdSDKManager") setAppID:serverInfo[@"app_id"]];
            if ([ATAppSettingManager sharedManager].complyWithCOPPA) {
                [NSClassFromString(@"BUAdSDKManager") setCoppa:1];
            }
        }
    });
}

@end
