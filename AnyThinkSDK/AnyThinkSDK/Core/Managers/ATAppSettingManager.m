//
//  ATAppSettingManager.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 09/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAppSettingManager.h"
#import "ATNetworkingManager.h"
#import "ATThreadSafeAccessor.h"
#import "ATAPI.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATLogger.h"
#import "ATAgentEvent.h"

NSString *const kATAppSettingGDPAFlag = @"gdpr_ia";
NSString *const kATAppSettingGDPRPolicyURLKey = @"gdpr_nu";

static NSString *const kATAppSettingDataProtectedArea = @"gdpr_a";
static NSString *const kATAppSettingExpireIntervalKey = @"scet";
static NSString *const kATAppSettingSplashTimeoutKey = @"pl_n";
static NSString *const kATAppSettingDefaultFlagKey = @"embeded_default_setting";
static NSString *const kATAppSettingUsesServerConsentFlagKey = @"gdpr_so";
static NSString *const kATAppSettingThirdPartySDKConsentDefaultFlagKey = @"nw_eu_def";

static NSString *const kUserDefaultsATIDKey = @"com.anythink.data.up_id";
@interface ATAppSettingManager()
@property(nonatomic, readonly) ATThreadSafeAccessor *settingAccessor;
@property(nonatomic) NSDictionary *currentSetting_impl;
@property(nonatomic) ATTrackingSetting *trackingSetting_impl;
@property(nonatomic, readonly) NSDate *currentSettingExpireDate;
@property(atomic) BOOL loading;
@property(nonatomic, readonly) NSArray<NSString*>* GDPRAreas;
@property(nonatomic, readonly) NSDictionary<NSString*, NSString*>* notifications;
@end

static NSString *const kBase64Table1 = @"dMWnhbeyKr0J+IvLNOx3BFkEuml92/5fjSqGT7R8pZVciPHAstC4UXa6QDw1gozY";
static NSString *const kBase64Table2 = @"xZnV5k+DvSoajc7dRzpHLYhJ46lt0U3QrWifGyNgb9P1OIKmCEuq8sw/XMeBAT2F";
@implementation ATAppSettingManager
+(instancetype)sharedManager {
    static ATAppSettingManager *sharedManager = nil;
    __block BOOL launch = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        launch = YES;
        sharedManager = [[ATAppSettingManager alloc] init];
    });
    return sharedManager;
}

static NSString *const kSettingArchiveSettingKey = @"setting";
static NSString *const kSettingArchiveExpireDateKey = @"expire_date";
-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _settingAccessor = [ATThreadSafeAccessor new];
        
        _GDPRAreas = @[@"AT", @"BE", @"BG", @"HR", @"CY", @"CZ", @"DK", @"EE", @"FI", @"FR", @"DE", @"GR", @"HU", @"IS", @"IE", @"IT", @"LV", @"LI", @"LT", @"LU", @"MT", @"NL", @"NO", @"PL", @"PT", @"RO", @"SK", @"SI", @"ES", @"SE", @"GB", @"UK"];
        
        AT_SafelyRun(^{
            NSDictionary *archivedSettingInfo = nil;
            if ([NSDictionary respondsToSelector:@selector(dictionaryWithContentsOfURL:error:)]) {
                archivedSettingInfo = [NSDictionary dictionaryWithContentsOfURL:[NSURL fileURLWithPath:[ATAppSettingManager appSettingFilePath]] error:nil];
            } else {
                archivedSettingInfo = [NSDictionary dictionaryWithContentsOfFile:[ATAppSettingManager appSettingFilePath]];
            }
            NSMutableDictionary *currentSetting_impl = [NSMutableDictionary dictionaryWithDictionary:archivedSettingInfo[kSettingArchiveSettingKey]];
            if ([currentSetting_impl count] == 0) { currentSetting_impl[kATAppSettingDefaultFlagKey] = @YES; }
            if (![currentSetting_impl containsObjectForKey:kATAppSettingDataProtectedArea]) currentSetting_impl[kATAppSettingDataProtectedArea] = _GDPRAreas;
            _currentSetting_impl = currentSetting_impl;
            _trackingSetting_impl = [_currentSetting_impl[@"logger"] isKindOfClass:[NSDictionary class]] ? [[ATTrackingSetting alloc] initWithDictionary:_currentSetting_impl[@"logger"]] : [ATTrackingSetting defaultSetting];
            
            if ([_currentSetting_impl[@"n_l"] isKindOfClass:[NSString class]]) {
                _notifications = [NSJSONSerialization JSONObjectWithData:[_currentSetting_impl[@"n_l"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            }
            [self preinitFilterAdapter:_currentSetting_impl[@"preinit"]];
            [ATLogger logMessage:[NSString stringWithFormat:@"AppSetting read from archive:%@", archivedSettingInfo] type:ATLogTypeInternal];
            _currentSettingExpireDate = archivedSettingInfo[kSettingArchiveExpireDateKey];
            if ([_currentSettingExpireDate isKindOfClass:[NSDate class]]) {
                NSTimeInterval interval = [_currentSettingExpireDate timeIntervalSinceDate:[NSDate date]];
                if (interval > 0) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self requestAppSettingCompletion:^(NSDictionary *setting, NSError *error) {
                            //
                        }];
                    });
                }
            }
        });
        
    }
    return self;
}

