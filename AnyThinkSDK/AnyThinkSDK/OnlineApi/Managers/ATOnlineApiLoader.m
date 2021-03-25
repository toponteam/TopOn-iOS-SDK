//
//  ATOnlineApiLoader.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/15.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiLoader.h"
#import "ATThreadSafeAccessor.h"
#import "ATBidInfo.h"
#import "ATPlacementModel.h"
#import "ATUnitGroupModel.h"
#import "ATOnlineApiOfferModel.h"
#import "Utilities.h"
#import "ATPlacementSettingManager.h"
#import "ATAppSettingManager.h"
#import "ATOnlineApiTracker.h"
#import "ATNetworkingManager.h"
#import "NSData+KAKit.h"
#import "NSObject+KAKit.h"
#import "ATRequestConfiguration.h"

NSString *excludeOffersKey = @"excludeOffersKey";
@interface ATOnlineApiLoader ()
{
    NSString *localPath;
    NSFileManager *manager;
}
@property(nonatomic, readonly) ATThreadSafeAccessor *olApiLoaderAccessor;
@property(nonatomic, readonly) ATThreadSafeAccessor *olApiOfferIDsAccessor;
//cache offermodel with key(placementId_unitId)
@property(nonatomic, readonly) NSMutableDictionary<NSString*, ATOnlineApiOfferModel*>* modelsDic;
@property(nonatomic, strong) NSMutableDictionary *offersIdDic;;
@end

@implementation ATOnlineApiLoader

// MARK:- initialization

+(instancetype) sharedLoader {
    static ATOnlineApiLoader *sharedLoader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLoader = [[ATOnlineApiLoader alloc] init];
    });
    return sharedLoader;
}

- (instancetype) init {
    self = [super init];
    if (self != nil) {
        _olApiLoaderAccessor = [ATThreadSafeAccessor new];
        _olApiOfferIDsAccessor = [ATThreadSafeAccessor new];
        _modelsDic = [NSMutableDictionary<NSString*, ATOnlineApiOfferModel*> dictionary];
            
        manager = [NSFileManager defaultManager];
        localPath = [[Utilities documentsPath] stringByAppendingPathComponent:@"com.anythink.adx.offermodel"];
        [self getModelsFromDisk];
    }
    return self;
}

// MARK:- functions claimed in .h

- (void)requestOnlineApiAdsWithConfiguration:(ATRequestConfiguration *)config {
    
    ATOnlineApiOfferModel* model = [self readyOnlineApiAdWithUnitGroupModelID:config.unitID placementID:config.setting.placementID];
    if (model) {
        config.callback(model, nil);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSString *p_paramStr = [[self paramsWithConfiguration:config] jsonString_anythink];
        NSString *p_paramStr_base64 = [p_paramStr stringByBase64Encoding_anythink];
        
        NSString *p2_paramStr = [[self parameter2] jsonString_anythink];
        NSString *p2_paramStr_base64 = [p2_paramStr stringByBase64Encoding_anythink];
        
        NSMutableDictionary *param = @{
            @"p": p_paramStr_base64,
            @"p2": p2_paramStr_base64,
            @"request_id": config.requestID != nil ? config.requestID : @"",
            @"ad_source_id":@([config.unitID integerValue]),
            @"ad_num":@(1),
            @"exclude_offers": [self readShownAdWithOfferID:config.setting.lastOfferidsNum unitID:config.unitID]
        }.mutableCopy;
        if (config.bannerHight) {
            [param setValue:@(config.bannerHight) forKey:@"ad_height"];
        }
        if (config.bannerWidth) {
            [param setValue:@(config.bannerWidth) forKey:@"ad_width"];
        }

        config.requestParam = param;
        
        [self requestWithParam_impl:config];
        
    });
}

- (void)removeOfferModel:(ATOnlineApiOfferModel *)offerModel {
    
    [_olApiLoaderAccessor writeWithBlock:^{
        [self removeOfferModel_impl:offerModel];
    }];
}

- (ATOnlineApiOfferModel *)readyOnlineApiAdWithUnitGroupModelID:(NSString *)unitGroupModelID placementID:(NSString *)placementID {
    
    NSString *key = [self cacheKeyWithPlacementID:placementID unitGroupModelID:unitGroupModelID];
    ATOnlineApiOfferModel *model = _modelsDic[key];
    
    return model.isExpired ? nil : model;
}

- (void)initialOfferIdsDic {
    if (self.offersIdDic == nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *localDic = [defaults valueForKey:excludeOffersKey];
        self.offersIdDic = [NSMutableDictionary dictionaryWithDictionary:localDic];
    }
    
}
- (void)recordShownAdWithOfferID:(NSString *)offerID unitID:(NSString *)uid {
    [_olApiOfferIDsAccessor writeWithBlock:^{
        
        [self initialOfferIdsDic];
        
        NSMutableArray *offerIDs = [NSMutableArray arrayWithArray:[self.offersIdDic valueForKey:uid]];
        [offerIDs insertObject:offerID atIndex:0];
        if (offerIDs.count > 50) {
            [offerIDs removeLastObject];
        }
        [self.offersIdDic setValue:offerIDs forKey:uid];
        [[NSUserDefaults standardUserDefaults] setValue:self.offersIdDic forKey:excludeOffersKey];
        
    }];
}

