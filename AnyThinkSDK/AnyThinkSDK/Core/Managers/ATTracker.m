//
//  ATTracker.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 19/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATTracker.h"
#import "ATNetworkingManager.h"
#import "ATPlacementSettingManager.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATPlacementModel.h"
#import "ATAdManager.h"
#import "ATThreadSafeAccessor.h"
#import "ATAdManager+Internal.h"
#import "ATAppSettingManager.h"
#import "ATAgentEvent.h"
#import "ATCapsManager.h"
#import "ATTCPLogManager.h"

NSString *const ATTrackerExtraShownNetworkPriorityInfoKey = @"priority_info";
NSString *const kATTrackerExtraAutoloadFlagKey = @"auto_load";
NSString *const kATTrackerExtraErrorKey = @"error_info";
NSString *const kATTrackerExtraHeaderBiddingInfoKey = @"header_bidding_info";
NSString *const kATTrackerExtraResourceTypeKey = @"resource_type";
NSString *const kATTrackerExtraSDKCalledFlagKey = @"sdk_called_flag";
NSString *const kATTrackerExtraSDKNotCalledReasonKey = @"sdk_not_called_reason";
NSString *const kATTrackerExtraUnitIDKey = @"unit_group_unit_id";//Ad source id
NSString *const kATTrackerExtraNetworkFirmIDKey = @"network_firm_id";
NSString *const kATTrackerExtraRefreshFlagKey = @"refresh";//for banner&native banner refresh
NSString *const kATTrackerExtraDefaultLoadFlagKey = @"default_load";
NSString *const kATTrackerExtraFilledWithinNetworkTimeoutFlagKey = @"filled_within_network_timeout";
NSString *const kATTrackerExtraFillRequestFlagKey = @"fill_request_flag";
NSString *const kATTrackerExtraFillTimeKey = @"fill_time";
NSString *const kATTrackerExtraASResultKey = @"as_result";
NSString *const kATTrackerExtraAppIDKey = @"app_id";
NSString *const kATTrackerExtraLastestRequestIDKey = @"latest_request_id";
NSString *const kATTrackerExtraLastestRequestIDMatchFlagKey = @"latest_request_id_match_flag";
NSString *const kATTrackerExtraAdFilledByReadyFlagKey = @"filled_by_ready";
NSString *const kATTrackerExtraAutoloadOnCloseFlagKey = @"auto_load_on_close";
NSString *const kATTrackerExtraLoadTimeKey = @"load_time";
NSString *const kATTrackerExtraClickAddressKey = @"click_address";
NSString *const kATTrackerExtraMyOfferDefaultFalgKey = @"my_offer_default";
NSString *const kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey = @"loaded_by_ad_source_status_flag";
NSString *const kATTrackerExtraCustomObjectKey = @"custom_object";
NSString *const kATTrackerExtraAdObjectKey = @"ad_object";
NSString *const kATTrackerExtraAdShowSceneKey = @"ad_show_scene";
NSString *const kATTrackerExtraAdShowSDKTimeKey = @"sdk_time";
NSString *const kATTrackerExtraTrafficGroupIDKey = @"traffic_group_id";
NSString *const kATTrackerExtraUGUnitIDKey = @"ug_unit_id";
NSString *const kATTrackerExtraASIDKey = @"as_id";
NSString *const kATTrackerExtraFormatKey = @"ad_format";
NSString *const kATTrackerExtraRequestExpectedOfferNumberFlagKey = @"req_expected_offer_num_flag";

