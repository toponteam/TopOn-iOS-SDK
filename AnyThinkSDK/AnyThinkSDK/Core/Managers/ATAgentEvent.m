//
//  ATAgentEvent.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 02/05/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAgentEvent.h"
#import "ATNetworkingManager.h"
#import "ATPlacementSettingManager.h"
#import "ATAdManager+Internal.h"
#import "ATAPI+Internal.h"
#import "ATPlacementModel.h"
#import "ATUnitGroupModel.h"
#import "Utilities.h"
#import "ATAppSettingManager.h"
#import "ATTCPLogManager.h"

NSString *const kGeneralAdAgentEventExtraInfoLoadErrorCodeKey = @"load_error_code";
NSString *const kRVAgentEventExtraInfoDownloadResultKey = @"download_result";
NSString *const kRVAgentEventExtraInfoDownloadTimeKey = @"download_time";
NSString *const kRVAgentEventExtraInfoErrorTypeKey = @"error_type";
NSString *const kRVAgentEventExtraInfoErrorMsgKey = @"error_msg";
NSString *const kRVAgentEventExtraInfoRewardedFlagKey = @"rewarded";
NSString *const kAgentEventExtraInfoNotReadyReasonKey = @"not_ready_reason";
NSString *const kAgentEventExtraInfoReadyFlagKey = @"ready_flag";
NSString *const kAgentEventExtraInfoCallerInfoKey = @"caller_info";

NSString *const kAgentEventExtraInfoPlacementIDKey = @"placement_id";
NSString *const kAgentEventExtraInfoPSIDKey = @"ps_id";
NSString *const kAgentEventExtraInfoSessionIDKey = @"session_id";
NSString *const kAgentEventExtraInfoRequestIDKey = @"request_id";
NSString *const kAgentEventExtraInfoGroupIDKey = @"group_id";
NSString *const kAgentEventExtraInfoLoadingEventTypeKey = @"loading_event_type";
NSString *const kAgentEventExtraInfoSDKCallFlagKey = @"sdk_call_flag";
NSString *const kAgentEventExtraInfoSDKNotCalledReasonKey = @"sdk_not_called_reason";
NSString *const kAgentEventExtraInfoASIDKey = @"as_id";
NSString *const kAgentEventExtraInfoLoadingResultKey = @"loading_result";
NSString *const kAgentEventExtraInfoLoadingFailureReasonKey = @"loading_failure_reason";
NSString *const kAgentEventExtraInfoAdSourceIDKey = @"ad_source_id";
NSString *const kAgentEventExtraInfoNetworkFirmIDKey = @"network_firm_id";
NSString *const kAgentEventExtraInfoUnitGroupUnitIDKey = @"unit_gorup_unit_id";
NSString *const kAgentEventExtraInfoPriorityKey = @"ad_source_priority";
NSString *const kAgentEventExtraInfoRequestFailReasonKey = @"request_fail_reason";
NSString *const kAgentEventExtraInfoRequestFailErrorCodeKey = @"request_fail_error_code";
NSString *const kAgentEventExtraInfoRequestFailErrorMsgKey = @"request_fail_error_msg";
NSString *const kAgentEventExtraInfoRequestFailTimeKey = @"request_fail_time";
NSString *const kAgentEventExtraInfoRequestHeaderBiddingFlagKey = @"header_bidding_flag";
NSString *const kAgentEventExtraInfoRequestPriceKey = @"price";
NSString *const kAgentEventExtraInfoNetworkSDKVersionKey = @"network_sdk_version";
NSString *const kAgentEventExtraInfoASResultKey = @"ad_source_result";
NSString *const kAgentEventExtraInfoRewardFlagKey = @"reward_flag";
NSString *const kAgentEventExtraInfoTKHostKey = @"tk_host";
NSString *const kAgentEventExtraInfoNetworkErrorCodeKey = @"network_error_code";
NSString *const kAgentEventExtraInfoNetworkErrorMsgKey = @"network_error_msg";
NSString *const kAgentEventExtraInfoAPINameKey = @"api_name";
NSString *const kAgentEventExtraInfoRequestTimestampKey = @"request_timestamp";
NSString *const kAgentEventExtraInfoResponseTimestampKey = @"response_timestamp";
NSString *const kAgentEventExtraInfoNetworkTimeKey = @"time_consumed";
NSString *const kAgentEventExtraInfoLatestRequestIDKey = @"latest_request_id";
NSString *const kAgentEventExtraInfoLatestRequestIDDifferFlagKey = @"latest_request_id_match";
NSString *const kAgentEventExtraInfoMyOfferDefaultFlagKey = @"my_offer_default_flag";

