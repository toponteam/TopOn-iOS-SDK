//
//  ATMintegralBaseManager.m
//  AnyThinkMintegralAdapter
//
//  Created by Topon on 11/14/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATMintegralBaseManager.h"
#import "ATAPI+Internal.h"
#import "ATAppSettingManager.h"
#import "Utilities.h"
#import "ATBidInfoManager.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"

static NSString *const kATMintegralPluginNumber = @"Y+H6DFttYrPQYcIeicKwJQKQYrN=";//topon的渠道号
@implementation ATMintegralBaseManager

+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"MTGSDK") sdkVersion] forNetwork:kNetworkNameMintegral];
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMintegral]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMintegral];
            void(^blk)(void) = ^{
                if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameMintegral]) {
                    NSDictionary *consent = [ATAPI sharedInstance].networkConsentInfo[kNetworkNameMintegral];
                    if ([consent isKindOfClass:[NSDictionary class]]) {
                        [consent enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                            [[NSClassFromString(@"MTGSDK") sharedInstance] setUserPrivateInfoType:[key integerValue] agree:[obj boolValue]];
                        }];
                    }
                } else {
                    BOOL set = NO;
                    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                    BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                    if (set) { ((id<ATMTGSDK>)[NSClassFromString(@"MTGSDK") sharedInstance]).consentStatus = !limit; }
                }
                
                Class class = NSClassFromString(@"MTGSDK");
                SEL selector = NSSelectorFromString(@"setChannelFlag:");
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    if ([class respondsToSelector:selector]) {
                        [class performSelector:selector withObject:kATMintegralPluginNumber];
                    }
                #pragma clang diagnostic pop

                [[NSClassFromString(@"MTGSDK") sharedInstance] setAppID:serverInfo[@"appid"] ApiKey:serverInfo[@"appkey"]];
            };
            if ([NSThread currentThread].isMainThread) blk();
            else dispatch_sync(dispatch_get_main_queue(), blk);
        }
    });
}

+ (void) bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMintegral]) {
        [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"MTGSDK") sdkVersion] forNetwork:kNetworkNameMintegral];
        [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMintegral];
        void(^blk)(void) = ^{
            if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameMintegral]) {
                NSDictionary *consent = [ATAPI sharedInstance].networkConsentInfo[kNetworkNameMintegral];
                if ([consent isKindOfClass:[NSDictionary class]]) {
                    [consent enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                        [[NSClassFromString(@"MTGSDK") sharedInstance] setUserPrivateInfoType:[key integerValue] agree:[obj boolValue]];
                    }];
                }
            } else {
                BOOL set = NO;
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                if (set) { ((id<ATMTGSDK>)[NSClassFromString(@"MTGSDK") sharedInstance]).consentStatus = !limit; }
            }
            
            Class class = NSClassFromString(@"MTGSDK");
            SEL selector = NSSelectorFromString(@"setChannelFlag:");
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                if ([class respondsToSelector:selector]) {
                    [class performSelector:selector withObject:kATMintegralPluginNumber];
                }
            #pragma clang diagnostic pop
            
            [[NSClassFromString(@"MTGSDK") sharedInstance] setAppID:info[@"appid"] ApiKey:info[@"appkey"]];
        };
        if ([NSThread currentThread].isMainThread) blk();
        else dispatch_sync(dispatch_get_main_queue(), blk);
    }
    
    if (NSClassFromString(@"MTGAdCustomConfig") != nil && [NSClassFromString(@"MTGAdCustomConfig") respondsToSelector:@selector(sharedInstance)] && [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] respondsToSelector:@selector(setCustomInfo:type:unitId:)]) { [[NSClassFromString(@"MTGAdCustomConfig") sharedInstance] setCustomInfo:[info[kADapterCustomInfoStatisticsInfoKey] jsonString_anythink] type:2 unitId:info[@"unitid"]]; }
    [NSClassFromString(@"MTGBiddingRequest") getBidWithRequestParameter:[[NSClassFromString(@"MTGBiddingRequestParameter") alloc] initWithPlacementId:info[@"placement_id"] unitId:info[@"unitid"] basePrice:@0] completionHandler:^(id<ATMTGBiddingResponse> bidResponse) {
        if (completion != nil) { completion(bidResponse.success ? [ATBidInfo bidInfoWithPlacementID:placementModel.placementID unitGroupUnitID:unitGroupModel.unitID token:bidResponse.bidToken price:bidResponse.price expirationInterval:unitGroupModel.bidTokenTime customObject:bidResponse] : nil, bidResponse.success ? nil : (bidResponse.error != nil ? bidResponse.error : [NSError errorWithDomain:@"com.anythink.MTGHBFailure" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Bid request has failed", NSLocalizedFailureReasonErrorKey:@"MTGSDK has failed to get bid info"}])); }
        
        if ([ATAppSettingManager sharedManager].complyWithCCPA) {
            [[NSClassFromString(@"MTGSDK") sharedInstance] setDoNotTrackStatus:YES];
        }
    }];
}

@end