static NSString *const kBase64Table1 = @"dMWnhbeyKr0J+IvLNOx3BFkEuml92/5fjSqGT7R8pZVciPHAstC4UXa6QDw1gozY";
static NSString *const kBase64Table2 = @"xZnV5k+DvSoajc7dRzpHLYhJ46lt0U3QrWifGyNgb9P1OIKmCEuq8sw/XMeBAT2F";
static NSString *const kAESEncryptionKey = @"0123456789abecef";
@interface ATTracker()
@property(nonatomic, readonly) ATThreadSafeAccessor *accessor;
@property(nonatomic, readonly) NSMutableArray<NSDictionary*>* data;
@property(nonatomic, readonly) NSMutableArray<NSDictionary*>* diskData;
@property(nonatomic, readonly) ATThreadSafeAccessor *diskDataAccessor;
@end
@implementation ATTracker
+(instancetype)sharedTracker {
    static ATTracker *sharedTracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTracker = [[ATTracker alloc] init];
    });
    return sharedTracker;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _accessor = [ATThreadSafeAccessor new];
        _data = [NSMutableArray<NSDictionary*> new];
        
        _diskData = [NSMutableArray<NSDictionary*> new];
        _diskDataAccessor = [ATThreadSafeAccessor new];
        
        NSArray<NSDictionary*>* diskData = [NSArray<NSDictionary*> arrayWithContentsOfFile:[ATTracker failedDataPath]];
        if ([diskData count] > 0) {
            [ATTracker sendData:diskData retryIfTimeout:YES];
            [[NSFileManager defaultManager] removeItemAtPath:[ATTracker failedDataPath] error:nil];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidEnterBackgroundNotification:) name:UIApplicationWillResignActiveNotification object:nil];
        
        __weak typeof(self) weakSelf = self;
        ATTrackingSetting *tkSetting = [ATAppSettingManager sharedManager].trackingSetting;
        if (tkSetting.sendsDataEveryInterval) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(tkSetting.trackerInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf sendAccumulatedData:YES];
            });
        }
    }
    return self;
}

-(void) handleApplicationDidEnterBackgroundNotification:(NSNotification*)notification {
    [self sendAccumulatedData:NO];
}

-(void) sendAccumulatedData:(BOOL)sendAfterInterval {
    __weak typeof(self) weakSelf = self;
    [_accessor writeWithBlock:^{
        if ([weakSelf.data count] > 0) {
            [ATTracker sendData:[NSArray arrayWithArray:weakSelf.data] retryIfTimeout:YES];
            [weakSelf.data removeAllObjects];
        }
    }];
    
    ATTrackingSetting *tkSetting = [ATAppSettingManager sharedManager].trackingSetting;
    if (sendAfterInterval && tkSetting.sendsDataEveryInterval > .0f) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(tkSetting.trackerInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf sendAccumulatedData:YES];
        });
    }
}

-(void) trackWithPlacementID:(NSString*)placementID requestID:(NSString*)requestID trackType:(ATNativeADTrackType)trackType extra:(NSDictionary*)extra {
    NSDictionary *dataElement = [ATTracker dataElementWithPlacementID:placementID requestID:requestID trackType:trackType extra:[extra isKindOfClass:[NSDictionary class]] ? [NSDictionary dictionaryWithDictionary:extra] : nil];
    ATPlacementModel *placementModel = [[ATPlacementSettingManager sharedManager] placementSettingWithPlacementID:placementID];
    if ((placementModel != nil && ![[ATAppSettingManager sharedManager].trackingSetting.tcTKSkipFormats[@(trackType).stringValue] containsObject:@(placementModel.format).stringValue]) || (extra[kATTrackerExtraFormatKey] != nil && ![[ATAppSettingManager sharedManager].trackingSetting.tcTKSkipFormats[@(trackType).stringValue] containsObject:[NSString stringWithFormat:@"%@", extra[kATTrackerExtraFormatKey]]]) || (placementModel == nil && [ATAppSettingManager sharedManager].trackingSetting.tcTKSkipFormats[@(trackType).stringValue] != nil)) {
        [self appendDataElement:dataElement];
//        NSLog(@"\n**************************Marvin_tk_element**************************\n%@\n**************************tk_element**************************\n", dataElement);
    }
    
    if (trackType == ATNativeAdTrackTypeShowAPICall) {
        id<ATAd> ad = extra[kATTrackerExtraAdObjectKey];
        NSString *notificationName = [ATAppSettingManager sharedManager].showNotificationName;
        if (ad.unitGroup.postsNotificationOnShow && notificationName != nil) { [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:ad.customObject userInfo:@{@"data":dataElement, @"common":[ATTracker commonParameters], @"nw_id":@(ad.unitGroup.networkFirmID), @"format":@(ad.placementModel.format)}]; }
    }
}

