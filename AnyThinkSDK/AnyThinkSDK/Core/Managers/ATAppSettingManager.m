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
#import "ATKeychain.h"

NSString *const kATAppSettingGDPAFlag = @"gdpr_ia";
NSString *const kATAppSettingGDPRPolicyURLKey = @"gdpr_nu";

static NSString *const kATAppSettingDataProtectedArea = @"gdpr_a";
static NSString *const kATAppSettingExpireIntervalKey = @"scet";
static NSString *const kATAppSettingSplashTimeoutKey = @"pl_n";
static NSString *const kATAppSettingDefaultFlagKey = @"embeded_default_setting";
static NSString *const kATAppSettingUsesServerConsentFlagKey = @"gdpr_so";
static NSString *const kATAppSettingThirdPartySDKConsentDefaultFlagKey = @"nw_eu_def";

static NSString *const kUserDefaultsATIDKey = @"com.anythink.data.up_id";
static NSString *const kUserDefaultsGDPRFlagKey = @"com.anythink.data.gdpr_flag";

static NSString *const kUserDefaultsSYSIDKey = @"com.exc.7BEDD788.sys";
static NSString *const kUserDefaultsBKUPIDKey = @"com.exc.C43EB5CC.bk";

@interface ATAppSettingManager()
@property(nonatomic, readonly) ATThreadSafeAccessor *settingAccessor;
@property(nonatomic) NSDictionary *currentSetting_impl;
@property(nonatomic) ATTrackingSetting *trackingSetting_impl;
@property(nonatomic) ATADXSetting *adxSetting_impl;
@property(nonatomic, readonly) NSDate *currentSettingExpireDate;
@property(atomic) BOOL loading;
@property(nonatomic, readonly) NSArray<NSString*>* GDPRAreas;
@property(nonatomic, readonly) NSDictionary<NSString*, NSString*>* notifications;

@property(nonatomic, copy) NSString *kSYSID;
@property(nonatomic, copy) NSString *kATID;
@property(nonatomic, copy) NSString *kBKUPID;

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
            if (![currentSetting_impl containsObjectForKey:kATAppSettingDataProtectedArea]) currentSetting_impl[kATAppSettingDataProtectedArea] = self->_GDPRAreas;
            self->_currentSetting_impl = currentSetting_impl;
            _trackingSetting_impl = [_currentSetting_impl[@"logger"] isKindOfClass:[NSDictionary class]] ? [[ATTrackingSetting alloc] initWithDictionary:_currentSetting_impl[@"logger"]] : [ATTrackingSetting defaultSetting];
            
            if ([_currentSetting_impl[@"n_l"] isKindOfClass:[NSString class]]) { _notifications = [NSJSONSerialization JSONObjectWithData:[_currentSetting_impl[@"n_l"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil]; }
            [self preinitFilterAdapter:_currentSetting_impl[@"preinit"]];
            
             _adxSetting_impl = [_currentSetting_impl[@"adx"] isKindOfClass:[NSDictionary class]] ? [[ATADXSetting alloc] initWithDictionary:_currentSetting_impl[@"adx"]] : [ATADXSetting defaultSetting];
            
            _currentSettingExpireDate = archivedSettingInfo[kSettingArchiveExpireDateKey];
            if ([_currentSettingExpireDate isKindOfClass:[NSDate class]]) {
                NSTimeInterval interval = [_currentSettingExpireDate timeIntervalSinceDate:[NSDate date]];
                if (interval > 0) { dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ [self requestAppSettingCompletion:^(NSDictionary *setting, NSError *error) { }]; }); }
            }
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkAppSetting:) name:kATADLoadingStartLoadNotification object:nil];
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
        [[NSUserDefaults standardUserDefaults] setValue:_currentSetting_impl[kATAppSettingGDPAFlag] != nil ? _currentSetting_impl[kATAppSettingGDPAFlag] : @0 forKey:kUserDefaultsGDPRFlagKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([_currentSetting_impl[@"logger"] isKindOfClass:[NSDictionary class]]) { _trackingSetting_impl = [[ATTrackingSetting alloc] initWithDictionary:_currentSetting_impl[@"logger"]]; }
        _currentSettingExpireDate = [NSDate dateWithTimeIntervalSinceNow:[_currentSetting_impl[kATAppSettingExpireIntervalKey] floatValue] / 1000.0f];
        if ([_currentSetting_impl[@"n_l"] isKindOfClass:[NSString class]]) { _notifications = [NSJSONSerialization JSONObjectWithData:[_currentSetting_impl[@"n_l"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil]; }
        [self preinitFilterAdapter:_currentSetting_impl[@"preinit"]];
         if ([_currentSetting_impl[@"adx"] isKindOfClass:[NSDictionary class]]) { _adxSetting_impl = [[ATADXSetting alloc] initWithDictionary:_currentSetting_impl[@"adx"]]; }
        NSDictionary *settingToSave = @{kSettingArchiveSettingKey:_currentSetting_impl, kSettingArchiveExpireDateKey:_currentSettingExpireDate};
        [settingToSave writeToFile:[ATAppSettingManager appSettingFilePath] atomically:YES];
        if ([currentSetting count] > 0) { [self scheduleSettingUpdate:_currentSetting_impl]; }
    }];
}