//5.4.0 tk failed count;
NSString *const kAgentEventExtraInfoTrackerFailedCountKey = @"tacker_failed_count";
//5.6.3 tk failed use TCP or HTTP;
NSString *const kAgentEventExtraInfoTrackerFailedProtocolTypeKey = @"tacker_failed_protocolType";
//NSString *const kAgentEventExtraInfoLoadingEventTypeLoad = @"load";
NSString *const kAgentEventExtraInfoLoadingEventTypeLoadResult = @"load_result";

NSString *const kAgentEventExtraInfoShowResultKey = @"show_result";
NSString *const kAgentEventExtraInfoShowFailureReasonKey = @"show_failure_reason";

NSString *const kAgentEventExtraInfoAdFilledByReadyFlagKey = @"filled_by_ready";
NSString *const kAgentEventExtraInfoAutoloadOnCloseFlagKey = @"auto_load_on_close";
NSString *const kAgentEventExtraInfoGeneratedIDTypeKey = @"generated_id_type";
NSString *const kAgentEventExtraInfoIDGenerationRandomNumberKey = @"random_number";
NSString *const kAgentEventExtraInfoIDGenerationTimestampKey = @"id_gen_timestamp";

NSString *const kAgentEventExtraInfoMyOfferOfferIDKey = @"my_offer_offer_id";
NSString *const kAgentEventExtraInfoMyOfferResourceURLKey = @"my_offer_resource_url";
NSString *const kAgentEventExtraInfoMyOfferVideoDownloadResultKey = @"my_offer_video_download_result";
NSString *const kAgentEventExtraInfoMyOfferVideoSizeKey = @"my_offer_video_size";
NSString *const kAgentEventExtraInfoMyOfferVideoDownloadFailReasonKey = @"my_offer_video_download_fail_reason";
NSString *const kAgentEventExtraInfoMyOfferVideoDownloadStartTimestampKey = @"my_offer_video_download_start_timestamp";
NSString *const kAgentEventExtraInfoMyOfferVideoDownloadFinishTimestampKey = @"my_offer_video_download_end_timestamp";
NSString *const kAgentEventExtraInfoMyOfferVideoDownloadTimeKey = @"my_offer_video_download_time";
NSString *const kAgentEventExtraInfoMyOfferVideoDownloadModelTypeKey = @"my_offer_video_download_modelType";
NSString *const kAgentEventExtraInfoOriginalRequestIDKey = @"original_request_id";
NSString *const kAgentEventExtraInfoMetadataLoadingTimeKey = @"metadata_loading_time";
NSString *const kAgentEventExtraInfoAdDataLoadingTimeKey = @"ad_data_loading_time";
NSString *const kAgentEventExtraInfoGDPRThirdPartySDKLevelKey = @"third_party_sdk_level";
NSString *const kAgentEventExtraInfoGDPRDevConsentKey = @"dev_consent";
NSString *const kAgentEventExtraInfoServerGDPRIAValueKey = @"server_gdpr_ia_value";

NSString *const kAgentEventExtraInfoLifecycleEventTypeKey = @"lifecycle_event_type";
NSString *const kAgentEventExtraInfoActivateTimeKey = @"activate_time";
NSString *const kAgentEventExtraInfoResignActiveTimeKey = @"resign_active_time";
NSString *const kAgentEventExtraInfoLifecycleIntervalKey = @"lifecycle_interval";

NSString *const kAgentEventExtraInfoFormatKey = @"ad_format";
NSString *const kAgentEventExtraInfoShowTimestampKey = @"show_timestamp";
NSString *const kAgentEventExtraInfoCloseTimestampKey = @"close_timestamp";
NSString *const kAgentEventExtraInfoShowDurationKey = @"show_duration";

NSString *const kAgentEventExtraInfoBidInfoProcessingPriceKey = @"processing_price";
NSString *const kAgentEventExtraInfoBidInfoBidRequestTimeKey = @"bid_request_time";
NSString *const kAgentEventExtraInfoBidInfoLoadingStatusKey = @"loading_status";
NSString *const kAgentEventExtraInfoBidInfoMarkingPriceKey = @"marking_price";
NSString *const kAgentEventExtraInfoBidInfoProcessResultKey = @"process_result";
NSString *const kAgentEventExtraInfoBidInfoBatProcessResultKey = @"bat_process_result";

NSString *const kAgentEventExtraInfoAdTypeKey = @"ad_type";
NSString *const kAgentEventExtraInfoAdClickUrlKey = @"ad_click_url";
NSString *const kAgentEventExtraInfoAdLastUrlKey = @"ad_last_url";
NSString *const kAgentEventExtraInfoAdPkgNameKey = @"ad_pkg_name";
NSString *const kAgentEventExtraInfoIsSuccessKey = @"is_success";
NSString *const kAgentEventExtraInfoLoadStartTimeKey = @"load_start_time";
NSString *const kAgentEventExtraInfoLoadStopTimeKey = @"load_stop_time";