-(NSTimeInterval) splashTolerateTimeout {
    NSDictionary *curSetting = self.currentSetting;
    if ([curSetting containsObjectForKey:kATAppSettingSplashTimeoutKey]) {
        return [curSetting[kATAppSettingSplashTimeoutKey] doubleValue] / 1000.0f;
    } else {
        return 5.0f;
    }
}

-(void) setCurrentSetting:(NSDictionary *)currentSetting {
    [_settingAccessor writeWithBlock:^{
        _currentSetting_impl = currentSetting;
        if ([_currentSetting_impl[@"logger"] isKindOfClass:[NSDictionary class]]) { _trackingSetting_impl = [[ATTrackingSetting alloc] initWithDictionary:_currentSetting_impl[@"logger"]]; }
        _currentSettingExpireDate = [NSDate dateWithTimeIntervalSinceNow:[_currentSetting_impl[kATAppSettingExpireIntervalKey] floatValue] / 1000.0f];
        if ([_currentSetting_impl[@"n_l"] isKindOfClass:[NSString class]]) {
            _notifications = [NSJSONSerialization JSONObjectWithData:[_currentSetting_impl[@"n_l"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        }
        [self preinitFilterAdapter:_currentSetting_impl[@"preinit"]];
        NSDictionary *settingToSave = @{kSettingArchiveSettingKey:_currentSetting_impl,
                                        kSettingArchiveExpireDateKey:_currentSettingExpireDate
                                        };
        [settingToSave writeToFile:[ATAppSettingManager appSettingFilePath] atomically:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([_currentSetting_impl[kATAppSettingExpireIntervalKey] floatValue] / 1000.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self requestAppSettingCompletion:^(NSDictionary *setting, NSError *error) {
                //
            }];
        });
    }];
}

-(ATTrackingSetting*) trackingSetting {
    return [_settingAccessor readWithBlock:^id{ return _trackingSetting_impl; }];
}

+(BOOL) validateATID:(NSString*)ATID {
    return [ATID isKindOfClass:[NSString class]] && [ATID length] > 0;
}

-(NSUInteger) myOfferMaxResourceLength {
    return [self.currentSetting[@"c_a"] unsignedIntegerValue] * 1024;
}

//From server to local
NSInteger ConvertServerDataConsentSet(NSDictionary *appSetting) {
    return [@{@0:@(ATDataConsentSetPersonalized), @1:@(ATDataConsentSetNonpersonalized)}[appSetting[@"gdpr_sdcs"]] integerValue];
}

//From dev to server
NSInteger ConvertDevDataConsentSet(ATDataConsentSet consent) {
    return [@{@(ATDataConsentSetUnknown):@2, @(ATDataConsentSetNonpersonalized):@1, @(ATDataConsentSetPersonalized):@0}[@([ATAPI sharedInstance].dataConsentSet)] integerValue];
}

-(BOOL)shouldUploadProtectedFields {
    NSDictionary *appSetting = self.currentSetting;
    if ([appSetting[kATAppSettingDefaultFlagKey] boolValue]) {//No server setting
        return [ATAPI sharedInstance].dataConsentSet != ATDataConsentSetNonpersonalized;
    } else {
        if ([appSetting[kATAppSettingGDPAFlag] boolValue]) {
            return [appSetting[kATAppSettingUsesServerConsentFlagKey] boolValue] ? ConvertServerDataConsentSet(appSetting) == ATDataConsentSetPersonalized : [ATAPI sharedInstance].dataConsentSet == ATDataConsentSetPersonalized;
        } else {
            return YES;
        }
    }
}

//return value: whether limit third party sdk data collection
//setThirdPartySDK whether invoke third party sdk data collection API
-(BOOL) limitThirdPartySDKDataCollectionWithAgentEventExtra:(NSDictionary**)extra setThirdPartySDK:(BOOL*)setThirdPartySDK {
    BOOL limit = NO;
    BOOL set = NO;
    NSDictionary *appSetting = self.currentSetting;
    if ([appSetting[kATAppSettingDefaultFlagKey] boolValue]) {//No server setting
        limit = [ATAPI sharedInstance].dataConsentSet == ATDataConsentSetNonpersonalized;
        set = [ATAPI sharedInstance].dataConsentSet != ATDataConsentSetUnknown;
    } else {
        NSMutableDictionary *extraInfo = [NSMutableDictionary dictionaryWithCapacity:3];
        if ([ATAPI sharedInstance].dataConsentSet == ATDataConsentSetUnknown) {
            if ([appSetting[kATAppSettingGDPAFlag] boolValue]) {
                if (![appSetting[kATAppSettingThirdPartySDKConsentDefaultFlagKey] boolValue]) {
                    limit = YES;
                    set = YES;
                    extraInfo[kAgentEventExtraInfoGDPRThirdPartySDKLevelKey] = @1;
                    extraInfo[kAgentEventExtraInfoGDPRDevConsentKey] = @(ConvertDevDataConsentSet([ATAPI sharedInstance].dataConsentSet));
                    extraInfo[kAgentEventExtraInfoServerGDPRIAValueKey] = appSetting[kATAppSettingGDPAFlag];
                }
            }
        } else {
            if ([appSetting[kATAppSettingUsesServerConsentFlagKey] boolValue]) {
                if (ConvertServerDataConsentSet(appSetting) == ATDataConsentSetNonpersonalized) {
                    limit = YES;
                    set = YES;
                } else {
                    set = YES;
                }
            } else {
                if ([ATAPI sharedInstance].dataConsentSet == ATDataConsentSetNonpersonalized) {
                    if ([appSetting[kATAppSettingGDPAFlag] boolValue]) {
                        set = YES;
                        limit = YES;
                    } else {
                        set = YES;
                        extraInfo[kAgentEventExtraInfoGDPRThirdPartySDKLevelKey] = @2;
                        extraInfo[kAgentEventExtraInfoGDPRDevConsentKey] = @(ConvertDevDataConsentSet([ATAPI sharedInstance].dataConsentSet));
                        extraInfo[kAgentEventExtraInfoServerGDPRIAValueKey] = appSetting[kATAppSettingGDPAFlag];
                        [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyGDPRLevelKey placementID:nil unitGroupModel:nil extraInfo:extraInfo];
                    }
                } else {
                    set = YES;
                }
            }
        }
        if (extra != nil) { *extra = extraInfo; }
        
    }
    if (setThirdPartySDK != NULL) { *setThirdPartySDK = set; }
    return limit;
}

-(BOOL)limitThirdPartySDKDataCollection:(BOOL*)setThirdPartySDK {
//    NSLog(@"Marvin -- 限制敏感信息上报（1为限制）:%d",[self limitThirdPartySDKDataCollectionWithAgentEventExtra:nil setThirdPartySDK:setThirdPartySDK]);
//    NSLog(@"Marvin -- set是否设置第三方network:%d",*setThirdPartySDK);

    return [self limitThirdPartySDKDataCollectionWithAgentEventExtra:nil setThirdPartySDK:setThirdPartySDK];
}

-(BOOL) usesServerDataConsentSet {
    return [[ATAppSettingManager sharedManager].currentSetting[kATAppSettingUsesServerConsentFlagKey] boolValue];
}

-(ATDataConsentSet) serverDataConsentSet {
    return [@{@0:@(ATDataConsentSetPersonalized), @1:@(ATDataConsentSetNonpersonalized)}[[ATAppSettingManager sharedManager].currentSetting[@"gdpr_sdcs"]] integerValue];
}

-(ATDataConsentSet) commonTkDataConsentSet {
    ATDataConsentSet dataConsent = [ATAPI sharedInstance].dataConsentSet;
    if (dataConsent == 2) {
        return 1;
    }else if (dataConsent == 1) {
        return 0;
    }else {
        return 2;
    }
}

-(NSTimeInterval)psIDInterval {
    return [[ATAppSettingManager sharedManager].currentSetting[@"n_psid_tm"] doubleValue] / 1000.0f;
}

-(NSString*)showNotificationName {
    return [ATAppSettingManager sharedManager].notifications[@"show"];
}

-(NSString*)clickNotificationName {
    return [ATAppSettingManager sharedManager].notifications[@"click"];
}

-(NSArray *) preinitInfoArr {
    return [ATAppSettingManager sharedManager].currentSetting[@"preinit"];
}

//preinit
-(void) preinitFilterAdapter:(NSArray*)preInitInfo {
    [preInitInfo enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *adapters = [NSArray arrayWithArray:object[@"adapter"]];
        NSDictionary *contentInfo = [NSJSONSerialization JSONObjectWithData:[object[@"content"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        [adapters enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (NSClassFromString([NSString stringWithFormat:@"%@",obj]) != nil) {
                [self preInitNetwrok:obj withContent:contentInfo];
                *stop = YES;
            }
        }];
    }];
}

-(void) preInitNetwrok:(NSString *)adapter withContent:(NSDictionary *)content {
    dispatch_async(dispatch_get_main_queue(), ^{
        id<ATAdAdapter> adapterPreInit = [[NSClassFromString(adapter) alloc] initWithNetworkCustomInfo:content];
    });
}

/**
 Default setting
 */
-(NSDictionary*)defaultSetting {
    return @{kATAppSettingGDPRPolicyURLKey:@"http://img.toponad.com/gdpr/PrivacyPolicySetting.html", kATAppSettingDataProtectedArea :_GDPRAreas, @"gdpr_so":@0, @"gdpr_sdcs":@0, @"n_psid_tm":@30000, kATAppSettingDefaultFlagKey:@YES};
}

-(BOOL) currentSettingExpired {
    return ![[_settingAccessor readWithBlock:^id{
        return @(_currentSettingExpireDate != nil && [[NSDate date] timeIntervalSinceDate:_currentSettingExpireDate] <= (NSTimeInterval).0f);
    }] boolValue];
}

-(BOOL) inDataProtectedArea {
    NSDictionary *appSetting = [[ATAppSettingManager sharedManager].currentSetting count] > 0 ? [ATAppSettingManager sharedManager].currentSetting : [ATAppSettingManager sharedManager].defaultSetting;
    return [appSetting[kATAppSettingGDPAFlag] boolValue];
}

-(NSString*) ATID {
    __block NSString *UPID;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_currentSetting_impl[@"upid"]) {
            UPID = _currentSetting_impl[@"upid"];
        } else {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsATIDKey]) {
                UPID = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsATIDKey];
            } else {
                if ([[ATAPI sharedInstance] inDataProtectionArea] && [ATAPI sharedInstance].dataConsentSet != ATDataConsentSetPersonalized) {
                    UPID = [NSString stringWithFormat:@"%@%@",[Utilities idfv],@"topon123xyz"].md5;
                } else {
                    if ([Utilities advertisingIdentifier] && [[Utilities advertisingIdentifier] length] > 0) {
                        UPID = [Utilities advertisingIdentifier].md5;
                    } else {
                        UPID = [Utilities idfv].md5;
                    }
                }
                [[NSUserDefaults standardUserDefaults] setObject:UPID forKey:kUserDefaultsATIDKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    });
    return UPID != nil ? UPID : [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsATIDKey];
}