-(void) trackClickWithAd:(nonnull id<ATAd>)ad extra:(nullable NSDictionary*)extra {
    NSDictionary *dataElement = [ATTracker dataElementWithPlacementID:ad.placementModel.placementID requestID:ad.requestID trackType:ATNativeADTrackTypeADClicked extra:extra];
    ATPlacementModel *placementModel = ad.placementModel;
        if ((placementModel != nil && ![[ATAppSettingManager sharedManager].trackingSetting.tcTKSkipFormats[@(ATNativeADTrackTypeADClicked).stringValue] containsObject:@(placementModel.format).stringValue]) || (placementModel == nil && [ATAppSettingManager sharedManager].trackingSetting.tcTKSkipFormats[@(ATNativeADTrackTypeADClicked).stringValue] != nil)) {
            if (!(ad.unitGroup.clickTkDelayMin == -1 && ad.unitGroup.clickTkDelayMax == -1)) {
                    NSTimeInterval delayTime = (ad.unitGroup.clickTkDelayMin + arc4random_uniform(ad.unitGroup.clickTkDelayMax - ad.unitGroup.clickTkDelayMin)) / 1000.0f;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [ATTracker sendData:@[dataElement] address:ad.unitGroup.clickTkAddress retryIfTimeout:YES];
            //                    NSLog(@"\n**************************Marvin_tk_element**************************\n%@\n**************************tk_element**************************\n", dataElement);
                    });
                }
        }
    
    
    
    NSString *notificationName = [ATAppSettingManager sharedManager].clickNotificationName;
    if (ad.unitGroup.postsNotificationOnClick && notificationName != nil) { [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:ad.customObject userInfo:@{@"data":dataElement, @"common":[ATTracker commonParameters], @"nw_id":@(ad.unitGroup.networkFirmID), @"format":@(ad.placementModel.format)}]; }
}

+(NSString*) failedDataPath {
    return [[Utilities documentsPath] stringByAppendingPathComponent:@"com.anythink.FailedTKData"];
}

-(void) appendDataElement:(NSDictionary*)element {
    __weak typeof(self) weakSelf = self;
    [_accessor writeWithBlock:^{
        if ([element isKindOfClass:[NSDictionary class]]) { [weakSelf.data addObject:element]; }
        if ([ATTracker needsSendDataWithNumberOfElements:[weakSelf.data count]]) {
            [ATTracker sendData:[NSArray arrayWithArray:weakSelf.data] retryIfTimeout:YES];
            [weakSelf.data removeAllObjects];
        }
    }];
}

+(BOOL) needsSendDataWithNumberOfElements:(NSInteger)number {
    ATTrackingSetting *trackingSetting = [ATAppSettingManager sharedManager].trackingSetting;
    //Do not inspect interval between last send and current date
    return number >= trackingSetting.trackerNumberThreadhold;
}

+(void) sendData:(NSArray<NSDictionary*>*)data address:(NSString*)address retryIfTimeout:(BOOL)retry {
    NSString *dataStr = [[data jsonString_anythink] stringByBase64Encoding_anythink];
    NSString *commonStr = [[[ATTracker commonParameters] jsonString_anythink] stringByBase64Encoding_anythink];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"common":commonStr, @"data":dataStr, @"api_ver":@"1.0"}];
    parameters[@"sign"] = [Utilities computeSignWithParameters:parameters];
    
    NSArray<NSString*>* testDeviceIDFAList = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AnyThinkSDKTestDeviceIDFA"];
    if ([testDeviceIDFAList isKindOfClass:[NSArray class]] && [testDeviceIDFAList containsObject:[Utilities advertisingIdentifier]]) {
        NSMutableArray<NSDictionary*>* testFields = [NSMutableArray<NSDictionary*> array];
        [data enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *entry = [NSMutableDictionary dictionary];
            if (obj[@"type"] != nil) { entry[@"type"] = obj[@"type"]; }
            if (obj[@"nw_firm_id"] != nil) { entry[@"nw_firm_id"] = obj[@"nw_firm_id"]; }
            [testFields addObject:entry];
        }];
        parameters[@"test_fields"] = testFields;
    }
    
    NSString *trackAddress = address != nil ? address:[ATAppSettingManager sharedManager].trackingSetting.trackerAddress;
    
    switch ([ATAppSettingManager sharedManager].trackingSetting.trackerTCPType) {
        case 0://http
            [ATTracker sendHTTPRequestData:data address:trackAddress parameters:parameters retryIfTimeout:retry];
            break;
        case 1://tcp
            [ATTracker sendTCPRequestData:data parameters:parameters retryIfTimeout:retry];
            break;
        case 2://http&tcp
            [ATTracker sendTCPRequestData:data parameters:parameters retryIfTimeout:retry];
            [ATTracker sendHTTPRequestData:data address:trackAddress parameters:parameters retryIfTimeout:retry];
            break;
        default:
            break;
    }
}

