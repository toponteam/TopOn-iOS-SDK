//
//  ATMobrainBaseManager.m
//  AnyThinkMobrainAdapter
//
//  Created by Topon on 2/1/21.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import "ATMobrainBaseManager.h"

@implementation ATMobrainBaseManager

+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"ABUAdSDKManager") SDKVersion] forNetwork:kNetworkNameMobrain];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMobrain]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMobrain];
                Class abuSDKClass = NSClassFromString(@"ABUAdSDKManager");
                if(abuSDKClass != nil){
                    [abuSDKClass setAppID:serverInfo[@"app_id"]];
//                    [abuSDKClass setLoglevel:ABUAdSDKLogLevelDebug language:ABUAdSDKLogLanguageCH];
                }
            }
        });
    });
}

@end