-(void) scheduleSettingUpdate:(NSDictionary*)setting {
    NSTimeInterval expireInterval = [setting[kATAppSettingDefaultFlagKey] boolValue] ? 1800000.0f : [setting[kATAppSettingExpireIntervalKey] doubleValue];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(expireInterval / 1000.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ [self requestAppSettingCompletion:^(NSDictionary *setting, NSError *error) { }]; });
}

-(ATTrackingSetting*) trackingSetting {
    return [_settingAccessor readWithBlock:^id{ return _trackingSetting_impl; }];
}

-(ATADXSetting*) adxSetting {
    return [_settingAccessor readWithBlock:^id{ return _adxSetting_impl; }];
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
-(BOOL) limitThirdPartySDKDataCollectionWithAgentEventExtra:(NSDictionary**)extra setThirdPartySDK:(BOOL*)setThirdPartySDK networkFirmID:(NSInteger)networkFirmID {
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
                    if (networkFirmID != 0) { extraInfo[kAgentEventExtraInfoNetworkFirmIDKey] = @(networkFirmID); }
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
                        if (networkFirmID != 0) { extraInfo[kAgentEventExtraInfoNetworkFirmIDKey] = @(networkFirmID); }
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

-(BOOL)limitThirdPartySDKDataCollection:(BOOL*)setThirdPartySDK networkFirmID:(NSInteger)networkFirmID {
//    NSLog(@"Marvin -- 限制敏感信息上报（1为限制）:%d",[self limitThirdPartySDKDataCollectionWithAgentEventExtra:nil setThirdPartySDK:setThirdPartySDK]);
//    NSLog(@"Marvin -- set是否设置第三方network:%d",*setThirdPartySDK);

    return [self limitThirdPartySDKDataCollectionWithAgentEventExtra:nil setThirdPartySDK:setThirdPartySDK networkFirmID:networkFirmID];
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
    } else if (dataConsent == 1) {
        return 0;
    } else {
        return 2;
    }
}

-(NSTimeInterval)psIDInterval {
    return [[ATAppSettingManager sharedManager].currentSetting[@"n_psid_tm"] doubleValue] / 1000.0f;
}

-(NSTimeInterval) psIDIntervalForHotLaunch {
    return [[ATAppSettingManager sharedManager].currentSetting[@"psid_hl"] doubleValue] / 1000.0f;
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        id<ATAdAdapter> adapterPreInit = [[NSClassFromString(adapter) alloc] initWithNetworkCustomInfo:content localInfo:nil];
    });
}

/**
 Default setting
 */
