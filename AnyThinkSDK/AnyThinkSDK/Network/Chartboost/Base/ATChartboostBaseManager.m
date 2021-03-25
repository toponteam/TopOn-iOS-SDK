//
//  ATChartboostBaseManager.m
//  AnyThinkChartboostAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATChartboostBaseManager.h"
#import "ATAPI+Internal.h"
#import "ATAppSettingManager.h"

@interface ATCBDataConsentItem : NSObject<ATCHBDataUseConsent>

@end

@implementation ATCBDataConsentItem

- (NSString *)privacyStandard {
    return @"us_privacy";
}

@end

@implementation ATChartboostBaseManager
+(void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"Chartboost") getSDKVersion] forNetwork:kNetworkNameChartboost];
        if ([ATAppSettingManager sharedManager].complyWithCCPA) {
            [NSClassFromString(@"Chartboost") addDataUseConsent:[ATCBDataConsentItem new]];
        }
    });
}
@end
