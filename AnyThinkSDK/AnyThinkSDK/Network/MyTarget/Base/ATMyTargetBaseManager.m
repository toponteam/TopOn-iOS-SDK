//
//  ATMyTargetBaseManager.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/12/25.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATMyTargetBaseManager.h"
#import "Utilities.h"
#import "ATAppSettingManager.h"

@implementation ATMyTargetBaseManager

+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMyTarget]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMyTarget];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"MTRGVersion") currentVersion] forNetwork:kNetworkNameMyTarget];
            
            // gdpr
            Class privacyClass = NSClassFromString(@"MTRGPrivacy");
            if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameMyTarget]) {
                [privacyClass setUserConsent:YES];
            } else {
                BOOL set = NO;
                ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                if (set) {
                    [privacyClass setUserConsent:limit == NO];
                }
            }
        }
    });
}

@end