-(NSDictionary*)defaultSetting {
    return @{kATAppSettingGDPRPolicyURLKey:@"https://img.anythinktech.com/gdpr/PrivacyPolicySetting.html", kATAppSettingDataProtectedArea :_GDPRAreas, @"gdpr_so":@0, @"gdpr_sdcs":@0, @"n_psid_tm":@30000, kATAppSettingDefaultFlagKey:@YES};
}

/**
 check appsetting
 */
-(void) checkAppSetting:(NSNotification*)noti {
    if ([[ATAppSettingManager sharedManager] currentSettingExpired]) {
        [[ATAppSettingManager sharedManager] requestAppSettingCompletion:^(NSDictionary *setting, NSError *error) {
        }];
    }
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

-(void) getUserLocationWithCallback:(void(^)(ATUserLocation location))callback {
    NSDictionary *appSetting = [ATAppSettingManager sharedManager].currentSetting;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsGDPRFlagKey] == nil) {
        NSNumber *timestamp = [Utilities normalizedTimeStamp];
#ifdef UNDER_DEVELOPMENT
        NSString *host = @"http://test.aa.toponad.com/v1/open/eu";
#else
        NSString *host = @"https://api.anythinktech.com/v1/open/eu";
#endif
        
        NSString *address = [NSString stringWithFormat:@"%@?t=%@&sign=%@", host, timestamp, [NSString stringWithFormat:@"%@", timestamp].md5];
        [[ATNetworkingManager sharedManager] sendHTTPRequestToAddress:address HTTPMethod:ATNetworkingHTTPMethodPOST parameters:@{} completion:^(NSData * _Nonnull data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error != nil) {
                callback(ATUserLocationUnknown);
            } else {
                __block NSDictionary *responseObject = nil;
                //AT_SafelyRun is used to guard against exception that's beyond our precaution, which includes the nullability of responseData.
                AT_SafelyRun(^{ responseObject = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithBase64EncodedData:data options:0] options:NSJSONReadingMutableContainers error:nil]; });
                if ([responseObject isKindOfClass:[NSDictionary class]] && [responseObject[@"data"] isKindOfClass:[NSDictionary class]] && [responseObject[@"data"][@"is_eu"] respondsToSelector:@selector(integerValue)]) {
                    callback([responseObject[@"data"][@"is_eu"] integerValue] == 1 ? ATUserLocationInEU : ATUserLocationOutOfEU);
                } else {
                    callback(ATUserLocationUnknown);
                }
            }
        }];
    } else {
        callback([[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsGDPRFlagKey] boolValue] ? ATUserLocationInEU : ATUserLocationOutOfEU);
    }
}

-(NSString*) ATID {
    if (_kATID == nil) {
        if (_currentSetting_impl[@"upid"]) {
            _kATID = _currentSetting_impl[@"upid"];
        } else {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsATIDKey]) {
                _kATID = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsATIDKey];
            } else {
                if ([Utilities advertisingIdentifier] && [[Utilities advertisingIdentifier] length] > 0 && [Utilities validateDeviceId:[Utilities advertisingIdentifier]]) {
                    _kATID = [Utilities advertisingIdentifier].md5;
                } else {
                    NSString *tmpId = [Utilities validateDeviceId:[Utilities idfv]]?[Utilities idfv]:[NSString stringWithFormat:@"%@&%@&%d", [Utilities userAgent], [Utilities normalizedTimeStamp], arc4random_uniform(10000)];
                    _kATID = tmpId.md5;
                }
                [[NSUserDefaults standardUserDefaults] setObject:_kATID forKey:kUserDefaultsATIDKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{ [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyPSIDSessionIDGeneration placementID:nil unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoGeneratedIDTypeKey:@3}];
                });
            }
        }
    }
    return _kATID;
}

