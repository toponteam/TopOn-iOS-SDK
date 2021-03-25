//
//  ATSigmobBaseManager.m
//  AnyThinkSigmobAdapter
//
//  Created by Topon on 11/15/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATSigmobBaseManager.h"
#import "ATAPI+Internal.h"

@implementation ATSigmobBaseManager
+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameSigmob]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameSigmob];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"WindAds") sdkVersion] forNetwork:kNetworkNameSigmob];
            id<ATWindAdOptions> options = [[NSClassFromString(@"WindAdOptions") alloc]initWithAppId:serverInfo[@"app_id"] appKey:serverInfo[@"app_key"] usedMediation:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSClassFromString(@"WindAds") startWithOptions:options];
            });
        }
    });
}
@end
