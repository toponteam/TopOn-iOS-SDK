//
//  ATKSBaseManager.m
//  AnyThinkKuaiShouAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATKSBaseManager.h"

@implementation ATKSBaseManager
+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameKS]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameKS];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"KSAdSDKManager") SDKVersion] forNetwork:kNetworkNameKS];
            [NSClassFromString(@"KSAdSDKManager") setAppId:serverInfo[@"app_id"]];
        }
    });
}
@end