-(NSString*) SYSID {
    if (_kSYSID == nil) {
        if (_currentSetting_impl[@"sy_id"]) {
            _kSYSID = _currentSetting_impl[@"sy_id"];
            if (![[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsSYSIDKey] || [ATKeychain searchDateWithService:kUserDefaultsSYSIDKey] == nil) {
                // save to keychain again
                [ATKeychain saveData:_kSYSID withService:kUserDefaultsSYSIDKey];
                // save to user default again
                [[NSUserDefaults standardUserDefaults] setObject:_kSYSID forKey:kUserDefaultsSYSIDKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }else{
            // first check system_id on user default storage.
            if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsSYSIDKey]) {
                _kSYSID = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsSYSIDKey];
            }else {
                // then check system_id on keychain storage.
                _kSYSID = [ATKeychain searchDateWithService:kUserDefaultsSYSIDKey];
                if (_kSYSID != nil) {
                    // save to user default again
                    [[NSUserDefaults standardUserDefaults] setObject:_kSYSID forKey:kUserDefaultsSYSIDKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        }
    }
    return  _kSYSID;
}

-(NSString*) BKUPID {
    if (_kBKUPID == nil) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsBKUPIDKey]) {
            _kBKUPID = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsBKUPIDKey];
        }else {
            // BKUPID nil
            // then check system_id on keychain storage.
            _kBKUPID = [ATKeychain searchDateWithService:kUserDefaultsBKUPIDKey];
            if (_kBKUPID == nil) {
                _kBKUPID = [self ATID];
                // save to keychain again
                [ATKeychain saveData:_kBKUPID withService:kUserDefaultsBKUPIDKey];
                // save to user default again
                [[NSUserDefaults standardUserDefaults] setObject:_kBKUPID forKey:kUserDefaultsBKUPIDKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
    return _kBKUPID;
}

-(NSString*)ABTestID {
    return [self currentSetting][@"abtest_id"];
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
                if ([weakSelf limitThirdPartySDKDataCollectionWithAgentEventExtra:&agentEventExtraInfo setThirdPartySDK:NULL networkFirmID:0]) { if (agentEventExtraInfo != nil) { [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyGDPRLevelKey placementID:nil unitGroupModel:nil extraInfo:agentEventExtraInfo]; } }
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
                [self scheduleSettingUpdate:[self currentSetting]];
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
                            @"upid":[[ATAppSettingManager sharedManager].ATID length] > 0 ? [ATAppSettingManager sharedManager].ATID : @"",
                            @"sy_id":[[ATAppSettingManager sharedManager].SYSID length] > 0 ? [ATAppSettingManager sharedManager].SYSID : @"",
                            @"bk_id":[[ATAppSettingManager sharedManager].BKUPID length] > 0 ? [ATAppSettingManager sharedManager].BKUPID : @""};
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
                                       @"app_vc":[Utilities appBundleVersionCode],
                                       @"sdk_ver":[ATAPI sharedInstance].version,
                                       @"nw_ver":@{},//[Utilities networkVersions]
                                       @"orient":[Utilities screenOrientation],
                                       @"system":@(1),
                                       @"gdpr_cs":[NSString stringWithFormat:@"%ld", [[ATAppSettingManager sharedManager] commonTkDataConsentSet]]
                                       };
    [parameters addEntriesFromDictionary:nonSubjectFields];
    [parameters addEntriesFromDictionary:protectedFields];
    if ([[ATAPI sharedInstance].psID length] > 0) { parameters[@"ps_id"] = [ATAPI sharedInstance].psID; }
    if ([[ATAPI sharedInstance].channel length] > 0) { parameters[@"channel"] = [ATAPI sharedInstance].channel; }
    if ([[ATAPI sharedInstance].subchannel length] > 0) { parameters[@"sub_channel"] = [ATAPI sharedInstance].subchannel; }
    parameters[@"first_init_time"] = @((NSUInteger)([[ATAPI firstLaunchDate] timeIntervalSince1970] * 1000.0f));
    parameters[@"days_from_first_init"] = @([[NSDate date] numberOfDaysSinceDate:[ATAPI firstLaunchDate]]);
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
    return [[self alloc] initWithDictionary:@{@"tk_address":@"https://tk.anythinktech.com/v1/open/tk", @"tk_max_amount":@8, @"tk_interval":@10000,
                                              @"da_address":@"https://da.anythinktech.com/v1/open/da", @"da_max_amount":@8, @"da_interval":@1800000,
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
        
        //TCP
        _trackerTCPAddress = dictionary[@"tcp_domain"];
        _trackerTCPPort = [dictionary[@"tcp_port"] integerValue];
        _trackerTCPType = [dictionary[@"tcp_tk_da_type"] integerValue];
        _trackerTCPRate = dictionary[@"tcp_rate"];
        
        NSString *key = @"da_not_keys_ft";
        if ([dictionary[key] isKindOfClass:[NSString class]] && [dictionary[key] dataUsingEncoding:NSUTF8StringEncoding] != nil) { _agentEventDropFormats = [NSJSONSerialization JSONObjectWithData:[dictionary[key] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil]; }
//        _agentEventDropFormats = @{@"1004630":@[@"0"]};
        
        key = @"da_rt_keys_ft";
        if ([dictionary[key] isKindOfClass:[NSString class]] && [dictionary[key] dataUsingEncoding:NSUTF8StringEncoding] != nil) { _agentEventRTFormats = [NSJSONSerialization JSONObjectWithData:[dictionary[key] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil]; }
//        _agentEventRTFormats = @{@"1004631":@[@"1"]};
        
        _agentEventBatNumberThreadhold = [dictionary[@"da_max_amount"] integerValue];
        _agentEventBatInterval = [dictionary[@"da_interval"] doubleValue] / 1000.0f;
        
        key = @"up_da_li";
        if ([dictionary[key] isKindOfClass:[NSString class]] && [dictionary[key] dataUsingEncoding:NSUTF8StringEncoding] != nil) { _tcHosts = [NSJSONSerialization JSONObjectWithData:[[dictionary[key] base64DecodingUsingTable:kBase64Table1] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil]; }
        
        key = @"tk_no_t_ft";
        if ([dictionary[key] isKindOfClass:[NSString class]] && [dictionary[key]
            dataUsingEncoding:NSUTF8StringEncoding] != nil) { _tcTKSkipFormats = [NSJSONSerialization JSONObjectWithData:[dictionary[key] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil]; }
//        _tcTKSkipFormats = @{@"1":@[@"1", @"2"]};
    }
    return self;
}
@end


@implementation ATADXSetting
+(instancetype) defaultSetting {
    return [[self alloc] initWithDictionary:@{@"req_addr":@"https://adx.anythinktech.com/request", @"bid_sw":@1,
                                              @"bid_addr":@"https://adx.anythinktech.com/bid", @"req_sw":@1,
                                              @"tk_addr":@"https://adxtk.anythinktech.com/v1", @"tk_sw":@1,
                                              kATAppSettingDefaultFlagKey:@YES
                                              }];
}

-(instancetype) initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self != nil) {
        _reqHttpAddress = dictionary[@"req_addr"];
        _reqTCPAdress = dictionary[@"req_tcp_addr"];
        _reqTCPPort = [dictionary[@"req_tcp_port"] intValue];
        _reqNetType = [dictionary[@"req_sw"] intValue];
        
        _bidHttpAddress = dictionary[@"bid_addr"];
        _bidTCPAdress = dictionary[@"bid_tcp_addr"];
        _bidTCPPort = [dictionary[@"bid_tcp_port"] intValue];
        _bidNetType = [dictionary[@"bid_sw"] intValue];
        
        _trackerHttpAdress = dictionary[@"tk_addr"];
        _trackerTCPAdress = dictionary[@"tk_tcp_addr"];
        _trackerTCPPort = [dictionary[@"tk_tcp_port"] intValue];
        _trackerNetType = [dictionary[@"tk_sw"] intValue];
        
    }
    return self;
}
@end
