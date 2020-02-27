//
//  ATApplovinNativeAdapter.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 27/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATApplovinNativeAdapter.h"
#import "ATApplovinRenderer.h"
#import "ATApplovinCustomEvent.h"
#import "NSObject+ExtraInfo.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
@interface ATApplovinNativeAdapter()
@property(nonatomic, readonly) ATApplovinCustomEvent *customEvent;
@end
@implementation ATApplovinNativeAdapter
+(Class) rendererClass {
    return [ATApplovinRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameApplovin]) {
            [[ATAPI sharedInstance] setVersion:@([NSClassFromString(@"ALSdk") versionCode]).stringValue forNetwork:kNetworkNameApplovin];
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameApplovin];
            if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameApplovin]) {
                [NSClassFromString(@"ALPrivacySettings") setHasUserConsent:[[ATAPI sharedInstance].networkConsentInfo[kNetworkNameApplovin][kApplovinConscentStatusKey] boolValue]];
                [NSClassFromString(@"ALPrivacySettings") setIsAgeRestrictedUser:[[ATAPI sharedInstance].networkConsentInfo[kNetworkNameApplovin][kApplovinUnderAgeKey] boolValue]];
            } else {
                BOOL set = NO;
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                if (set) { [NSClassFromString(@"ALPrivacySettings") setHasUserConsent:!limit]; }
            }
        }
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary*> *assets, NSError *error))completion {
    _customEvent = [[ATApplovinCustomEvent alloc] init];
    _customEvent.unitID = info[@"sdkkey"];
    _customEvent.requestCompletionBlock = completion;
    NSDictionary *extraInfo = info[kAdapterCustomInfoExtraKey];
    _customEvent.requestExtra = extraInfo;
    _customEvent.requestNumber = [info[@"request_num"] integerValue];
    id<ATALSdk> sdk = [NSClassFromString(@"ALSdk") sharedWithKey:info[@"sdkkey"]];
    for (NSInteger i = 0; i < _customEvent.requestNumber; i++) { [sdk.nativeAdService loadNextAdAndNotify:_customEvent]; }
}
@end
