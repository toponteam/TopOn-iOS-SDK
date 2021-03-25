//
//  ATBaiduBaseManager.m
//  AnyThinkBaiduAdapter
//
//  Created by Topon on 11/15/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATBaiduBaseManager.h"
#import "ATAPI+Internal.h"

@implementation ATBaiduBaseManager
+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameBaidu];
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameBaidu]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameBaidu];
            id<ATBaiduMobAdSetting> setting = [NSClassFromString(@"BaiduMobAdSetting") sharedInstance];
            setting.supportHttps = YES;
            [NSClassFromString(@"BaiduMobAdSetting") setMaxVideoCacheCapacityMb:30];
        }
    });
}
@end
