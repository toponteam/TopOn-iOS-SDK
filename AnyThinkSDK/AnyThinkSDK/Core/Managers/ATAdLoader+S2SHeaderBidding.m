//
//  ATAdLoader+S2SHeaderBidding.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 2020/5/26.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATAdLoader+S2SHeaderBidding.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATNetworkingManager.h"
#import "ATAppSettingManager.h"
#import "ATAPI+Internal.h"
#import "ATPlacementSettingManager.h"

@implementation ATAdLoader (S2SHeaderBidding)
+(void) sendS2SBidRequestWithPlacementModel:(ATPlacementModel*)placementModel headerBiddingUnitGroups:(NSArray<ATUnitGroupModel*>*)headerBiddingUnitGroups requestID:(NSString*)requestID completion:(void(^)(NSDictionary<NSString*, ATBidInfo*>*bidInfos, NSDictionary<NSString*, NSError*>*errors))completion {
    NSString *pStr = [[[ATAdLoader parametersWithPlacementModel:placementModel] jsonString_anythink] stringByBase64Encoding_anythink];
    NSString *p2Str = [[[ATAdLoader parameter2] jsonString_anythink] stringByBase64Encoding_anythink];
    NSString *hbListStr = [[[ATAdLoader headerBiddingListParameterWithUnitGroups:headerBiddingUnitGroups] jsonString_anythink] stringByBase64Encoding_anythink];
    NSString *chInfoStr = [[[ATAdLoader statisticsInfoWithPlacementModel:placementModel unitGroupModel:nil finalWaterfall:nil requestID:requestID bidRequest:YES] jsonString_anythink] stringByBase64Encoding_anythink];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:pStr, @"p", p2Str, @"p2", hbListStr, @"hb_list", requestID, @"request_id", chInfoStr, @"ch_info", nil];
    
    [[ATNetworkingManager sharedManager] sendHTTPRequestToAddress:placementModel.S2SBidRequestAddress HTTPMethod:ATNetworkingHTTPMethodPOST parameters:para gzip:NO completion:^(NSData * _Nonnull data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __block NSDictionary *responseObject = nil;
        //AT_SafelyRun is used to guard against exception that's beyond our precaution, which includes the nullability of responseData.
        AT_SafelyRun(^{ responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil]; });
        if ([responseObject isKindOfClass:[NSDictionary class]] && [responseObject[@"data"] isKindOfClass:[NSArray class]]) {
            if (completion != nil) {
                NSMutableDictionary<NSString*, ATUnitGroupModel*>* ugMap = [NSMutableDictionary<NSString*, ATUnitGroupModel*> dictionary];
                [headerBiddingUnitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { ugMap[obj.content[@"unitid"]] = obj; }];
                NSArray<NSDictionary*>* dataArr = responseObject[@"data"];
                NSMutableDictionary <NSString*, ATBidInfo*>*bidInfos = [NSMutableDictionary<NSString*, ATBidInfo*> dictionary];
                NSMutableDictionary<NSString*, NSError*>* errors = [NSMutableDictionary<NSString*, NSError*> dictionary];
                [dataArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj[@"is_success"] boolValue]) {
                        ATBidInfo *bidInfo = [[ATBidInfo alloc] initWithDictionary:obj placementID:placementModel.placementID unitGroupUnitID:ugMap[obj[@"unit_id"]].unitID expirationInterval:ugMap[obj[@"unit_id"]].bidTokenTime];
                        bidInfos[bidInfo.unitGroupUnitID] = bidInfo;
                    } else {
                        if (ugMap[obj[@"unit_id"]] != nil) { errors[ugMap[obj[@"unit_id"]].unitID] = [NSError errorWithDomain:@"com.anythink.BidRequest" code:[obj[@"err_code"] integerValue] userInfo:@{NSLocalizedDescriptionKey:@"Bid request has failed", NSLocalizedFailureReasonErrorKey:obj[@"err_msg"] != nil ? obj[@"err_msg"] : @"Server bid failed"}]; }
                    }
                }];
                completion(bidInfos, errors);
            }
        } else {
            if (completion != nil) {
                if (error == nil) { error = [NSError errorWithDomain:@"com.anythink.S2SBiddingRequest" code:[responseObject[@"code"] integerValue] userInfo:@{NSLocalizedDescriptionKey:@"S2S bidding request has failed", NSLocalizedFailureReasonErrorKey:[responseObject[@"msg"] isKindOfClass:[NSString class]] ? responseObject[@"msg"] : @"S2S bidding request has failed"}]; }
                NSMutableDictionary<NSString*, NSError*>* errors = [NSMutableDictionary<NSString*, NSError*> dictionary];
                [headerBiddingUnitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { errors[obj.unitID] = error; }];
                completion(nil, errors);
            }
        }
    }];
}

