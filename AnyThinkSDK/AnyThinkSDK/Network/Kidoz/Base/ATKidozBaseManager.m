//
//  ATKidozBaseManager.m
//  AnyThinkKidozAdapter
//
//  Created by Topon on 12/23/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATKidozBaseManager.h"

@implementation ATKidozBaseManager

+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameKidoz]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameKidoz];
            [[ATAPI sharedInstance] setVersion:[[NSClassFromString(@"KidozSDK") instance] getSdkVersion] forNetwork:kNetworkNameKidoz];
        }
    });
}

@end
