//
//  ATAdColonyInterstitialAdapter.m
//  AnyThinkAdColonyInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/9.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdColonyInterstitialAdapter.h"
#import "ATAdColonyInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAppSettingManager.h"

typedef NS_ENUM(NSInteger, ATInterstitialAdColonyInitState) {
    ATInterstitialAdColonyInitStateNotInit = 0,
    ATInterstitialAdColonyInitStateIniting = 1,
    ATInterstitialAdColonyInitStateInited = 2
};
@interface ATAdColonyInterstitialAdapter()
@property(nonatomic, readonly) ATAdColonyInterstitialCustomEvent *customEvent;
@property(nonatomic, readonly) NSDictionary *info;
@end
static NSString *const kAdColonyClassName = @"AdColony";
static NSString *const kZoneIDKey = @"zone_id";
static NSString *const kAdColonyIVConfig = @"com.topon.adColony_Config_finish";
static NSString *const kAdColonyRewardedSuccess = @"com.topon.adColony_rewarded_success";

@implementation ATAdColonyInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id<ATAdColonyInterstitial>)customObject info:(NSDictionary*)info {
    return !customObject.expired;
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    ATAdColonyInterstitialCustomEvent *customEvent = (ATAdColonyInterstitialCustomEvent*)interstitial.customEvent;
    customEvent.delegate = delegate;
    id<ATAdColonyInterstitial> acInterstitial = (id<ATAdColonyInterstitial>)interstitial.customObject;
    [acInterstitial showWithPresentingViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(kAdColonyClassName) getSDKVersion] forNetwork:kNetworkNameAdColony];
        });
        _info = info;
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kAdColonyClassName) != nil) {
        _customEvent = [[ATAdColonyInterstitialCustomEvent alloc] initWithUnitID:info[kZoneIDKey] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        __weak typeof(self) weakSelf = self;
        
        [[ATAPI sharedInstance] inspectInitFlagForNetwork:kNetworkNameAdColony usingBlock:^NSInteger(NSInteger currentValue) {
            if (currentValue == ATInterstitialAdColonyInitStateNotInit) {
                id<ATAdColonyAppOptions> options = [[NSClassFromString(@"AdColonyAppOptions") alloc] init];
                if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameAdColony]) {
                    options.gdprRequired = [[ATAPI sharedInstance].networkConsentInfo[kNetworkNameAdColony][kAdColonyGDPRConsiderationFlagKey] boolValue];
                    options.gdprConsentString = [ATAPI sharedInstance].networkConsentInfo[kNetworkNameAdColony][kAdColonyGDPRConsentStringKey];
                } else {
                    BOOL set = NO;
                    BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                    if (set) {
                        /**
                         gdprConsentString: @"0" Nonpersonalized, @"1" Personalized
                         */
                        options.gdprConsentString = limit ? @"0" : @"1";
                        options.gdprRequired = [[ATAPI sharedInstance] inDataProtectionArea];
                    }
                }
                [NSClassFromString(kAdColonyClassName) configureWithAppID:info[@"app_id"] zoneIDs:info[@"zone_ids"] options:options completion:^(NSArray<id<ATAdColonyZone>> *zones) {
                    [zones enumerateObjectsUsingBlock:^(id<ATAdColonyZone>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (obj.rewarded) {
                            [obj setReward:^(BOOL success, NSString *name, int amount) {
                                if (success) {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:kAdColonyRewardedSuccess object:nil userInfo:nil];
                                }
                            }];
                        }
                    }];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAdColonyIVConfig object:nil userInfo:nil];
                    [NSClassFromString(kAdColonyClassName) requestInterstitialInZone:info[kZoneIDKey] options:options andDelegate:weakSelf.customEvent];
                    [[ATAPI sharedInstance] setInitFlag:ATInterstitialAdColonyInitStateInited forNetwork:kNetworkNameAdColony];
                }];
                return ATInterstitialAdColonyInitStateIniting;
            } else if (currentValue == ATInterstitialAdColonyInitStateIniting) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleConfigurationFinishedNotification:) name:kAdColonyIVConfig object:nil];
                return currentValue;
            } else if (currentValue == ATInterstitialAdColonyInitStateInited) {
                [NSClassFromString(kAdColonyClassName) requestInterstitialInZone:info[kZoneIDKey] options:nil andDelegate:weakSelf.customEvent];
                return currentValue;
            }
            return currentValue;
        }];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, kAdColonyClassName]}]);
    }
}

-(void)handleConfigurationFinishedNotification:(NSNotification*)notify {
    [NSClassFromString(kAdColonyClassName) requestInterstitialInZone:_info[kZoneIDKey] options:nil andDelegate:_customEvent];

}
@end
