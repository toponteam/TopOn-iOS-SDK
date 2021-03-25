//
//  ATIronsourceBaseManager.m
//  AnyThinkIronSourceAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATIronsourceBaseManager.h"
#import "Utilities.h"
#import "ATAppSettingManager.h"
#import "ATUnitGroupModel.h"
#import "ATAdAdapter.h"

NSString *const kIronSourceClassName = @"IronSource";
@implementation ATIronsourceBaseManager
+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameIronSource]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameIronSource];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(kIronSourceClassName) sdkVersion] forNetwork:kNetworkNameIronSource];
            if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameIronSource]) {
                [NSClassFromString(kIronSourceClassName) setConsent:[[ATAPI sharedInstance].networkConsentInfo[kNetworkNameIronSource] boolValue]];
            } else {
                BOOL set = NO;
                ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                if (set) { [NSClassFromString(kIronSourceClassName) setConsent:!limit]; }
            }
        }

        if ([ATAppSettingManager sharedManager].complyWithCCPA) {
            [NSClassFromString(kIronSourceClassName) setMetaDataWithKey:@"do_not_sell" value:@"YES"];
        }
    });
}
@end
