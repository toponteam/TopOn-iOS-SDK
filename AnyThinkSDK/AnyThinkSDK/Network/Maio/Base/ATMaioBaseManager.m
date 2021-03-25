//
//  ATMaioBaseManager.m
//  AnyThinkMaioAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATMaioBaseManager.h"

NSString *const kMaioClassName = @"Maio";
@implementation ATMaioBaseManager
+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMaio]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMaio];
            if (NSClassFromString(kMaioClassName) != nil) { [[ATAPI sharedInstance] setVersion:[NSClassFromString(kMaioClassName) sdkVersion] forNetwork:kNetworkNameMaio]; }
        }
    });
}
@end
