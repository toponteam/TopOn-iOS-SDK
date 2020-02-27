//
//  ATIronSourceInterstitialAdapter.m
//  AnyThinkIronSourceInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/9.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATIronSourceInterstitialAdapter.h"
#import "ATIronSourceInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"

NSString *const kATIronSourceInterstitialNotificationLoaded = @"com.anythink.kATIronSourceInterstitialNotificationLoaded";
NSString *const kATIronSourceInterstitialNotificationLoadFailed = @"com.anythink.kATIronSourceInterstitialNotificationLoadFailed";
NSString *const kATIronSourceInterstitialNotificationShow = @"com.anythink.kATIronSourceInterstitialNotificationShow";
NSString *const kATIronSourceInterstitialNotificationClick = @"com.anythink.kATIronSourceInterstitialNotificationClick";
NSString *const kATIronSourceInterstitialNotificationClose = @"com.anythink.kATIronSourceInterstitialNotificationClose";

NSString *const kATIronSourceInterstitialNotificationUserInfoInstanceID = @"instance_id";
NSString *const kATIronSourceInterstitialNotificationUserInfoError = @"error";

@interface ATIronSourceInterstitialDelegate:NSObject<ISDemandOnlyInterstitialDelegate>
@end

static NSString *const kIronSourceClassName = @"IronSource";
@implementation ATIronSourceInterstitialDelegate
+(instancetype) sharedDelegateWithAppKey:(NSString*)appKey {
    static ATIronSourceInterstitialDelegate *sharedDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[ATIronSourceInterstitialDelegate alloc] init];
        [NSClassFromString(kIronSourceClassName) initISDemandOnly:appKey adUnits:@[@"interstitial"]];
    });
    return sharedDelegate;
}
#pragma mark - demand only
- (void)interstitialDidLoad:(NSString *)instanceId {
    [ATLogger logMessage:[NSString stringWithFormat:@"IronSourceInterstitial::interstitialDidLoad:%@", instanceId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATIronSourceInterstitialNotificationLoaded object:nil userInfo:@{kATIronSourceInterstitialNotificationUserInfoInstanceID:instanceId != nil ? instanceId : @""}];
}

- (void)interstitialDidFailToLoadWithError:(NSError *)error instanceId:(NSString *)instanceId {
    [ATLogger logMessage:[NSString stringWithFormat:@"IronSourceInterstitial::interstitialDidFailToLoadWithError:%@", error] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATIronSourceInterstitialNotificationLoadFailed object:nil userInfo:@{kATIronSourceInterstitialNotificationUserInfoInstanceID:instanceId != nil ? instanceId : @"", kATIronSourceInterstitialNotificationUserInfoError:error != nil ? error : [NSError errorWithDomain:@"com.anythink.IronSrouceInterstitialLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load interstitial ad", NSLocalizedFailureReasonErrorKey:@"IronSource has failed to load interstitial ad."}]}];
}

- (void)interstitialDidOpen:(NSString *)instanceId {
    [ATLogger logMessage:[NSString stringWithFormat:@"IronSourceInterstitial::interstitialDidOpen:%@", instanceId] type:ATLogTypeExternal];
    [ATLogger logMessage:[NSString stringWithFormat:@"IronSourceInterstitial::interstitialDidShow:%@", instanceId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATIronSourceInterstitialNotificationShow object:nil userInfo:@{kATIronSourceInterstitialNotificationUserInfoInstanceID:instanceId != nil ? instanceId : @""}];
}

- (void)interstitialDidClose:(NSString *)instanceId {
    [ATLogger logMessage:[NSString stringWithFormat:@"IronSourceInterstitial::interstitialDidClose:%@", instanceId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATIronSourceInterstitialNotificationClose object:nil userInfo:@{kATIronSourceInterstitialNotificationUserInfoInstanceID:instanceId != nil ? instanceId : @""}];
}

- (void)interstitialDidFailToShowWithError:(NSError *)error instanceId:(NSString *)instanceId {
    [ATLogger logMessage:[NSString stringWithFormat:@"IronSourceInterstitial::interstitialDidFailToShowWithError:%@ instanceId:%@", error, instanceId] type:ATLogTypeExternal];
}

- (void)didClickInterstitial:(NSString *)instanceId {
    [ATLogger logMessage:[NSString stringWithFormat:@"IronSourceInterstitial::didClickInterstitial:%@", instanceId] type:ATLogTypeExternal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATIronSourceInterstitialNotificationClick object:nil userInfo:@{kATIronSourceInterstitialNotificationUserInfoInstanceID:instanceId != nil ? instanceId : @""}];
}
@end

@interface ATIronSourceInterstitialAdapter()
@property(nonatomic, readonly) ATIronSourceInterstitialCustomEvent *customEvent;
@end

static NSString *const kPlacementNameKey = @"placement_name";
@implementation ATIronSourceInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(NSString*)customObject info:(NSDictionary*)info {
    return [NSClassFromString(kIronSourceClassName) hasISDemandOnlyInterstitial:customObject];;
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    [NSClassFromString(kIronSourceClassName) showISDemandOnlyInterstitial:viewController instanceId:interstitial.customObject];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameIronSource]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameIronSource];
                [[ATAPI sharedInstance] setVersion:[NSClassFromString(kIronSourceClassName) sdkVersion] forNetwork:kNetworkNameIronSource];
                if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameIronSource]) {
                    [NSClassFromString(kIronSourceClassName) setConsent:[[ATAPI sharedInstance].networkConsentInfo[kNetworkNameIronSource] boolValue]];
                } else {
                    BOOL set = NO;
                    BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                    if (set) {
                        /*
                         consent: 1 Personalized, 0 Nonpersonalized
                         */
                        [NSClassFromString(kIronSourceClassName) setConsent:!limit];
                    }
                }
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kIronSourceClassName) != nil) {
        _customEvent = [[ATIronSourceInterstitialCustomEvent alloc] initWithUnitID:info[@"instance_id"] customInfo:info];
        _customEvent.requestNumber = [info[@"request_num"] integerValue];
        _customEvent.requestCompletionBlock = completion;
        [NSClassFromString(kIronSourceClassName) setISDemandOnlyInterstitialDelegate:[ATIronSourceInterstitialDelegate sharedDelegateWithAppKey:info[@"app_key"]]];
        [NSClassFromString(kIronSourceClassName) loadISDemandOnlyInterstitial:info[@"instance_id"]];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, kIronSourceClassName]}]);
    }
    
}
@end
