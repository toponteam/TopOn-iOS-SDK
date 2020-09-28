//
//  ATYeahmobiNativeAdapter.m
//  AnyThinkYeahmobiNativeAdapter
//
//  Created by Martin Lau on 2018/10/15.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATYeahmobiNativeAdapter.h"
#import "ATYeahmobiNativeCustomEvent.h"
#import "ATYeahmobiNativeRenderer.h"
#import "ATAPI+Internal.h"
#import "ATAdCustomEvent.h"
#import "NSObject+ExtraInfo.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"

NSString *const kYearmobiNativeAssetsCustomEventKey = @"custom_event";
@interface ATYeahmobiNativeAdapter()
@property(nonatomic, readonly) ATYeahmobiNativeCustomEvent *customEvent;
@end
@implementation ATYeahmobiNativeAdapter
+(Class) rendererClass {
    return [ATYeahmobiNativeRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameYeahmobi]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameYeahmobi];
            [[ATAPI sharedInstance] setVersion:[[NSClassFromString(@"CTService") shareManager] getSDKVersion] forNetwork:kNetworkNameYeahmobi];
            [[NSClassFromString(@"CTService") shareManager] loadRequestGetCTSDKConfigBySlot_id:serverInfo[@"slot_id"]];
            
            if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameYeahmobi]) {
                if ([[ATAPI sharedInstance].networkConsentInfo isKindOfClass:[NSDictionary class]] && [[ATAPI sharedInstance].networkConsentInfo[kYeahmobiGDPRConsentTypeKey] isKindOfClass:[NSString class]] && [[ATAPI sharedInstance].networkConsentInfo[kYeahmobiGDPRConsentValueKey] isKindOfClass:[NSString class]]) {
                    [[NSClassFromString(@"CTService") shareManager] uploadConsentValue:[ATAPI sharedInstance].networkConsentInfo[kYeahmobiGDPRConsentValueKey] consentType:[ATAPI sharedInstance].networkConsentInfo[kYeahmobiGDPRConsentTypeKey] complete:^(BOOL status){}];
                }
            } else {
                BOOL set = NO;
                ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                if (set) { [[NSClassFromString(@"CTService") shareManager] uploadConsentValue:limit ? @"no" : @"yes" consentType:@"GDPR" complete:^(BOOL status){}]; }
                
            }
        }
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"CTService") != nil) {
        _customEvent = [[ATYeahmobiNativeCustomEvent alloc] init];
        _customEvent.unitID = serverInfo[@"slot_id"];
        _customEvent.requestCompletionBlock = completion;
        NSDictionary *extraInfo = localInfo;
        _customEvent.requestExtra = extraInfo;
        __weak typeof(self) weakSelf = self;
        [[NSClassFromString(@"CTService") shareManager] getMultitermNativeADswithSlotId:serverInfo[@"slot_id"] adNumbers:[serverInfo[@"request_num"] integerValue] delegate:_customEvent imageWidthHightRate:1 isTest:NO success:^(NSArray * _Nonnull nativeArr) {
            [weakSelf.customEvent loadSuccessed:nativeArr];
        } failure:^(NSError * _Nonnull error) {
            [weakSelf.customEvent loadFailed:error];
        }];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadNativeADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Yeahmobi"]}]);
    }
}
@end
