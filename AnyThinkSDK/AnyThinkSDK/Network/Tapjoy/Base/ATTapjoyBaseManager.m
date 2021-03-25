//
//  ATTapjoyBaseManager.m
//  AnyThinkTapjoyAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATTapjoyBaseManager.h"
#import "Utilities.h"
#import "ATAppSettingManager.h"
#import "ATUnitGroupModel.h"
#import "ATAdAdapter.h"

NSString *const kTapjoyClassName = @"Tapjoy";
@implementation ATTapjoyBaseManager
+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[ATAPI sharedInstance] setVersion:[NSClassFromString(kTapjoyClassName) getVersion] forNetwork:kNetworkNameTapjoy];
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameTapjoy]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameTapjoy];
            if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameTapjoy]) {
                [NSClassFromString(kTapjoyClassName) setUserConsent:[ATAPI sharedInstance].networkConsentInfo[kNetworkNameTapjoy][kTapjoyConsentValueKey]];
                [NSClassFromString(kTapjoyClassName) subjectToGDPR:[[ATAPI sharedInstance].networkConsentInfo[kNetworkNameTapjoy][kTapjoyGDPRSubjectionKey] boolValue]];
            } else {
                BOOL set = NO;
                ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                if (set) {
                    /*
                    setUserConsent: 1 Personalized, 0 Nonpersonalized
                    */
                    [NSClassFromString(kTapjoyClassName) setUserConsent:limit ? @"0" : @"1"];
                    [NSClassFromString(kTapjoyClassName) subjectToGDPR:[[ATAPI sharedInstance] inDataProtectionArea]];
                }
            }
        }
        
        if ([ATAppSettingManager sharedManager].complyWithCCPA) {
            [[NSClassFromString(kTapjoyClassName) getPrivacyPolicy] setUSPrivacy:@"1YYY"];
        }
        
        if ([ATAppSettingManager sharedManager].complyWithCOPPA) {
            [[NSClassFromString(kTapjoyClassName) getPrivacyPolicy] setBelowConsentAge:YES];

        }
    });
}
@end