NSString *const kATAgentEventKeyLoadFail = @"1004630";
NSString *const kATAgentEventKeyRequestFail = @"1004631";
NSString *const kATAgentEventKeyReady = @"1004632";
NSString *const kATAgentEventKeyShowFail = @"1004633";
NSString *const kATAgentEventKeyClose = @"1004634";
NSString *const kATAgentEventKeyNetworkRequestFail = @"1004616";
NSString *const kATAgentEventKeyNetworkRequestSuccess = @"1004635";
NSString *const kATAgentEventKeyFailToPlay = @"1004636";
NSString *const kATAgentEventKeyPSIDSessionIDGeneration = @"1004637";
NSString *const kATAgentEventKeyMyOfferVideoDownload = @"1004638";
NSString *const kATAgentEventKeyAdSourceStatusFillKey = @"1004639";
NSString *const kATAgentEventKeyMetadataAndAdDataLoadingTimeKey = @"1004640";
NSString *const kATAgentEventKeyGDPRLevelKey = @"1004641";
NSString *const kATAgentEventKeyAdShowDurationKey = @"1004643";
NSString *const kATAgentEventKeyAppLifecycleKey = @"1004644";
NSString *const kATAgentEventKeyBidInfoProcessingKey = @"1004646";
NSString *const kATAgentEventKeyClickRedirectFailedKey = @"1004648";
NSString *const kATAgentEventKeyPreloadStorekitResultKey = @"1004649";

@interface ATAgentEvent()
@property(nonatomic, readonly) NSMutableArray<NSDictionary*>* ramData;
@property(nonatomic, readonly) ATThreadSafeAccessor *ramDataAccessor;
@property(nonatomic, readwrite) NSDate *ramDataLastUploadDate;

@property(nonatomic, readonly) NSMutableArray<NSDictionary*>*diskData;
@property(nonatomic, readonly) ATThreadSafeAccessor *diskDataAccessor;
@property(nonatomic, readwrite) NSDate *diskDataLastUploadDate;
@end
static NSString *const kUserDefaultsDiskLastUploadDateKey = @"com.anythink.AgentEventLastUploadDate";
static NSString *const kBase64Table1 = @"dMWnhbeyKr0J+IvLNOx3BFkEuml92/5fjSqGT7R8pZVciPHAstC4UXa6QDw1gozY";
static NSString *const kBase64Table2 = @"xZnV5k+DvSoajc7dRzpHLYhJ46lt0U3QrWifGyNgb9P1OIKmCEuq8sw/XMeBAT2F";
@implementation ATAgentEvent
+(instancetype)sharedAgent {
    static ATAgentEvent *sharedEvent = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEvent = [[ATAgentEvent alloc] init];
    });
    return sharedEvent;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[ATAgentEvent eventRootPath] withIntermediateDirectories:NO attributes:@{NSFileProtectionKey:NSFileProtectionComplete} error:nil];
        
        _ramData = [NSMutableArray<NSDictionary*> array];
        _ramDataAccessor = [ATThreadSafeAccessor new];
        _ramDataLastUploadDate = [NSDate date];
        
        _diskData = [NSMutableArray<NSDictionary*> arrayWithContentsOfFile:[ATAgentEvent diskEventsArchivePath]];
        _diskData = [_diskData isKindOfClass:[NSMutableArray class]] ? _diskData : [NSMutableArray<NSDictionary*> array];
        _diskDataAccessor = [ATThreadSafeAccessor new];
        _diskDataLastUploadDate = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsDiskLastUploadDateKey] isKindOfClass:[NSDate class]] ? [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsDiskLastUploadDateKey] : [NSDate date];
    }
    return self;
}

/**
 * Check the upload conditions & if they're met, upload the saved events.
 * Upload conditions:
 * 1) Last upload took place more than 30 mins ago;
 * 2) There has been more than eight entries in the directory.
 */
