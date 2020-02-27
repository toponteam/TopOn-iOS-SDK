//
//  ATMobPowerNativeAdapter.m
//  AnyThinkMobPowerNativeAdapter
//
//  Created by Martin Lau on 2018/12/24.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMobPowerNativeAdapter.h"
#import "ATMobPowerNativeCustomEvent.h"
#import "ATMobPowerNativeRenderer.h"
#import "ATAPI+Internal.h"
#import "ATAdCustomEvent.h"
#import "NSObject+ExtraInfo.h"
#import "Utilities.h"
#import "ATAdAdapter.h"

@interface ATMobPowerNativeAdapter()
@property(nonatomic, readonly) ATMobPowerNativeCustomEvent *customEvent;
@end
@implementation ATMobPowerNativeAdapter
+(Class) rendererClass {
    return [ATMobPowerNativeRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameMobPower]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameMobPower];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"MPSDK") sdkVersion] forNetwork:kNetworkNameMobPower];
            [[NSClassFromString(@"MPSDK") sharedSDK] startWithAppID:info[@"app_id"] appKey:info[@"api_key"] error:nil];
        }
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"MPNativeManager") != nil && NSClassFromString(@"MPNative") != nil) {
        _customEvent = [[ATMobPowerNativeCustomEvent alloc] init];
        _customEvent.unitID = info[@"placement_id"];
        _customEvent.requestCompletionBlock = completion;
        NSDictionary *extraInfo = info[kAdapterCustomInfoExtraKey];
        _customEvent.requestExtra = extraInfo;
        [[NSClassFromString(@"MPNativeManager") sharedManager] loadNativeAdsWithPlacementID:info[@"placement_id"] count:[info[@"request_num"] integerValue] category:0 delegate:_customEvent];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load native ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"MobPower"]}]);
    }
}
@end
