//
//  ATMopubBaseManager.m
//  AnyThinkMopubAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATMopubBaseManager.h"
#import "Utilities.h"
#import "ATAppSettingManager.h"
#import "ATUnitGroupModel.h"
#import "ATAdAdapter.h"

@implementation ATMopubBaseManager
+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        id<ATMoPub> mopub = [NSClassFromString(@"MoPub") sharedInstance];
        [[ATAPI sharedInstance] setVersion:[mopub version] forNetwork:kNetworkNameMopub];
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMopub]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMopub];
            if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameMopub]) {
                if ([[ATAPI sharedInstance].networkConsentInfo[kNetworkNameMopub] boolValue]) {
                    [mopub grantConsent];
                } else {
                    [mopub revokeConsent];
                }
            } else {
                BOOL set = NO;
                ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                if (set) {
                    if (limit) {
                        [mopub grantConsent];
                    } else {
                        [mopub revokeConsent];
                    }
                }
            }
        }
    });
}
@end