+(NSArray<NSDictionary*>*)headerBiddingListParameterWithUnitGroups:(NSArray<ATUnitGroupModel*>*)unitGroups {
    NSMutableArray<NSDictionary*>* headerBiddingList = [NSMutableArray<NSDictionary*> array];
    [unitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { [headerBiddingList addObject:[obj.adapterClass respondsToSelector:@selector(headerBiddingParametersWithUnitGroupModel:)] ? [obj.adapterClass headerBiddingParametersWithUnitGroupModel:obj] : @{}]; }];
    return headerBiddingList;
}

+(NSDictionary*)parametersWithPlacementModel:(ATPlacementModel*)placementModel {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSDictionary *protectedFields = nil;
    if ([[ATAppSettingManager sharedManager] shouldUploadProtectedFields]) {
        protectedFields = @{@"os_vn":[Utilities systemName],
                            @"os_vc":[Utilities systemVersion],
                            @"network_type":[ATNetworkingManager currentNetworkType],
                            @"mnc":[Utilities mobileNetworkCode],
                            @"mcc":[Utilities mobileCountryCode],
                            @"language":[Utilities language],
                            @"brand":[Utilities brand],
                            @"model":[Utilities model],
                            @"timezone":[Utilities timezone],
                            @"screen":[Utilities screenResolution],
                            @"ua":[Utilities userAgent],
                            @"upid":[[ATAppSettingManager sharedManager].ATID length] > 0 ? [ATAppSettingManager sharedManager].ATID : @""};
    } else {
        protectedFields = @{@"os_vn":@"",
                            @"os_vc":@"",
                            @"network_type":@"",
                            @"mnc":@"",
                            @"mcc":@"",
                            @"language":@"",
                            @"brand":@"",
                            @"model":@"",
                            @"timezone":@"",
                            @"screen":@"",
                            @"ua":@""};
    }
    NSString *sessionID = [[ATPlacementSettingManager sharedManager] sessionIDForPlacementID:placementModel.placementID];
    NSDictionary *nonSubjectFields = @{@"app_id":[ATAPI sharedInstance].appID,
                                       @"platform":[Utilities platform],
                                       @"pl_id":placementModel.placementID,
                                       @"ps_id":[ATAPI sharedInstance].psID != nil ? [ATAPI sharedInstance].psID : @"",
                                       @"session_id":sessionID != nil ? sessionID : @"",
                                       @"package_name":[Utilities appBundleID],
                                       @"app_vn":[Utilities appBundleVersion],
                                       @"app_vc":[Utilities appBundleVersion],
                                       @"sdk_ver":[ATAPI sharedInstance].version,
                                       @"nw_ver":[Utilities networkVersions],
                                       @"orient":[Utilities screenOrientation],
                                       @"system":@(1),
                                       @"gdpr_cs":[NSString stringWithFormat:@"%ld", [[ATAppSettingManager sharedManager] commonTkDataConsentSet]]
                                       };
    [parameters addEntriesFromDictionary:nonSubjectFields];
    [parameters addEntriesFromDictionary:protectedFields];
    if ([[ATAPI sharedInstance].channel length] > 0) { parameters[@"channel"] = [ATAPI sharedInstance].channel; }
    if ([[ATAPI sharedInstance].subchannel length] > 0) { parameters[@"sub_channel"] = [ATAPI sharedInstance].subchannel; }
    parameters[@"first_init_time"] = @((NSUInteger)([[ATAPI firstLaunchDate] timeIntervalSince1970] * 1000.0f));
    parameters[@"days_from_first_init"] = @([[NSDate date] numberOfDaysSinceDate:[ATAPI firstLaunchDate]]);
    
    NSArray *cappedMyOfferIDs = [NSArray arrayWithArray:[ATPlacementSettingManager excludeMyOfferID]];
    if (cappedMyOfferIDs.count > 0) { parameters[@"exclude_myofferid"] = cappedMyOfferIDs; }
    
    NSString *ABTestID = [ATAppSettingManager sharedManager].ABTestID;
    if (ABTestID != nil) { parameters[@"abtest_id"] = ABTestID; }
    return parameters;
}

+(NSDictionary*)parameter2 {
    NSMutableDictionary *parameters2 = [NSMutableDictionary dictionary];
    if ([[ATAppSettingManager sharedManager] shouldUploadProtectedFields]) {
        parameters2[@"idfa"] = [Utilities advertisingIdentifier];
        parameters2[@"idfv"] = [Utilities idfv];
    } else {
        parameters2[@"idfa"] = @"";
        parameters2[@"idfv"] = @"";
    }
    return parameters2;
}
@end
