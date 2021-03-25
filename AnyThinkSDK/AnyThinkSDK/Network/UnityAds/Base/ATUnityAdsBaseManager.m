//
//  ATUnityAdsBaseManager.m
//  AnyThinkUnityAdsAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATUnityAdsBaseManager.h"
#import "Utilities.h"
#import "ATAppSettingManager.h"
#import "ATUnitGroupModel.h"
#import "ATAdAdapter.h"

@implementation ATUnityAdsBaseManager
+(void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameUnityAds]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameUnityAds];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"UnityAds") getVersion] forNetwork:kNetworkNameUnityAds];
            id playerMetaData = [[NSClassFromString(@"UADSMetaData") alloc] init];
            if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameUnityAds]) {
                [playerMetaData set:@"gdpr.consent" value:[ATAPI sharedInstance].networkConsentInfo[kNetworkNameUnityAds]];
            } else { 
                BOOL set = NO;
                ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                if (set) { [playerMetaData set:@"gdpr.consent" value:@(!limit)]; }
            }
            if ([ATAppSettingManager sharedManager].complyWithCCPA) {
                [playerMetaData set:@"privacy.consent" value:@(NO)];
            }
            [playerMetaData commit];
        }
        
    });
}
@end