- (NSArray *)readShownAdWithOfferID:(NSInteger)num unitID:(NSString *)uid {
    return [_olApiOfferIDsAccessor readWithBlock:^id{
        
        [self initialOfferIdsDic];
        
        NSMutableArray *offerIds = [NSMutableArray arrayWithArray:[self.offersIdDic valueForKey:uid]];
        if (offerIds.count < num) {
            return offerIds;
        }
        NSArray *target = [offerIds subarrayWithRange:NSMakeRange(0, num)];
        return target;
    }];
}

//- (ATOnlineApiOfferModel *)offerModelWithPlacementID:(NSString *)placementID unitGroupModelID:(NSString *)unitGroupModelID {
//
//    NSString *key = [self cacheKeyWithPlacementID:placementID unitGroupModelID:unitGroupModelID];
//    ATOnlineApiOfferModel *model = _modelsDic[key];
//
//    return model.isExpired ? nil : model;
//}

// MARK:- private methods
- (void)getModelsFromDisk {
    AT_SafelyRun(^{
        [self getModelsFromDisk_impl];
    });
}

- (void)getModelsFromDisk_impl {
    
    __block NSString *filePath = localPath;
    BOOL fileExisted = [manager fileExistsAtPath: filePath];
    if (fileExisted == NO) {
        [manager createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSArray<NSString *> *subpaths = [manager contentsOfDirectoryAtPath:filePath error:nil];
    [subpaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *objPath = [filePath stringByAppendingPathComponent:obj];
        NSString *content = [NSString stringWithContentsOfFile:objPath encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dictionary = data.dictionary;
        
        if (dictionary.isDictionary) {
            NSDictionary *contentDic = nil;
            NSArray<NSDictionary *> *offerArr = dictionary[@"offers"];
            if ([Utilities isEmpty:offerArr] == NO) {
                contentDic = offerArr.firstObject;
            }
            self.modelsDic[obj] = [[ATOnlineApiOfferModel alloc]initWithDictionary:dictionary content:contentDic];
        }
    }];
}

- (void)removeOfferModel_impl:(ATOnlineApiOfferModel *)model {
    
    
    NSString *key = [self cacheKeyWithPlacementID:model.placementID unitGroupModelID:model.unitID];
    [_modelsDic removeObjectForKey:key];
    NSString *finalPath = [localPath stringByAppendingPathComponent:key];
    [manager removeItemAtPath:finalPath error:nil];
}

- (NSString *)cacheKeyWithPlacementID:(NSString *)p_id unitGroupModelID:(NSString *)u_id {
    return [NSString stringWithFormat:@"%@_%@", p_id, u_id];
}

- (void)requestWithParam_impl:(ATRequestConfiguration *)configuration {
    
    NSString *address = [ATAppSettingManager sharedManager].onlineApiSetting.reqHttpAddress;
    
    [[ATNetworkingManager sharedManager] sendHTTPRequestToAddress:address HTTPMethod:ATNetworkingHTTPMethodPOST parameters:configuration.requestParam gzip:NO completion:^(NSData * _Nonnull data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        AT_SafelyRun(^{
            [self handleResponseData:data configuration:configuration];
        });
    }];
}

- (void)handleResponseData:(NSData *)data configuration:(ATRequestConfiguration *)config {
    
    if (config.callback == nil) {
        return;
    }
    
    NSDictionary *respObj = data.dictionary;
    NSDictionary *dataDic = respObj[@"data"];
    if (dataDic.isDictionary == NO) {
        
        NSError *error = [NSError errorWithDomain:@"com.anythink.adxRequest" code:[respObj[@"code"] integerValue] userInfo:@{NSLocalizedDescriptionKey:@"onlineApi request has failed", NSLocalizedFailureReasonErrorKey:[respObj[@"msg"] isKindOfClass:[NSString class]] ? respObj[@"msg"] : @"onlineApi request has failed"}];
        config.callback(nil, error);
        return;
    }
    
    NSString *key = [self cacheKeyWithPlacementID:config.setting.placementID unitGroupModelID:config.unitID];
    ATOnlineApiOfferModel *model = [self convertDataToModelAndStoreToDisk:dataDic config:config storeKey:key];
    
    [_modelsDic setValue:model forKey:key];
        
    config.callback(model, nil);
}

- (void)storeModelToDisk:(NSString *)key data:(NSDictionary *)dic {

    NSString *path = [localPath stringByAppendingPathComponent:key];
    [_olApiLoaderAccessor writeWithBlock:^{
        
        NSString *dataStr = [dic jsonString_anythink];
        [dataStr writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }];
}

- (ATOnlineApiOfferModel *) convertDataToModelAndStoreToDisk:(NSDictionary *)dataDic config:(ATRequestConfiguration *)config storeKey:(NSString *)key {
    
    NSMutableDictionary *m_dataDic = dataDic.mutableCopy;
    [m_dataDic setValue:config.setting.placementID forKey:@"at_placement_id"];
    [m_dataDic setValue:config.unitID forKey:@"at_unit_id"];
    [m_dataDic setValue:config.requestID forKey:@"at_request_id"];
    [m_dataDic setValue:@(config.format).stringValue forKey:@"at_format"];
    [m_dataDic setValue:@(config.networkFirmID).stringValue forKey:@"at_networkFirmID"];
    
    [self storeModelToDisk:key data:m_dataDic];
    
    ATOnlineApiOfferModel *model = [[ATOnlineApiOfferModel alloc] initWithDictionary:m_dataDic content:config.extraInfo];
    return model;
}

// MARK:- parameters
- (NSDictionary *)paramsWithConfiguration:(ATRequestConfiguration *)config {
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSDictionary *protectedDatas = [self protectedDatas:config];
    
    NSDictionary *nonSubjectDatas = [self nonSubjectFieldsFor:config];
    
    [params addEntriesFromDictionary:nonSubjectDatas];
    [params addEntriesFromDictionary:protectedDatas];
    
    [params setValue:[[ATAPI sharedInstance] channel] forKey:@"channel"];
    [params setValue:[[ATAPI sharedInstance] subchannel] forKey:@"sub_channel"];
    [params setValue:[ATAppSettingManager sharedManager].ABTestID forKey:@"abtest_id"];
    
    return params;
}

- (NSDictionary *)parameter2 {
    BOOL should = [[ATAppSettingManager sharedManager] shouldUploadProtectedFields];
    
    NSDictionary *dic = @{
        @"idfa": should ? [Utilities advertisingIdentifier] : @"",
        @"idfv": should ? [Utilities idfv] : @""
    };
    
    return dic;
}

- (NSDictionary *)nonSubjectFieldsFor:(ATRequestConfiguration *)config {
    
    NSString *sessionID = [[ATPlacementSettingManager sharedManager] sessionIDForPlacementID:config.setting.placementID];

    NSDictionary *dic = @{@"app_id":[ATAPI sharedInstance].appID,
                                              @"platform":[Utilities platform],
                                              @"pl_id":config.setting.placementID,
                                              @"ps_id":[ATAPI sharedInstance].psID != nil ? [ATAPI sharedInstance].psID : @"",
                                              @"session_id":sessionID != nil ? sessionID : @"",
                                              @"package_name":[Utilities appBundleID],
                                              @"app_vn":[Utilities appBundleVersion],
                                              @"app_vc":[Utilities appBundleVersionCode],
                                              @"sdk_ver":[ATAPI sharedInstance].version,
                                              @"nw_ver":@{},
                                              @"orient":[Utilities screenOrientation],
                                              @"system":@1,
                                              @"gdpr_cs":[NSString stringWithFormat:@"%ld", (long)[[ATAppSettingManager sharedManager] commonTkDataConsentSet]]
                                              };
    return dic;
}

- (NSDictionary *)protectedDatas:(ATRequestConfiguration *)config {
    BOOL should = [[ATAppSettingManager sharedManager] shouldUploadProtectedFields];
    NSMutableDictionary *dic = @{
        @"os_vn": should ? [Utilities systemName] : @"",
        @"os_vc": should ? [Utilities systemVersion] : @"",
        @"network_type": should ? [ATNetworkingManager currentNetworkType] : @"",
        @"mnc": should ? [Utilities mobileNetworkCode] : @"",
        @"mcc": should ? [Utilities mobileCountryCode] : @"",
        @"language": should ? [Utilities language] : @"",
        @"brand": should ? [Utilities brand] : @"",
        @"model": should ? [Utilities model] : @"",
        @"timezone": should ? [Utilities timezone] : @"",
        @"screen": should ? [Utilities screenResolution] : @"",
        @"ua": should ? [Utilities userAgent] : @"",
        @"t_g_id":config.trafficGroupID,
        @"gro_id":@(config.groupID),
        @"pl_id":config.setting.placementID,
    }.mutableCopy;
    
    if (should) {
        [dic setValue:[ATAppSettingManager sharedManager].ATID forKey:@"upid"];
        [dic setValue:[ATAppSettingManager sharedManager].SYSID forKey:@"sys_id"];
        [dic setValue:[ATAppSettingManager sharedManager].BKUPID forKey:@"bkup_id"];
    }

    return dic;
}
@end