-(void) uploadIfNeed {
    [ATLogger logMessage:@"uploadIfNeed" type:ATLogTypeInternal];
    ATTrackingSetting *trackingSetting = [ATAppSettingManager sharedManager].trackingSetting;
    __weak typeof(self) weakSelf = self;
    [_diskDataAccessor writeWithBlock:^{
        if ([weakSelf.diskData count] > trackingSetting.agentEventBatNumberThreadhold || [[NSDate date] timeIntervalSinceDate:weakSelf.diskDataLastUploadDate] >= trackingSetting.agentEventBatInterval) {
            NSArray<NSDictionary*>* dataToUpload = [NSArray arrayWithArray:weakSelf.diskData];
            weakSelf.diskDataLastUploadDate = [NSDate date];
            [[NSUserDefaults standardUserDefaults] setObject:weakSelf.diskDataLastUploadDate forKey:kUserDefaultsDiskLastUploadDateKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [weakSelf.diskData removeAllObjects];
            [weakSelf.diskData writeToFile:[ATAgentEvent diskEventsArchivePath] atomically:YES];
            [weakSelf uploadData:dataToUpload completion:^(BOOL succeed) {
                if (!succeed) {
                    [weakSelf.diskDataAccessor writeWithBlock:^{
                        [weakSelf.diskData addObjectsFromArray:dataToUpload];
                        [weakSelf.diskData writeToFile:[ATAgentEvent diskEventsArchivePath] atomically:YES];
                    }];
                }
            }];
        }
    }];
}

+(NSString*) diskEventsArchivePath {
    return [[self eventRootPath] stringByAppendingPathComponent:@"data"];
}

+(NSString*) eventRootPath {
    return [[Utilities documentsPath] stringByAppendingPathComponent:@"AnyThinkSDKAgentEvent"];
}

-(void) uploadData:(NSArray*)data completion:(void(^)(BOOL succeed))completion {
    if ([data count] > 0) {
        NSString *p1 = [[[ATAgentEvent parametersWithEventData:data] jsonString_anythink] stringByBase64Encoding_anythink];
        NSString *p2 = [[[ATAgentEvent parameter2] jsonString_anythink] stringByBase64Encoding_anythink];
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:p1, @"p", p2, @"p2", @"1.0", @"api_ver", nil];
        parameters[@"sign"] = [Utilities computeSignWithParameters:parameters];
        
        NSArray<NSString*>* testDeviceIDFAList = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AnyThinkSDKTestDeviceIDFA"];
        if ([testDeviceIDFAList isKindOfClass:[NSArray class]] && [testDeviceIDFAList containsObject:[Utilities advertisingIdentifier]]) {
            NSMutableArray<NSDictionary*>* testFields = [NSMutableArray<NSDictionary*> array];
            [data enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMutableDictionary *entry = [NSMutableDictionary dictionary];
                if ([obj[@"key"] isEqualToString:kATAgentEventKeyRequestFail]) {
                    if (obj[@"msg"] != nil) { entry[@"nw_firm_id"] = obj[@"msg"]; }
                    if (obj[@"msg4"] != nil) { entry[@"error_code"] = obj[@"msg4"]; }
                    if (obj[@"msg5"] != nil) { entry[@"error_msg"] = obj[@"msg5"]; }
                }
                
                if ([entry count] > 0) { [testFields addObject:entry]; }
            }];
            if ([testFields count] > 0) { parameters[@"test_fields"] = testFields; }
        }
        
        switch ([ATAppSettingManager sharedManager].trackingSetting.trackerTCPType) {
            case 0://http
            case 2://http&tcp only send http
                [self sendHTTPRequestParameters:parameters completion:completion];
                break;
            case 1://tcp
                [self sendTCPRequestParameters:parameters completion:completion];
                break;
            default:
                break;
        }
    }
}

- (void)sendHTTPRequestParameters:(id)parameters completion:(void(^)(BOOL succeed))completion {
    [[ATNetworkingManager sharedManager] sendHTTPRequestToAddress:[ATAppSettingManager sharedManager].trackingSetting.agentEventAddress HTTPMethod:ATNetworkingHTTPMethodPOST parameters:parameters completion:^(NSData * _Nonnull data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (completion != nil) {
//            __block NSDictionary *responseObject = nil;
            //AT_SafelyRun is used to guard against exception that's beyond our precaution, which includes the nullability of responseData.
//            AT_SafelyRun(^{ responseObject = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithBase64EncodedData:data options:0] options:NSJSONReadingMutableContainers error:nil]; });
            completion(((NSHTTPURLResponse*)response).statusCode == 200);
        }
    }];
}

- (void)sendTCPRequestParameters:(id)parameters completion:(void(^)(BOOL succeed))completion {
    parameters[@"report_type"] = @([ATAppSettingManager sharedManager].trackingSetting.trackerTCPType);
    [[ATTCPLogManager sharedManager] sendTCPToOpenApi:ATTCPSocketOpenApiData paramters:parameters completion:^(NSData * _Nonnull responseData, NSError * _Nullable error) {
        if (completion != nil) {
            completion((error == nil ? YES : NO));
        }
    }];
}


