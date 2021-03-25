//
//  ATAdmobBaseManager.m
//  AnyThinkAdmobAdapter
//
//  Created by Topon on 11/13/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATAdmobBaseManager.h"
#import "ATAPI+Internal.h"
#import "ATAdManager+Banner.h"
#import "Utilities.h"
#import "ATAppSettingManager.h"

@implementation ATAdmobBaseManager

+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
    
            [[ATAPI sharedInstance] setVersion:[[NSClassFromString(@"GADMobileAds") sharedInstance] sdkVersion] forNetwork:kNetworkNameAdmob];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameAdmob]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameAdmob];
                id<ATPACConsentInformation> consentInfo = [NSClassFromString(@"PACConsentInformation") sharedInstance];
                if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameAdmob]) {
                    consentInfo.consentStatus = [[ATAPI sharedInstance].networkConsentInfo[kNetworkNameAdmob][kAdmobConsentStatusKey] integerValue];
                    consentInfo.tagForUnderAgeOfConsent = [[ATAPI sharedInstance].networkConsentInfo[kNetworkNameAdmob][kAdmobUnderAgeKey] boolValue];
                } else {
                    BOOL set = NO;
                    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                    BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                    if (set) { consentInfo.consentStatus = limit ? ATPACConsentStatusNonPersonalized : ATPACConsentStatusPersonalized; }
                }
            }
            
            if ([ATAppSettingManager sharedManager].complyWithCCPA) {
                [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"gad_rdp"];
            }
            
            Class gadClass = NSClassFromString(@"GADMobileAds");
            if ([ATAppSettingManager sharedManager].complyWithCOPPA && gadClass) {
                [[[gadClass sharedInstance] requestConfiguration] tagForChildDirectedTreatment:YES];
            }
        });
    });
}


+ (void)initGoogleAdManagerWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ATAPI sharedInstance] setVersion:[[NSClassFromString(@"GADMobileAds") sharedInstance] sdkVersion] forNetwork:kNetworkNameGoogleAdManager];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameGoogleAdManager]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameGoogleAdManager];
            }
        });
    });
}

@end