-(NSDictionary*)currentSetting {
    return [_settingAccessor readWithBlock:^id{
        return [NSDictionary dictionaryWithDictionary:_currentSetting_impl];
    }];
}

-(void) requestAppSettingCompletion:(void(^)(NSDictionary *setting, NSError *error))completion {
    NSString *pStr = [[[ATAppSettingManager parameters] jsonString_anythink] stringByBase64Encoding_anythink];
    NSString *p2Str = [[[ATAppSettingManager parameters2] jsonString_anythink] stringByBase64Encoding_anythink];
    NSMutableDictionary *para = [NSMutableDictionary dictionaryWithObjectsAndKeys:pStr, @"p", p2Str, @"p2", @"1.0", @"api_ver", nil];
    para[@"sign"] = [Utilities computeSignWithParameters:para];
    
    __weak typeof(self) weakSelf = self;
    if (!self.loading) {
        self.loading = YES;
        NSNumber *requestTimestamp = [Utilities normalizedTimeStamp];
        [[ATNetworkingManager sharedManager] sendHTTPRequestToDomain:kAPIDomain path:@"v1/open/app" HTTPMethod:ATNetworkingHTTPMethodPOST parameters:para completion:^(NSData*  _Nonnull data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            __block NSDictionary *responseObject = nil;
            //AT_SafelyRun is used to guard against exception that's beyond our precaution, which includes the nullability of responseData.
            AT_SafelyRun(^{ responseObject = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithBase64EncodedData:data options:0] options:NSJSONReadingMutableContainers error:nil]; });
            [ATLogger logMessage:[NSString stringWithFormat:@"App setting request response:%@", responseObject] type:ATLogTypeInternal];
            if ([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"data"] != nil && [responseObject[@"data"] isKindOfClass:[NSDictionary class]]) {
                weakSelf.currentSetting = responseObject[@"data"];
                NSDictionary *agentEventExtraInfo = nil;
                if ([weakSelf limitThirdPartySDKDataCollectionWithAgentEventExtra:&agentEventExtraInfo setThirdPartySDK:NULL]) {
                    if (agentEventExtraInfo != nil) {
                        [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyGDPRLevelKey placementID:nil unitGroupModel:nil extraInfo:agentEventExtraInfo];
                    }
                }
                [ATAgentEvent saveRequestAPIName:@"app" requestDate:requestTimestamp responseDate:[Utilities normalizedTimeStamp] extra:nil];
                completion(responseObject[@"data"], nil);
            } else {
                [ATLogger logError:@"Invalid response has been received from the server, which might result from invalid App ID and/or App Key." type:ATLogTypeExternal];
                error = error != nil ? error : [NSError errorWithDomain:NSURLErrorDomain code:404 userInfo:@{NSLocalizedDescriptionKey:@"App setting update failed", NSLocalizedFailureReasonErrorKey:@"The response does not contain any data."}];
                [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyNetworkRequestFail placementID:nil unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoAPINameKey:@"app",
                                                                                                                                                kAgentEventExtraInfoNetworkErrorCodeKey:@(error.code),
                                                                                                                                                kAgentEventExtraInfoNetworkErrorMsgKey:[NSString stringWithFormat:@"%@", error],
                                                                                                                                      kAgentEventExtraInfoTKHostKey:@"aa.toponad.com"
                                                                                                                                                }];
                completion(nil, error);
            }
            weakSelf.loading = NO;
        }];
    } else {
        [ATLogger logWarning:@"App setting request being made too frequently" type:ATLogTypeInternal];
    }
}