-(void) appendEvent:(NSDictionary*)event usingTrackingSetting:(ATTrackingSetting*)trackingSetting diskData:(BOOL)diskData {
    __weak typeof(self) weakSelf = self;
    ATThreadSafeAccessor *accessor = diskData ? _diskDataAccessor : _ramDataAccessor;
    NSMutableArray<NSDictionary*>* data = diskData ? _diskData : _ramData;
    NSInteger maxNumberOfEvents = diskData ? trackingSetting.agentEventBatNumberThreadhold : trackingSetting.agentEventNumberThreadhold;
    NSTimeInterval interval = diskData ? trackingSetting.agentEventBatInterval : trackingSetting.agentEventInterval;
    NSDate *lastUploadDate = diskData ? _diskDataLastUploadDate : _ramDataLastUploadDate;
    
    [accessor writeWithBlock:^{
        [data addObject:event];
        if ([data count] >= maxNumberOfEvents || [[NSDate date] timeIntervalSinceDate:lastUploadDate] >= interval) {
            NSArray<NSDictionary*>* dataToUpload = [NSArray<NSDictionary*> arrayWithArray:data];
            [weakSelf uploadData:dataToUpload completion:^(BOOL succeed) {
                if (!succeed && diskData) {
                    [accessor writeWithBlock:^{
                        [data addObjectsFromArray:dataToUpload];
                        [data writeToFile:[ATAgentEvent diskEventsArchivePath] atomically:YES];
                    }];
                }
            }];
            [data removeAllObjects];
            if (diskData) {
                weakSelf.diskDataLastUploadDate = [NSDate date];
                [[NSUserDefaults standardUserDefaults] setObject:weakSelf.diskDataLastUploadDate forKey:kUserDefaultsDiskLastUploadDateKey];
            } else {
                weakSelf.ramDataLastUploadDate = [NSDate date];
            }
        }
        if (diskData) {
            [data writeToFile:[ATAgentEvent diskEventsArchivePath] atomically:YES];
        }
    }];
}

+(void) saveRequestAPIName:(NSString*)apiName requestDate:(NSNumber*)requestDate responseDate:(NSNumber*)responseDate extra:(NSDictionary*)extra {
    ATTrackingSetting *trackingSetting = [ATAppSettingManager sharedManager].trackingSetting;
    [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyNetworkRequestSuccess placementID:nil unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoAPINameKey:apiName != nil ? apiName : @"",
                                                                                                                                              kAgentEventExtraInfoRequestTimestampKey:requestDate,
                                                                                                                                              kAgentEventExtraInfoResponseTimestampKey:responseDate,
                                                                                                                                              kAgentEventExtraInfoNetworkTimeKey:@([responseDate doubleValue] - [requestDate doubleValue]),                    kAgentEventExtraInfoTKHostKey:trackingSetting.trackerAddress != nil ? trackingSetting.trackerAddress : @""
                                                                                                                                              }];
}

-(void) saveEventWithKey:(NSString*)key placementID:(NSString*)placementID unitGroupModel:(nullable ATUnitGroupModel*)unitGroupModel extraInfo:(NSDictionary*)extraInfo {
    ATTrackingSetting *trackingSetting = [ATAppSettingManager sharedManager].trackingSetting;
    ATPlacementModel *placementModel = [[ATPlacementSettingManager sharedManager] placementSettingWithPlacementID:placementID];
    if (key != nil && !((placementModel != nil && [trackingSetting.agentEventDropFormats[key] containsObject:@(placementModel.format).stringValue]) || (placementModel == nil && trackingSetting.agentEventDropFormats[key] != nil))) {
        NSDictionary *eventDict = [ATAgentEvent eventParametersWithKey:key forPlacementID:placementID unitGroupModel:unitGroupModel extraInfo:extraInfo];
        [self appendEvent:eventDict usingTrackingSetting:trackingSetting diskData:!((placementModel != nil && [trackingSetting.agentEventRTFormats[key] containsObject:@(placementModel.format).stringValue]) || (placementModel == nil && trackingSetting.agentEventRTFormats[key] != nil))];
//        NSLog(@"\n**************************Marvin_da_event**************************\n%@\n**************************da_event**************************\n", eventDict);
    }
}

+(NSDictionary*)eventParametersWithKey:(NSString*)key forPlacementID:(NSString*)placementID unitGroupModel:(nullable ATUnitGroupModel*)unitGroupModel extraInfo:(NSDictionary*)extraInfo {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[self baseParametersWithKey:key placementID:placementID unitGroupModel:unitGroupModel extraInfo:extraInfo]];
    NSDictionary<NSString*, NSString*> *msgKeys = [self msgKeysForAgentEventKey:key];
    [msgKeys enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) { if (extraInfo[key] != nil) { parameters[obj] = extraInfo[key]; } }];
    return parameters;
}

