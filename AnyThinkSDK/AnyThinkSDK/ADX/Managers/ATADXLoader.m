//
//  ATADXLoader.m
//  AnyThinkSDK
//
//  Created by stephen on 20/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//


#import "ATADXLoader.h"
#import "ATNetworkingManager.h"
#import "ATAPI.h"
#import "Utilities.h"
#import "ATADXOfferModel.h"
#import "ATThreadSafeAccessor.h"
#import "ATLogger.h"
#import "ATAppSettingManager.h"
#import "ATPlacementSettingManager.h"
#import "ATAPI.h"
#import "ATADXTracker.h"


@interface ATADXLoader()
@property(nonatomic, readonly) ATThreadSafeAccessor *adxLoaderAccessor;
//cache offermodel with key(placementId_unitId)
@property(nonatomic, readonly) NSMutableDictionary<NSString*, ATADXOfferModel*>* offerModelDict;

@end

@implementation ATADXLoader
#pragma mark - init
+(instancetype) sharedLoader {
    static ATADXLoader *sharedLoader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLoader = [[ATADXLoader alloc] init];
    });
    return sharedLoader;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _adxLoaderAccessor = [ATThreadSafeAccessor new];
        _offerModelDict = [NSMutableDictionary<NSString*, ATADXOfferModel*> dictionary];
        
        [self initOfferModelFromDisk];
    }
    return self;
}

-(NSString*) adxOfferModelsArchivePath {
    return [[Utilities documentsPath] stringByAppendingPathComponent:@"com.anythink.adx.offermodel"];
}

-(NSString*) offerModelPathForSaveKey:(NSString*)saveKey{
    return [[self adxOfferModelsArchivePath] stringByAppendingPathComponent:saveKey];
}

-(NSString*) saveKeyWithPlacementID:(NSString*)placementID unitID:(NSString *) unitID{
    return [NSString stringWithFormat:@"%@_%@", placementID, unitID];
}

-(void) initOfferModelFromDisk {
  
    AT_SafelyRun(^{
        if (![[NSFileManager defaultManager] fileExistsAtPath:[self adxOfferModelsArchivePath]]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:[self adxOfferModelsArchivePath] withIntermediateDirectories:NO attributes:nil error:nil];
        }
        //get adx offer from disk
        [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self adxOfferModelsArchivePath] error:nil] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *path = [[self adxOfferModelsArchivePath] stringByAppendingPathComponent:obj];
            NSString *contentStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
            NSDictionary *offerModelDict = [NSJSONSerialization JSONObjectWithData: [contentStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            if ([offerModelDict isKindOfClass:[NSDictionary class]]) {
                NSDictionary * content = nil;
                NSArray<NSDictionary*>* bidArray = offerModelDict[@"seatbid"];
                if(bidArray != nil && bidArray.count>0){
                    content = offerModelDict[@"at_content"];
                }
                _offerModelDict[obj] = [[ATADXOfferModel alloc] initWithDictionary:offerModelDict content:content];
            }
        }];
    });
    
}

