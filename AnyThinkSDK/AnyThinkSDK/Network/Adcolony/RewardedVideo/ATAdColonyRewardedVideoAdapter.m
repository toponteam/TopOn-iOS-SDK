//
//  ATAdColonyRewardedVideoAdapter.m
//  AnyThinkAdColonyRewardedVideoAdapter
//
//  Created by Martin Lau on 11/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdColonyRewardedVideoAdapter.h"
#import "ATAdManager+RewardedVideo.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import "AnyThinkRewardedVideo.h"
#import "ATAdColonyRewardedVideoCustomEvent.h"
#import "Utilities.h"
#import <objc/runtime.h>
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
#import "ATAdcolonyBaseManager.h"

typedef NS_ENUM(NSInteger, ATRVAdColonyInitState) {
    ATRVAdColonyInitStateNotInit = 0,
    ATRVAdColonyInitStateIniting = 1,
    ATRVAdColonyInitStateInited = 2
};
NSString *const kAdColonyRVCustomEventKey = @"custom_event";
static NSString *const kAdColonyRVConfig = @"com.topon.adColony_Config_finish";
static NSString *const kAdColonyRewardedSuccess = @"com.topon.adColony_rewarded_success";
@interface ATAdColonyRewardedVideoAdapter()
@property ATAdColonyRewardedVideoCustomEvent *customEvent;
@property(nonatomic, readonly) NSDictionary *info;
@end

static NSString *const kAdColonyClassName = @"AdColony";
static NSString *const kZoneIDKey = @"zone_id";
@implementation ATAdColonyRewardedVideoAdapter

+(BOOL) adReadyWithCustomObject:(id<ATAdColonyInterstitial>)customObject info:(NSDictionary*)info {
    return !customObject.expired;
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    __weak ATAdColonyRewardedVideoCustomEvent *customEvent = objc_getAssociatedObject(rewardedVideo.customObject, (__bridge_retained void*)kAdColonyRVCustomEventKey);
    customEvent.rewardedVideo = rewardedVideo;
    customEvent.delegate = delegate;
    id<ATAdColonyInterstitial> interstitial = (id<ATAdColonyInterstitial>)rewardedVideo.customObject;
    [interstitial showWithPresentingViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATAdcolonyBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
        _info = serverInfo;
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kAdColonyClassName) != nil) {
        _customEvent = [[ATAdColonyRewardedVideoCustomEvent alloc] initWithUnitID:serverInfo[kZoneIDKey] serverInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        __weak typeof(self) weakSelf = self;
        [[ATAPI sharedInstance] inspectInitFlagForNetwork:kNetworkNameAdColony usingBlock:^NSInteger(NSInteger currentValue) {
            if (currentValue == ATRVAdColonyInitStateNotInit) {
                id<ATAdColonyAppOptions> options = [[NSClassFromString(@"AdColonyAppOptions") alloc] init];
                if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameAdColony]) {
                    options.gdprRequired = [[ATAPI sharedInstance].networkConsentInfo[kNetworkNameAdColony][kAdColonyGDPRConsiderationFlagKey] boolValue];
                    options.gdprConsentString = [ATAPI sharedInstance].networkConsentInfo[kNetworkNameAdColony][kAdColonyGDPRConsentStringKey];
                } else {
                    BOOL set = NO;
                    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                    BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                    if (set) {
                        options.gdprConsentString = limit ? @"0" : @"1";
                        options.gdprRequired = [[ATAPI sharedInstance] inDataProtectionArea];
                    }
                }
                if ([ATAppSettingManager sharedManager].complyWithCOPPA) {
                    [options setPrivacyConsentString:@"0" forType:@"COPPA"];
                }
                if ([ATAppSettingManager sharedManager].complyWithCCPA) {
                    [options setPrivacyConsentString:@"0" forType:@"CCPA"];
                }
                if (localInfo[kATAdLoadingExtraUserIDKey] != nil) {
                    options.userID = localInfo[kATAdLoadingExtraUserIDKey];
                }
                [NSClassFromString(kAdColonyClassName) configureWithAppID:serverInfo[@"app_id"] zoneIDs:serverInfo[@"zone_ids"] options:options completion:^(NSArray<id<ATAdColonyZone>> *zones) {
                    [zones enumerateObjectsUsingBlock:^(id<ATAdColonyZone>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (obj.rewarded) {
                            [obj setReward:^(BOOL success, NSString *name, int amount) {
                                if (success) {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:kAdColonyRewardedSuccess object:nil userInfo:nil];
                                }
                            }];
                        }
                    }];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAdColonyRVConfig object:nil userInfo:nil];
                    [NSClassFromString(kAdColonyClassName) requestInterstitialInZone:serverInfo[kZoneIDKey] options:options andDelegate:weakSelf.customEvent];
                    [[ATAPI sharedInstance]setInitFlag:ATRVAdColonyInitStateInited forNetwork:kNetworkNameAdColony];
                }];
                return ATRVAdColonyInitStateIniting;
            } else if (currentValue == ATRVAdColonyInitStateIniting) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleConfigurationFinishedNotification:) name:kAdColonyRVConfig object:nil];
                return currentValue;
            } else if (currentValue == ATRVAdColonyInitStateInited) {
                [NSClassFromString(kAdColonyClassName) requestInterstitialInZone:serverInfo[kZoneIDKey] options:nil andDelegate:weakSelf.customEvent];
                return currentValue;
            }
            return currentValue;
        }];
        
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, kAdColonyClassName]}]);
    }
    
}

-(void) handleConfigurationFinishedNotification:(NSNotification*)notify {
    [NSClassFromString(kAdColonyClassName) requestInterstitialInZone:_info[kZoneIDKey] options:nil andDelegate:_customEvent];
}




@end