+ (void)sendHTTPRequestData:(NSArray<NSDictionary*>*)data address:(NSString*)address parameters:(id)parameters retryIfTimeout:(BOOL)retry {
    [[ATNetworkingManager sharedManager] sendHTTPRequestToAddress:address HTTPMethod:ATNetworkingHTTPMethodPOST parameters:parameters completion:^(NSData * _Nonnull responseData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseStr = [NSString stringWithData:[responseData base64EncodedDataWithOptions:0] usingEncoding:NSUTF8StringEncoding];
        [ATLogger logMessage:[NSString stringWithFormat:@"request para:%@\n, result:%@", parameters, responseStr] type:ATLogTypeInternal];
        if ((error.code == NSURLErrorNetworkConnectionLost || error.code == NSURLErrorNotConnectedToInternet || error.code == 53) && retry) {
            [[ATTracker sharedTracker] saveFailedData:data];
        }
        if (((NSHTTPURLResponse*)response).statusCode != 200) {
            error = error != nil ? error : [NSError errorWithDomain:@"com.anythink.TKAPI" code:((NSHTTPURLResponse*)response).statusCode userInfo:@{NSLocalizedDescriptionKey:@"Request has failed", NSLocalizedFailureReasonErrorKey:@"TK server has failed to response correctly."}];
            [ATTracker saveAPIError:error withData:data tcpType:NO];
        }
    }];
}

+ (void)sendTCPRequestData:(NSArray<NSDictionary*>*)tcpData parameters:(id)parameters retryIfTimeout:(BOOL)retry {
    [[ATTCPLogManager sharedManager] sendTCPToOpenApi:ATTCPSocketOpenApiTracking paramters:parameters completion:^(NSData * _Nonnull data, NSError * _Nullable error) {
        // only save tcpData when trackerTCPType = 1
        if ([ATAppSettingManager sharedManager].trackingSetting.trackerTCPType == 1) {
            if (error) {
                [ATTracker saveAPIError:error withData:tcpData tcpType:YES];
            }
        }
    }];
}

+(void) sendData:(NSArray<NSDictionary*>*)data retryIfTimeout:(BOOL)retry {
    [ATTracker sendData:data address:[ATAppSettingManager sharedManager].trackingSetting.trackerAddress retryIfTimeout:retry];
}

-(void) saveFailedData:(NSArray<NSDictionary*>*)data {
    __weak typeof(self) weakSelf = self;
    [weakSelf.diskDataAccessor writeWithBlock:^{
        [data enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *dataToSave = [obj mutableCopy];
            dataToSave[@"ofl"] = @1;
            [weakSelf.diskData addObject:dataToSave];
        }];
        [weakSelf.diskData writeToFile:[ATTracker failedDataPath] atomically:YES];
    }];
}

+(void) saveAPIError:(NSError*)error withData:(NSArray<NSDictionary*>*)data tcpType:(BOOL)isTCPType{
    ATTrackingSetting *trackingSetting = [ATAppSettingManager sharedManager].trackingSetting;
    [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyNetworkRequestFail placementID:nil unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoAPINameKey:@"tk",
                                                                                                                                            kAgentEventExtraInfoNetworkErrorCodeKey:@(error.code),
                                                                                                                                            kAgentEventExtraInfoNetworkErrorMsgKey:[NSString stringWithFormat:@"%@", error],
                                                                                                                                            kAgentEventExtraInfoTKHostKey:trackingSetting.trackerAddress != nil ? trackingSetting.trackerAddress : @"",
                                                                                                                                   kAgentEventExtraInfoTrackerFailedCountKey:@(data.count),
                                                                                                                                   kAgentEventExtraInfoTrackerFailedProtocolTypeKey:isTCPType ? @1 : @0
                                                                                                                                   
                                                                                                                                            }];
}