-(void) requestADXAdsWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel bidInfo:(ATBidInfo*) bidInfo requestID:(NSString*)requestID placementModel:(ATPlacementModel *)placementModel content:(NSDictionary *)content completion:(void(^)(ATADXOfferModel *offerModel, NSError *error))completion {
   
    if(unitGroupModel == nil || bidInfo == nil){
         completion(nil, [NSError errorWithDomain:@"com.anythink.adxRequest" code:ATADLoadingADXFailedCode userInfo:@{NSLocalizedDescriptionKey:@"adx request has failed", NSLocalizedFailureReasonErrorKey:@"adx request has failed"}]);
        
        return;
    }
    ATADXOfferModel* offerModel = [self offerModelWithPlacementID:placementModel.placementID unitGroupModel:unitGroupModel];
    if(offerModel != nil && !offerModel.isExpired){
        completion(offerModel, nil);
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *pStr = [[[ATADXLoader parametersWithPlacementModel:placementModel] jsonString_anythink] stringByBase64Encoding_anythink];
        NSString *p2Str = [[[ATADXLoader parameter2] jsonString_anythink] stringByBase64Encoding_anythink];

        NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:pStr, @"p", p2Str, @"p2", requestID, @"request_id", bidInfo.bidId, @"bid_id", nil];
        
        //send ad request and parse ad detail response
        [[ATNetworkingManager sharedManager] sendHTTPRequestToAddress:[ATAppSettingManager sharedManager].adxSetting.reqHttpAddress HTTPMethod:ATNetworkingHTTPMethodPOST parameters:para gzip:NO completion:^(NSData * _Nonnull data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            __block NSDictionary *responseObject = nil;
            //AT_SafelyRun is used to guard against exception that's beyond our precaution, which includes the nullability of responseData.
            AT_SafelyRun(^{ responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil]; });
            if ([responseObject isKindOfClass:[NSDictionary class]] && [responseObject[@"data"] isKindOfClass:[NSDictionary class]]) {
                if (completion != nil) {
                    //parse adx result
                    NSMutableDictionary* resultDictionary = [[NSMutableDictionary alloc] initWithDictionary:responseObject[@"data"]];
                    [resultDictionary setObject:@([bidInfo.expireDate timeIntervalSince1970]) forKey:@"expire_timestamp"];
                    [resultDictionary setObject:placementModel.placementID forKey:@"at_placement_id"];
                    [resultDictionary setObject:unitGroupModel.unitID forKey:@"at_unit_id"];
                    [resultDictionary setObject:[NSString stringWithFormat:@"%ld", placementModel.format] forKey:@"at_format"];
                    [resultDictionary setObject:requestID forKey:@"at_request_id"];
                    NSArray<NSDictionary*>* bidArray = resultDictionary[@"seatbid"];
                    if(bidArray != nil && bidArray.count>0){
                        NSDictionary* contentDict = @{@"s_c_t":content[@"s_c_t"],@"v_m":content[@"v_m"]};
                        [resultDictionary setObject:contentDict forKey:@"at_content"];
                    }
                    ATADXOfferModel* offerModel = [[ATADXOfferModel alloc] initWithDictionary:resultDictionary content:content];
                    //save ad
                    [self saveOfferWithDictionary:resultDictionary offerModel:offerModel saveKey:[self saveKeyWithPlacementID:placementModel.placementID unitID:unitGroupModel.unitID]];
                    
                    //send nurl when adx request is response
                    [[ATADXTracker sharedTracker] trackEvent:ATADXTrackerEventNTKurl offerModel:offerModel extra:nil];
                    //download res
                    completion(offerModel, nil);
                }
            } else {
                if (completion != nil) {
                    if (error == nil) { error = [NSError errorWithDomain:@"com.anythink.adxRequest" code:[responseObject[@"code"] integerValue] userInfo:@{NSLocalizedDescriptionKey:@"adx request has failed", NSLocalizedFailureReasonErrorKey:[responseObject[@"msg"] isKindOfClass:[NSString class]] ? responseObject[@"msg"] : @"adx request has failed"}]; }
                  
                    completion(nil, error);
                }
            }
        }];
    });
    
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
                            @"upid":[[ATAppSettingManager sharedManager].ATID length] > 0 ? [ATAppSettingManager sharedManager].ATID : @"",
                            @"sys_id":[[ATAppSettingManager sharedManager].SYSID length] > 0 ? [ATAppSettingManager sharedManager].SYSID : @"",
                            @"bkup_id":[[ATAppSettingManager sharedManager].BKUPID length] > 0 ? [ATAppSettingManager sharedManager].BKUPID : @""};
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
                                       @"app_vc":[Utilities appBundleVersionCode],
                                       @"sdk_ver":[ATAPI sharedInstance].version,
                                       @"nw_ver":@{},//[Utilities networkVersions]
                                       @"orient":[Utilities screenOrientation],
                                       @"system":@(1),
                                       @"gdpr_cs":[NSString stringWithFormat:@"%ld", [[ATAppSettingManager sharedManager] commonTkDataConsentSet]],
                                       @"t_g_id":placementModel.trafficGroupID,
                                       @"gro_id":@(placementModel.groupID)
                                       };
    [parameters addEntriesFromDictionary:nonSubjectFields];
    [parameters addEntriesFromDictionary:protectedFields];
    if ([[ATAPI sharedInstance].channel length] > 0) { parameters[@"channel"] = [ATAPI sharedInstance].channel; }
    if ([[ATAPI sharedInstance].subchannel length] > 0) { parameters[@"sub_channel"] = [ATAPI sharedInstance].subchannel; }

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

-(BOOL) readyADXAdWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel placementID:(NSString *)placementID {
    ATADXOfferModel* offerModel = self.offerModelDict[[self saveKeyWithPlacementID:placementID unitID:unitGroupModel.unitID]];
    if(offerModel != nil && !offerModel.isExpired){
        return YES;
    }
    return NO;
}

-(ATADXOfferModel*) offerModelWithPlacementID:(NSString *) placementID unitGroupModel:(ATUnitGroupModel*)unitGroupModel {
    ATADXOfferModel* offerModel = self.offerModelDict[[self saveKeyWithPlacementID:placementID unitID:unitGroupModel.unitID]];
    if(offerModel != nil && !offerModel.isExpired){
        return offerModel;
    }
    return nil;
}

-(void) saveOfferWithDictionary:(NSDictionary*)resultDictionary offerModel:(ATADXOfferModel *) offerModel saveKey:(NSString *) saveKey{
    [_adxLoaderAccessor writeWithBlock:^{
        [_offerModelDict setObject:offerModel forKey:saveKey];
        NSString *path = [self offerModelPathForSaveKey:saveKey];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDictionary options:0 error:0];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [jsonString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }];
    
}
-(void) removeOfferModel:(ATADXOfferModel*)offerModel {
    [_adxLoaderAccessor writeWithBlock:^{
        [_offerModelDict removeObjectForKey:[self saveKeyWithPlacementID:offerModel.placementID unitID:offerModel.unitID]];
        [[NSFileManager defaultManager] removeItemAtPath:[self offerModelPathForSaveKey:[self saveKeyWithPlacementID:offerModel.placementID unitID:offerModel.unitID]] error:nil];
    }];
  
}
-(void) clearOfferModelWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel placementID:(NSString *) placementID {
    
}

@end