+(NSDictionary*)baseParametersWithKey:(NSString*)key placementID:(nullable NSString*)placementID unitGroupModel:(nullable ATUnitGroupModel*)unitGroupModel extraInfo:(NSDictionary*)extraInfo {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:key != nil ? key : @"", @"key", placementID != nil ? placementID : @"", @"unitid", [Utilities normalizedTimeStamp], @"timestamp", nil];
    if (extraInfo[kAgentEventExtraInfoPlacementIDKey] != nil) { parameters[@"unitid"] = extraInfo[kAgentEventExtraInfoPlacementIDKey]; }
    if ([extraInfo[kAgentEventExtraInfoAutoloadOnCloseFlagKey] boolValue]) { parameters[@"refresh"] = @1; }
    if ([extraInfo isKindOfClass:[NSDictionary class]] && extraInfo[kAgentEventExtraInfoRequestIDKey] != nil) { parameters[@"requestid"] = extraInfo[kAgentEventExtraInfoRequestIDKey]; }
    ATPlacementModel *placementModel = [[ATPlacementSettingManager sharedManager] placementSettingWithPlacementID:placementID];
    if (placementModel != nil) { parameters[@"groupid"] = @(placementModel.groupID); }
    if (placementModel.trafficGroupID != nil) { parameters[@"traffic_group_id"] = placementModel.trafficGroupID; }
    if (extraInfo[kAgentEventExtraInfoPSIDKey] != nil) {
        parameters[@"psid"] = extraInfo[kAgentEventExtraInfoPSIDKey];
    } else {
        if ([ATAPI sharedInstance].psID != nil) { parameters[@"psid"] = [ATAPI sharedInstance].psID; }
    }
    if (extraInfo[kAgentEventExtraInfoSessionIDKey] != nil) {
        parameters[@"sessionid"] = extraInfo[kAgentEventExtraInfoSessionIDKey];
    } else {
        if (placementID != nil && [[ATPlacementSettingManager sharedManager] sessionIDForPlacementID:placementID] != nil) { parameters[@"sessionid"] = [[ATPlacementSettingManager sharedManager] sessionIDForPlacementID:placementID]; }
    }
    
    if (placementModel.asid != nil) { parameters[@"asid"] = placementModel.asid; }
    return parameters;
}

