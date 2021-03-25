//
//  ATGDTBaseManager.m
//  AnyThinkGDTAdapter
//
//  Created by Topon on 11/11/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATGDTBaseManager.h"
#import "ATAPI+Internal.h"
#import "ATAdManager.h"

@implementation ATGDTBaseManager

+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameGDT]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameGDT];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"GDTSDKConfig") sdkVersion] forNetwork:kNetworkNameGDT];
            [NSClassFromString(@"GDTSDKConfig") registerAppId:serverInfo[@"app_id"]];
            BOOL enable = ([localInfo isKindOfClass:[NSDictionary class]] && [localInfo[kATAdLoadingExtraGDTEnableDefaultAudioSessionKey] boolValue]) ? [localInfo[kATAdLoadingExtraGDTEnableDefaultAudioSessionKey] boolValue] : NO;
            [NSClassFromString(@"GDTSDKConfig") enableDefaultAudioSessionSetting:enable];
        }
    });
}

@end