+(NSDictionary*)dataElementWithPlacementID:(NSString*)placementID requestID:(NSString*)requestID trackType:(ATNativeADTrackType)trackType extra:(NSDictionary*)extra {
    NSMutableDictionary *element = [NSMutableDictionary dictionaryWithObjectsAndKeys:placementID != nil ? placementID : @"", @"pl_id", requestID != nil ? requestID : @"", @"req_id", @(trackType), @"type", nil];
    if (extra[kATTrackerExtraASIDKey] != nil) { element[@"asid"] = extra[kATTrackerExtraASIDKey]; }
    if (extra[kATTrackerExtraUGUnitIDKey] != nil) { element[@"unit_id"] = extra[kATTrackerExtraUGUnitIDKey]; }
    if (extra[kATTrackerExtraTrafficGroupIDKey] != nil) { element[@"traffic_group_id"] = extra[kATTrackerExtraTrafficGroupIDKey]; }
    
    if (extra[kATTrackerExtraAdShowSDKTimeKey] != nil) {
        element[kATTrackerExtraAdShowSDKTimeKey] = extra[kATTrackerExtraAdShowSDKTimeKey];
    } else {
        element[kATTrackerExtraAdShowSDKTimeKey] = [Utilities normalizedTimeStamp];
    }
    ATPlacementModel *placementModel = [[ATPlacementSettingManager sharedManager] placementSettingWithPlacementID:placementID];

    if (placementModel != nil) {
        element[@"format"] = @(placementModel.format);
        element[@"gro_id"] = @(placementModel.groupID);
    }
    if (extra[kATTrackerExtraFormatKey] != nil) { element[@"format"] = extra[kATTrackerExtraFormatKey]; }
    if (placementModel.asid != nil) { element[@"asid"] = placementModel.asid; }
    if (placementModel.trafficGroupID != nil) { element[@"traffic_group_id"] = placementModel.trafficGroupID; }
    if ([ATAPI sharedInstance].psID != nil) { element[@"ps_id"] = [ATAPI sharedInstance].psID; }
    if (placementID != nil && [[ATPlacementSettingManager sharedManager] sessionIDForPlacementID:placementID] != nil) { element[@"sessionid"] = [[ATPlacementSettingManager sharedManager] sessionIDForPlacementID:placementID]; }
    //Load
    if (extra[kATTrackerExtraSDKCalledFlagKey] != nil) { element[@"isload"] = [extra[kATTrackerExtraSDKCalledFlagKey] doubleValue] ? @1 : @0; }
    if (extra[kATTrackerExtraSDKNotCalledReasonKey] != nil) { element[@"reason"] = extra[kATTrackerExtraSDKNotCalledReasonKey]; }
    if (extra[kATTrackerExtraLoadTimeKey] != nil) { element[@"loadtime"] = extra[kATTrackerExtraLoadTimeKey]; }
    
    //Request
    if (extra[kATTrackerExtraUnitIDKey] != nil) { element[@"unit_id"] = extra[kATTrackerExtraUnitIDKey]; }
    if (extra[kATTrackerExtraNetworkFirmIDKey] != nil) { element[@"nw_firm_id"] = extra[kATTrackerExtraNetworkFirmIDKey]; }
    if (extra[kATTrackerExtraRefreshFlagKey] != nil || extra[kATTrackerExtraAutoloadOnCloseFlagKey] != nil) { element[@"refresh"] = @(([extra[kATTrackerExtraRefreshFlagKey] boolValue] || [extra[kATTrackerExtraAutoloadOnCloseFlagKey] boolValue]) ? 1 : 0); }
    if (extra[kATTrackerExtraAutoloadFlagKey] != nil || extra[kATTrackerExtraAdFilledByReadyFlagKey] != nil || extra[kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey] != nil || extra[kATTrackerExtraRequestExpectedOfferNumberFlagKey] != nil) { element[@"auto_req"] = @([extra[kATTrackerExtraRequestExpectedOfferNumberFlagKey] boolValue] ? 5 : ([extra[kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey] boolValue] ? 4 :([extra[kATTrackerExtraAdFilledByReadyFlagKey] boolValue] ? 3 : ([extra[kATTrackerExtraAutoloadFlagKey] boolValue] ? 1 : 2)))); }
    if (extra[kATTrackerExtraDefaultLoadFlagKey] != nil) { element[@"aprn_auto_req"] = @([extra[kATTrackerExtraDefaultLoadFlagKey] boolValue] ? 1 : 0); }
    
    //Fill
    if (extra[kATTrackerExtraFilledWithinNetworkTimeoutFlagKey] != nil) { element[@"status"] = @([extra[kATTrackerExtraFilledWithinNetworkTimeoutFlagKey] boolValue] ? 1 : 0); }
    if (extra[kATTrackerExtraFillRequestFlagKey] != nil) { element[@"flag"] = extra[kATTrackerExtraFillRequestFlagKey]; }
    if (extra[kATTrackerExtraFillTimeKey] != nil) { element[@"filledtime"] = extra[kATTrackerExtraFillTimeKey]; }
    
    //Header Biding
    if ([extra[kATTrackerExtraHeaderBiddingInfoKey] isKindOfClass:[NSDictionary class]]) { [element addEntriesFromDictionary:extra[kATTrackerExtraHeaderBiddingInfoKey]]; }
    
    //Show
    if (extra[kATTrackerExtraASResultKey] != nil) { element[@"as_result"] = extra[kATTrackerExtraASResultKey]; }
    if (extra[kATTrackerExtraLastestRequestIDKey] != nil) { element[@"new_req_id"] = extra[kATTrackerExtraLastestRequestIDKey]; }
    if (extra[kATTrackerExtraLastestRequestIDMatchFlagKey] != nil) { element[@"req_id_match"] = extra[kATTrackerExtraLastestRequestIDMatchFlagKey]; }

    if (extra[kATTrackerExtraMyOfferDefaultFalgKey] != nil) { element[@"myoffer_showtype"] = extra[kATTrackerExtraMyOfferDefaultFalgKey]; }
    
    //scene
    if (extra[kATTrackerExtraAdShowSceneKey] != nil) { element[@"scenario"] = extra[kATTrackerExtraAdShowSceneKey]; }
    
    //add statistics for show&impression
    if (trackType == ATNativeADTrackTypeADShow || trackType == ATNativeAdTrackTypeShowAPICall || trackType == ATNativeADTrackTypeADClicked) {
        [element addEntriesFromDictionary:@{@"ads":@([[ATCapsManager sharedManager] capByDayWithAdFormat:placementModel.format] + (trackType == ATNativeAdTrackTypeShowAPICall ? 1 : 0)),
                                            @"ahs":@([[ATCapsManager sharedManager] capByHourWithAdFormat:placementModel.format] + (trackType == ATNativeAdTrackTypeShowAPICall ? 1 : 0)),
                                            @"pds":@([[ATCapsManager sharedManager] capByDayWithPlacementID:placementModel.placementID] + (trackType == ATNativeAdTrackTypeShowAPICall ? 1 : 0)),
                                            @"phs":@([[ATCapsManager sharedManager] capByHourWithPlacementID:placementModel.placementID] + (trackType == ATNativeAdTrackTypeShowAPICall ? 1 : 0)),
        }];
    }
    return element;
}

