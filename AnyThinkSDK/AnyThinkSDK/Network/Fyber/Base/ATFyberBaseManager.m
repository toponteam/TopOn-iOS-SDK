//
//  ATFyberBaseManager.m
//  AnyThinkFyberAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATFyberBaseManager.h"
#import "ATAppSettingManager.h"
@implementation ATFyberBaseManager
+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameFyber]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameFyber];
            [[ATAPI sharedInstance] setVersion:((id<ATIASDKCore>)[NSClassFromString(@"IASDKCore") sharedInstance]).version forNetwork:kNetworkNameFyber];
            [[NSClassFromString(@"IASDKCore") sharedInstance] initWithAppID:serverInfo[@"app_id"]];
            if ([ATAppSettingManager sharedManager].complyWithCCPA) {
                ((id<ATIASDKCore>)[NSClassFromString(@"IASDKCore") sharedInstance]).CCPAString = @"1YNN";
            }
        }
    });
}
@end