+(NSDictionary*)parameters {
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
    
    NSDictionary *nonSubjectFields = @{@"app_id":[ATAPI sharedInstance].appID,
                                       @"platform":[Utilities platform],
                                       @"package_name":[Utilities appBundleID],
                                       @"app_vn":[Utilities appBundleVersion],
                                       @"app_vc":[Utilities appBundleVersion],
                                       @"sdk_ver":[ATAPI sharedInstance].version,
                                       @"nw_ver":[Utilities networkVersions],
                                       @"orient":[Utilities screenOrientation],
                                       @"system":@(1)
                                       };
    [parameters addEntriesFromDictionary:nonSubjectFields];
    [parameters addEntriesFromDictionary:protectedFields];
    if ([[ATAPI sharedInstance].psID length] > 0) { parameters[@"ps_id"] = [ATAPI sharedInstance].psID; }
    if ([[ATAPI sharedInstance].channel length] > 0) { parameters[@"channel"] = [ATAPI sharedInstance].channel; }
    if ([[ATAPI sharedInstance].subchannel length] > 0) { parameters[@"sub_channel"] = [ATAPI sharedInstance].subchannel; }
    return parameters;
}

+(NSDictionary*)parameters2 {
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

+(NSString*) appSettingFilePath {
    return [[Utilities documentsPath] stringByAppendingPathComponent:@"appSetting.com.anythink"];
}
@end

@implementation ATTrackingSetting
+(instancetype) defaultSetting {
    return [[self alloc] initWithDictionary:@{@"tk_address":@"https://tt.toponad.com/v2/tk", @"tk_max_amount":@8, @"tk_interval":@10000,
                                              @"da_address":@"https://dd.toponad.com/v2/da", @"da_max_amount":@8, @"da_interval":@1800000,
                                              kATAppSettingDefaultFlagKey:@YES
                                              }];
}

-(instancetype) initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self != nil) {
        _trackerAddress = dictionary[@"tk_address"];
        _trackerNumberThreadhold = [dictionary[@"tk_max_amount"] integerValue];
        _trackerInterval = [dictionary[@"tk_interval"] doubleValue] / 1000.0f;
        _sendsDataEveryInterval = [dictionary[@"tk_timer_sw"] boolValue];

        _agentEventAddress = dictionary[@"da_address"];
        _agentEventNumberThreadhold = _trackerNumberThreadhold;
        _agentEventInterval = _trackerInterval;
        
        if ([dictionary[@"da_not_keys"] isKindOfClass:[NSString class]] && [dictionary[@"da_not_keys"] dataUsingEncoding:NSUTF8StringEncoding] != nil) { _agentEventDropKeys = [NSJSONSerialization JSONObjectWithData:[dictionary[@"da_not_keys"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil]; }
        if ([dictionary[@"da_rt_keys"] isKindOfClass:[NSString class]] && [dictionary[@"da_rt_keys"] dataUsingEncoding:NSUTF8StringEncoding] != nil) { _agentEventRTKeys = [NSJSONSerialization JSONObjectWithData:[dictionary[@"da_rt_keys"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil]; }
        
        _agentEventBatNumberThreadhold = [dictionary[@"da_max_amount"] integerValue];
        _agentEventBatInterval = [dictionary[@"da_interval"] doubleValue] / 1000.0f;
        
        if ([dictionary[@"up_da_li"] isKindOfClass:[NSString class]] && [dictionary[@"up_da_li"] dataUsingEncoding:NSUTF8StringEncoding] != nil) { _tcHosts = [NSJSONSerialization JSONObjectWithData:[[dictionary[@"up_da_li"] base64DecodingUsingTable:kBase64Table1] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil]; }
        if ([dictionary[@"tk_no_t"] isKindOfClass:[NSString class]] && [dictionary[@"tk_no_t"]
            dataUsingEncoding:NSUTF8StringEncoding] != nil) { _tcTKSkipTypes = [NSJSONSerialization JSONObjectWithData:[dictionary[@"tk_no_t"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil]; }
    }
    return self;
}
@end