+(NSDictionary<NSString*, NSString*>*)msgKeysForAgentEventKey:(NSString*)key {
    return @{kATAgentEventKeyLoadFail:@{kAgentEventExtraInfoLoadingFailureReasonKey:@"msg",
                                        kGeneralAdAgentEventExtraInfoLoadErrorCodeKey:@"msg1"
    },
             kATAgentEventKeyRequestFail:@{kAgentEventExtraInfoNetworkFirmIDKey:@"msg",
                                               kAgentEventExtraInfoUnitGroupUnitIDKey:@"msg1",
                                               kAgentEventExtraInfoPriorityKey:@"msg2",
                                               kAgentEventExtraInfoRequestFailReasonKey:@"msg3",
                                               kAgentEventExtraInfoRequestFailErrorCodeKey:@"msg4",
                                               kAgentEventExtraInfoRequestFailErrorMsgKey:@"msg5",
                                               kAgentEventExtraInfoRequestHeaderBiddingFlagKey:@"msg6",
                                               kAgentEventExtraInfoRequestPriceKey:@"msg7",
                                               kAgentEventExtraInfoRequestFailTimeKey:@"msg8"
                                               },
             kATAgentEventKeyReady:@{kAgentEventExtraInfoReadyFlagKey:@"msg",
                                         kAgentEventExtraInfoNotReadyReasonKey:@"msg1",
                                         kAgentEventExtraInfoPriorityKey:@"msg2",
                                         kAgentEventExtraInfoUnitGroupUnitIDKey:@"msg3",
                                         kAgentEventExtraInfoNetworkFirmIDKey:@"msg4",
                                         kAgentEventExtraInfoNetworkSDKVersionKey:@"msg5",
                                         kAgentEventExtraInfoASResultKey:@"msg6",
                                         kAgentEventExtraInfoLatestRequestIDKey:@"msg7",
                                         kAgentEventExtraInfoLatestRequestIDDifferFlagKey:@"msg8",
                                         kAgentEventExtraInfoAdFilledByReadyFlagKey:@"msg9",
                                         kAgentEventExtraInfoMyOfferDefaultFlagKey:@"msg10"
                                         },
             kATAgentEventKeyShowFail:@{kAgentEventExtraInfoNotReadyReasonKey:@"msg",
                                            kAgentEventExtraInfoASResultKey:@"msg1",
                                            kAgentEventExtraInfoRequestHeaderBiddingFlagKey:@"msg2",
                                            kAgentEventExtraInfoRequestPriceKey:@"msg3",
                                            kAgentEventExtraInfoLatestRequestIDKey:@"msg4",
                                            kAgentEventExtraInfoLatestRequestIDDifferFlagKey:@"msg5"
                                            },
             kATAgentEventKeyClose:@{kAgentEventExtraInfoNetworkFirmIDKey:@"msg",
                                         kAgentEventExtraInfoUnitGroupUnitIDKey:@"msg1",
                                         kAgentEventExtraInfoPriorityKey:@"msg2",
                                         kAgentEventExtraInfoRewardFlagKey:@"msg3",
                                         kAgentEventExtraInfoMyOfferDefaultFlagKey:@"msg4"
                                         },
             kATAgentEventKeyNetworkRequestFail:@{kAgentEventExtraInfoAPINameKey:@"msg",
                                                      kAgentEventExtraInfoNetworkErrorCodeKey:@"msg1",
                                                      kAgentEventExtraInfoNetworkErrorMsgKey:@"msg2",
                                                      kAgentEventExtraInfoTKHostKey:@"msg3",
                                                      kAgentEventExtraInfoTrackerFailedCountKey:@"msg4",
                                                      kAgentEventExtraInfoTrackerFailedProtocolTypeKey:@"msg5"
             },
             kATAgentEventKeyNetworkRequestSuccess:@{kAgentEventExtraInfoAPINameKey:@"msg",
                                                         kAgentEventExtraInfoRequestTimestampKey:@"msg1",
                                                         kAgentEventExtraInfoResponseTimestampKey:@"msg2",
                                                         kAgentEventExtraInfoNetworkTimeKey:@"msg3"
                                                         },
             kATAgentEventKeyFailToPlay:@{kAgentEventExtraInfoNetworkFirmIDKey:@"msg",
                                              kAgentEventExtraInfoUnitGroupUnitIDKey:@"msg1",
                                              kAgentEventExtraInfoPriorityKey:@"msg2",
                                              //msg3's dropped
                                              kAgentEventExtraInfoNetworkErrorCodeKey:@"msg4",
                                              kAgentEventExtraInfoNetworkErrorMsgKey:@"msg5"
                                              },
             kATAgentEventKeyPSIDSessionIDGeneration:@{kAgentEventExtraInfoGeneratedIDTypeKey:@"msg",
                                                           kAgentEventExtraInfoIDGenerationRandomNumberKey:@"msg1",
                                                           kAgentEventExtraInfoIDGenerationTimestampKey:@"msg2"
                                                           },
             kATAgentEventKeyMyOfferVideoDownload:@{kAgentEventExtraInfoMyOfferOfferIDKey:@"msg",
                                                        kAgentEventExtraInfoMyOfferResourceURLKey:@"msg1",
                                                        kAgentEventExtraInfoMyOfferVideoDownloadResultKey:@"msg2",
                                                        kAgentEventExtraInfoMyOfferVideoSizeKey:@"msg3",
                                                        kAgentEventExtraInfoMyOfferVideoDownloadFailReasonKey:@"msg4",
                                                        kAgentEventExtraInfoMyOfferVideoDownloadStartTimestampKey:@"msg5",
                                                        kAgentEventExtraInfoMyOfferVideoDownloadFinishTimestampKey:@"msg6",
                                                        kAgentEventExtraInfoMyOfferVideoDownloadTimeKey:@"msg7",
                                                        kAgentEventExtraInfoMyOfferVideoDownloadModelTypeKey:@"msg8"
                                                        },
             kATAgentEventKeyAdSourceStatusFillKey:@{kAgentEventExtraInfoNetworkFirmIDKey:@"msg",
                                                     kAgentEventExtraInfoAdSourceIDKey:@"msg1",
                                                     kAgentEventExtraInfoPriorityKey:@"msg2",
                                                     kAgentEventExtraInfoOriginalRequestIDKey:@"msg3"
                                                    },
             kATAgentEventKeyMetadataAndAdDataLoadingTimeKey:@{kAgentEventExtraInfoNetworkFirmIDKey:@"msg",
                                                               kAgentEventExtraInfoAdSourceIDKey:@"msg1",
                                                               kAgentEventExtraInfoPriorityKey:@"msg2",
                                                               kAgentEventExtraInfoMetadataLoadingTimeKey:@"msg3",
                                                               kAgentEventExtraInfoAdDataLoadingTimeKey:@"msg4"
                                                              },
             kATAgentEventKeyGDPRLevelKey:@{kAgentEventExtraInfoGDPRThirdPartySDKLevelKey:@"msg",
                                            kAgentEventExtraInfoGDPRDevConsentKey:@"msg1",
                                            kAgentEventExtraInfoServerGDPRIAValueKey:@"msg2",
                                            kAgentEventExtraInfoNetworkFirmIDKey:@"msg3"
             },
             kATAgentEventKeyAppLifecycleKey:@{kAgentEventExtraInfoLifecycleEventTypeKey:@"msg",
                                               kAgentEventExtraInfoActivateTimeKey:@"msg1",
                                               kAgentEventExtraInfoResignActiveTimeKey:@"msg2",
                                               kAgentEventExtraInfoLifecycleIntervalKey:@"msg3"
             },
             kATAgentEventKeyAdShowDurationKey:@{kAgentEventExtraInfoFormatKey:@"msg",
                                                 kAgentEventExtraInfoShowTimestampKey:@"msg1",
                                                 kAgentEventExtraInfoCloseTimestampKey:@"msg2",
                                                 kAgentEventExtraInfoShowDurationKey:@"msg3",
                                                 kAgentEventExtraInfoNetworkFirmIDKey:@"msg4",
                                                 kAgentEventExtraInfoAdSourceIDKey:@"msg5",
                                                 kAgentEventExtraInfoPriorityKey:@"msg6",
                                                 kAgentEventExtraInfoMyOfferDefaultFlagKey:@"msg7",
                                                 kAgentEventExtraInfoRewardFlagKey:@"msg8"
             },
             kATAgentEventKeyBidInfoProcessingKey:@{kAgentEventExtraInfoNetworkFirmIDKey:@"msg",
                                                    kAgentEventExtraInfoAdSourceIDKey:@"msg1",
                                                    kAgentEventExtraInfoBidInfoProcessingPriceKey:@"msg2",
                                                    kAgentEventExtraInfoBidInfoBidRequestTimeKey:@"msg3",
                                                    kAgentEventExtraInfoBidInfoLoadingStatusKey:@"msg4",
                                                    kAgentEventExtraInfoBidInfoMarkingPriceKey:@"msg5",
                                                    kAgentEventExtraInfoBidInfoProcessResultKey:@"msg6",
                                                    kAgentEventExtraInfoBidInfoBatProcessResultKey:@"msg7"
                                                    
             },
             kATAgentEventKeyClickRedirectFailedKey:@{kAgentEventExtraInfoMyOfferOfferIDKey:@"msg",
                                                    kAgentEventExtraInfoAdTypeKey:@"msg1",
                                                    kAgentEventExtraInfoAdClickUrlKey:@"msg2",
                                                    kAgentEventExtraInfoAdLastUrlKey:@"msg3",
                                                    kGeneralAdAgentEventExtraInfoLoadErrorCodeKey:@"msg4",
                                                    kAgentEventExtraInfoLoadingFailureReasonKey:@"msg5"
                                                    
             },
             kATAgentEventKeyPreloadStorekitResultKey:@{kAgentEventExtraInfoMyOfferOfferIDKey:@"msg",
                                                    kAgentEventExtraInfoAdTypeKey:@"msg1",
                                                    kAgentEventExtraInfoAdPkgNameKey:@"msg2",
                                                    kAgentEventExtraInfoIsSuccessKey:@"msg3",
                                                    kAgentEventExtraInfoLoadStartTimeKey:@"msg4",
                                                    kAgentEventExtraInfoLoadStopTimeKey:@"msg5"
                                                    
             }
             }[key];
}

