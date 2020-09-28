//
//  ATAdColonyBannerAdapter.m
//  AnyThinkAdColonyBannerAdapter
//
//  Created by Martin Lau on 2020/6/10.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATAdColonyBannerAdapter.h"
#import "ATAdColonyBannerCustomEvent.h"
#import "ATAPI+Internal.h"
#import "ATAppSettingManager.h"
#import "ATAdAdapter.h"
typedef NS_ENUM(NSInteger, ATBannerAdColonyInitState) {
    ATBannerAdColonyInitStateNotInit = 0,
    ATBannerAdColonyInitStateIniting = 1,
    ATBannerAdColonyInitStateInited = 2
};

@interface ATAdColonyBannerAdapter()
@property(nonatomic, readonly) ATAdColonyBannerCustomEvent *customEvent;
@property(nonatomic, readonly) NSDictionary *info;
@end
static NSString *const kAdColonyClassName = @"AdColony";
static NSString *const kZoneIDKey = @"zone_id";
static NSString *const kAdColonyConfig = @"com.topon.adColony_Config_finish";
static NSString *const kAdColonyRewardedSuccess = @"com.topon.adColony_rewarded_success";
@implementation ATAdColonyBannerAdapter
-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(kAdColonyClassName) getSDKVersion] forNetwork:kNetworkNameAdColony];
        });
        _info = serverInfo;
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kAdColonyClassName) != nil) {
        _customEvent = [[ATAdColonyBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        ATUnitGroupModel *unitGroupModel = serverInfo[kAdapterCustomInfoUnitGroupModelKey];
        AdColonyAdSize bannerSize = {unitGroupModel.adSize.width, unitGroupModel.adSize.height};
        __weak typeof(self) weakSelf = self;
        [[ATAPI sharedInstance] inspectInitFlagForNetwork:kNetworkNameAdColony usingBlock:^NSInteger(NSInteger currentValue) {
            if (currentValue == ATBannerAdColonyInitStateNotInit) {
                id<ATAdColonyAppOptions> options = [[NSClassFromString(@"AdColonyAppOptions") alloc] init];
                BOOL set = NO;
                ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                if (set) {
                    /**
                     gdprConsentString: @"0" Nonpersonalized, @"1" Personalized
                     */
                    options.gdprConsentString = limit ? @"0" : @"1";
                    options.gdprRequired = [[ATAPI sharedInstance] inDataProtectionArea];
                }
                [NSClassFromString(kAdColonyClassName) configureWithAppID:serverInfo[@"app_id"] zoneIDs:serverInfo[@"zone_ids"] options:options completion:^(NSArray<id<ATAdColonyZone>> *zones) {
                    [zones enumerateObjectsUsingBlock:^(id<ATAdColonyZone>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { if (obj.rewarded) { [obj setReward:^(BOOL success, NSString *name, int amount) { if (success) { [[NSNotificationCenter defaultCenter] postNotificationName:kAdColonyRewardedSuccess object:nil userInfo:nil]; } }]; } }];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAdColonyConfig object:nil userInfo:nil];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [NSClassFromString(kAdColonyClassName) requestAdViewInZone:serverInfo[kZoneIDKey] withSize:bannerSize viewController:[ATBannerCustomEvent rootViewControllerWithPlacementID:((ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey]).placementID requestID:serverInfo[kAdapterCustomInfoRequestIDKey]] andDelegate:weakSelf.customEvent];
                    });
                    [[ATAPI sharedInstance] setInitFlag:ATBannerAdColonyInitStateInited forNetwork:kNetworkNameAdColony];
                }];
                return ATBannerAdColonyInitStateIniting;
            } else if (currentValue == ATBannerAdColonyInitStateIniting) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleConfigurationFinishedNotification:) name:kAdColonyConfig object:nil];
                return currentValue;
            } else if (currentValue == ATBannerAdColonyInitStateInited) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSClassFromString(kAdColonyClassName) requestAdViewInZone:serverInfo[kZoneIDKey] withSize:bannerSize viewController:[ATBannerCustomEvent rootViewControllerWithPlacementID:((ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey]).placementID requestID:serverInfo[kAdapterCustomInfoRequestIDKey]] andDelegate:weakSelf.customEvent];
                });
                return currentValue;
            }
            return currentValue;
        }];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, kAdColonyClassName]}]);
    }
}

-(void)handleConfigurationFinishedNotification:(NSNotification*)notify {
    ATUnitGroupModel *unitGroupModel = _info[kAdapterCustomInfoUnitGroupModelKey];
    AdColonyAdSize bannerSize = {unitGroupModel.adSize.width, unitGroupModel.adSize.height};
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSClassFromString(kAdColonyClassName) requestAdViewInZone:self->_info[kZoneIDKey] withSize:bannerSize viewController:[ATBannerCustomEvent rootViewControllerWithPlacementID:((ATPlacementModel*)self->_info[kAdapterCustomInfoPlacementModelKey]).placementID requestID:self->_info[kAdapterCustomInfoRequestIDKey]] andDelegate:self->_customEvent];
    });
}
@end
