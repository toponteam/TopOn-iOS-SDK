//
//  ATInmobiBaseManager.m
//  AnyThinkInmobiAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATInmobiBaseManager.h"
#import "ATAppSettingManager.h"
#import "ATUnitGroupModel.h"

NSString *const ATInMobiBuyerPriceKey = @"buyerPrice";
NSString *const kATInmobiSDKInitedNotification = @"com.anythink.InMobiInitNotification";

//NSString *const ATInMobiBidTokenKey = @"ctxHash";

@implementation ATInmobiBaseManager
+(void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"IMSdk") getVersion] forNetwork:kNetworkNameInmobi];
        
    });
}

+ (void)checkInitiationStatusWithServerInfo:(NSDictionary *)serverInfo requestItem:(ATInmobiBiddingRequest *)request {
    if (NSClassFromString(@"IMInterstitial") != nil && NSClassFromString(@"IMSdk") != nil) {
        BOOL set = NO;
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[@"tracking_info_unit_group_model"];
        BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
        if (set) { [NSClassFromString(@"IMSdk") updateGDPRConsent:@{@"gdpr_consent_available":limit ? @"false" : @"true", @"gdpr":[[ATAPI sharedInstance] inDataProtectionArea] ? @"1" : @"0"}]; }
        [NSClassFromString(@"IMSdk") initWithAccountID:serverInfo[@"app_id"] andCompletionHandler:^(NSError *error) {
            if (error == nil) {
                [[ATAPI sharedInstance] setInitFlag:2 forNetwork:kNetworkNameInmobi];
                [[NSNotificationCenter defaultCenter] postNotificationName:kATInmobiSDKInitedNotification object:nil];
            } else {
                request.bidCompletion(nil, error);
            }
        }];
    }
}
@end

@implementation ATInmobiBiddingRequest
@end
