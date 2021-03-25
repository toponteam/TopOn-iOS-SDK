//
//  ATVungleBaseManager.m
//  AnyThinkVungleAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATVungleBaseManager.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAppSettingManager.h"
#import "ATUnitGroupModel.h"
#import "ATAdAdapter.h"

@implementation ATVungleBaseManager
+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameVungle];
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameVungle]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameVungle];
            if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameVungle]) {
                [((id<ATVungleSDK>)[NSClassFromString(@"VungleSDK") sharedSDK]) updateConsentStatus:[[ATAPI sharedInstance].networkConsentInfo[kNetworkNameVungle] integerValue] consentMessageVersion:@"6.8.0"];
            } else {
                BOOL set = NO;
                ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                if (set) { [((id<ATVungleSDK>)[NSClassFromString(@"VungleSDK") sharedSDK]) updateConsentStatus:limit ? 2 : 1 consentMessageVersion:@"6.8.0"]; }
            }
        }
        if ([ATAppSettingManager sharedManager].complyWithCCPA) {
            [[NSClassFromString(@"VungleSDK") sharedSDK] updateCCPAStatus:2];
        }
    });
}
@end