+(NSDictionary*)commonParameters {
    NSMutableDictionary *common = [NSMutableDictionary dictionaryWithDictionary:@{@"app_id":[ATAPI sharedInstance].appID != nil ? [ATAPI sharedInstance].appID : @"",
                                                                                  @"system":@(1),
                                                                                  @"platform":[Utilities platform],
                                                                                  @"package_name":[Utilities appBundleID] != nil ? [Utilities appBundleID] : @"not_known",
                                                                                  @"app_vn":[Utilities appBundleVersion] != nil ? [Utilities appBundleVersion] : @"not_known",
                                                                                  @"app_vc":[Utilities appBundleVersion] != nil ? [Utilities appBundleVersion] : @"not_known",
                                                                                  @"sdk_ver":[ATAPI sharedInstance].version != nil ? [ATAPI sharedInstance].version : @"not_known",
                                                                                  @"orient":[Utilities screenOrientation] != nil ? [Utilities screenOrientation] : @0,
                                                                                  @"gdpr_cs":[NSString stringWithFormat:@"%ld", [[ATAppSettingManager sharedManager] commonTkDataConsentSet]]
    }];
    if ([[ATAPI sharedInstance].channel length] > 0) { common[@"channel"] = [ATAPI sharedInstance].channel; }
    if ([[ATAPI sharedInstance].subchannel length] > 0) { common[@"sub_channel"] = [ATAPI sharedInstance].subchannel; }
    if ([Utilities isBlankDictionary:[ATAPI sharedInstance].customData] == NO) {
        common[@"custom"] = [ATAPI sharedInstance].customData;
    }
    common[@"first_init_time"] = @((NSUInteger)([[ATAPI firstLaunchDate] timeIntervalSince1970] * 1000.0f));
    common[@"days_from_first_init"] = @([[NSDate date] numberOfDaysSinceDate:[ATAPI firstLaunchDate]]);
    
    NSString *ABTestID = [ATAppSettingManager sharedManager].ABTestID;
    if (ABTestID != nil) { common[@"abtest_id"] = ABTestID; }
    
    common[@"tcp_tk_da_type"] = @([ATAppSettingManager sharedManager].trackingSetting.trackerTCPType);
    common[@"tcp_rate"] = [[ATAppSettingManager sharedManager].trackingSetting.trackerTCPRate length] > 0 ? [ATAppSettingManager sharedManager].trackingSetting.trackerTCPRate : @"";
    
    if ([[ATAppSettingManager sharedManager] shouldUploadProtectedFields]) {
        [common addEntriesFromDictionary:@{@"os_vn":[Utilities systemName] != nil ? [Utilities systemName] : @"not_known",
                                           @"os_vc":[Utilities systemVersion] != nil ? [Utilities systemVersion] : @"not_known",
                                           @"brand":[Utilities brand] != nil ? [Utilities brand] : @"not_known",
                                           @"model":[Utilities model] != nil ? [Utilities model] : @"not_known",
                                           @"screen":[Utilities screenResolution] != nil ? [Utilities screenResolution] : @"not_known",
                                           @"network_type":[ATNetworkingManager currentNetworkType] != nil ? [ATNetworkingManager currentNetworkType] : @1,
                                           @"mnc":[Utilities mobileNetworkCode] != nil ? [Utilities mobileNetworkCode] : @"not_known",
                                           @"mcc":[Utilities mobileCountryCode] != nil ? [Utilities mobileCountryCode] : @"not_known",
                                           @"language":[Utilities language] != nil ? [Utilities language] : @"not_known",
                                           @"timezone":[Utilities timezone] != nil ? [Utilities timezone] : @"not_known",
                                           @"ua":[Utilities userAgent] != nil ? [Utilities userAgent] : @"not_known",
                                           @"idfa":[Utilities advertisingIdentifier] != nil ? [Utilities advertisingIdentifier] : @"not_known",
                                           @"idfv":[Utilities idfv] != nil ? [Utilities idfv] : @"not_known",
                                           @"upid":[[ATAppSettingManager sharedManager].ATID length] > 0 ? [ATAppSettingManager sharedManager].ATID : @""
                                           }];
    } else {
        [common addEntriesFromDictionary:@{@"os_vn":@"",
                                           @"os_vc":@"",
                                           @"brand":@"",
                                           @"model":@"",
                                           @"screen":@"",
                                           @"network_type":@"",
                                           @"mnc":@"",
                                           @"mcc":@"",
                                           @"language":@"",
                                           @"timezone":@"",
                                           @"ua":@"",
                                           @"idfa":@"",
                                           @"idfv":@""
                                           }];
    }
    return common;
}

+(NSDictionary*)headerBiddingTrackingExtraWithAd:(id<ATAd>)ad requestID:(NSString*)requestID {
    return @{@"bidtype":@(ad.unitGroup.headerBidding ? 1 : 0), @"bidprice":@(ad.price)};
}
@end
