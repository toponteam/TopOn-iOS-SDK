//
//  ATStartAppBaseManager.m
//  AnyThinkStartAppAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATStartAppBaseManager.h"
#import "Utilities.h"
#import "ATAppSettingManager.h"
#import "ATUnitGroupModel.h"
#import "ATAdAdapter.h"

@implementation ATStartAppBaseManager
+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameStartApp]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameStartApp];
            dispatch_async(dispatch_get_main_queue(), ^{
                id<ATSTAStartAppSDK> sdk = [NSClassFromString(@"STAStartAppSDK") sharedInstance];
                BOOL set = NO;
                ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                if (set) { [sdk setUserConsent:!limit forConsentType:@"pas" withTimestamp:[[NSDate date] timeIntervalSince1970]]; }
                sdk.appID = serverInfo[@"app_id"];
            });
        }
    });
}
@end