+(NSDictionary*)parametersWithEventData:(NSArray*)data {
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
    NSDictionary *nonSubjectFields = @{@"data":data,
                                       @"app_id":[[ATAPI sharedInstance].appID length] > 0 ? [ATAPI sharedInstance].appID : @"",
                                       @"platform":[Utilities platform],
                                       @"package_name":[Utilities appBundleID],
                                       @"app_vn":[Utilities appBundleVersion],
                                       @"app_vc":[Utilities appBundleVersionCode],
                                       @"sdk_ver":[ATAPI sharedInstance].version,
                                       @"orient":[Utilities screenOrientation],
                                       @"system":@(1)
                                       };
    if ([[ATAPI sharedInstance].channel length] > 0) { parameters[@"channel"] = [ATAPI sharedInstance].channel; }
    if ([[ATAPI sharedInstance].subchannel length] > 0) { parameters[@"sub_channel"] = [ATAPI sharedInstance].subchannel; }
    if ([Utilities isBlankDictionary:[ATAPI sharedInstance].customData] == NO) {
        parameters[@"custom"] = [[ATAPI sharedInstance].customData calculateObjectChangeStringForKey];
    }
    parameters[@"first_init_time"] = @((NSUInteger)([[ATAPI firstLaunchDate] timeIntervalSince1970] * 1000.0f));
    parameters[@"days_from_first_init"] = @([[NSDate date] numberOfDaysSinceDate:[ATAPI firstLaunchDate]]);
    
    NSString *ABTestID = [ATAppSettingManager sharedManager].ABTestID;
    if (ABTestID != nil) { parameters[@"abtest_id"] = ABTestID; }
    
    [parameters addEntriesFromDictionary:nonSubjectFields];
    [parameters addEntriesFromDictionary:protectedFields];
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
    parameters2[@"tcp_tk_da_type"] = @([ATAppSettingManager sharedManager].trackingSetting.trackerTCPType);
    parameters2[@"tcp_rate"] = [[ATAppSettingManager sharedManager].trackingSetting.trackerTCPRate length] > 0 ? [ATAppSettingManager sharedManager].trackingSetting.trackerTCPRate : @"";
    
    return parameters2;
}

+(NSDictionary*)generalAdAgentInfoWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel requestID:(NSString*)requestID {
    NSMutableDictionary *extraInfo = [NSMutableDictionary dictionaryWithDictionary:@{kGeneralAdAgentEventExtraInfoNetworkFirmIDKey:@(unitGroupModel.networkFirmID),
                                                                                     kGeneralAdAgentEventExtraInfoUnitGroupContentKey:unitGroupModel.content != nil ? unitGroupModel.content : @{},
                                                                                     kGeneralAdAgentEventExtraInfoPriorityKey:@([placementModel.unitGroups indexOfObject:unitGroupModel]).stringValue,
                                                                                     }];
    return extraInfo;
}
@end
