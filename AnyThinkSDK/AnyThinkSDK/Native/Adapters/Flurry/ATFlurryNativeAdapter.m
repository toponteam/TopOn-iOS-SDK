//
//  ATFlurryNativeAdapter.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 27/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATFlurryNativeAdapter.h"
#import "ATFlurryRenderer.h"
#import "ATFlurryCustomEvent.h"
#import "NSObject+ATCustomEvent.h"
#import "NSObject+ExtraInfo.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
@interface ATFlurryNativeAdapter()
@property(nonatomic, readonly) NSMutableArray<id<ATFlurryAdNative>>* nativeAds;
@property(nonatomic, readonly) ATFlurryCustomEvent *customEvent;
@end

@implementation ATFlurryNativeAdapter
+(Class) rendererClass {
    return [ATFlurryRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        _nativeAds = [NSMutableArray<id<ATFlurryAdNative>> array];
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"Flurry") getFlurryAgentVersion] forNetwork:kNetworkNameFlurry];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameFlurry]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameFlurry];
                if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameFlurry]) {
                    id<ATFlurryConsent> consent = [[NSClassFromString(@"FlurryConsent") alloc] initWithGDPRScope:[[ATAPI sharedInstance].networkConsentInfo[kNetworkNameFlurry][kFlurryConsentGDPRScopeFlagKey] boolValue] andConsentStrings:[ATAPI sharedInstance].networkConsentInfo[kNetworkNameFlurry][kFlurryConsentConsentStringKey]];
                    [NSClassFromString(@"FlurryConsent") updateConsentInformation:consent];
                } else {
                    BOOL set = NO;
                    [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                    if (set && [[ATAPI sharedInstance].consentStrings count] > 0) {
                        id<ATFlurryConsent> consent = [[NSClassFromString(@"FlurryConsent") alloc] initWithGDPRScope:[[ATAPI sharedInstance] inDataProtectionArea] andConsentStrings:[ATAPI sharedInstance].consentStrings];
                        [NSClassFromString(@"FlurryConsent") updateConsentInformation:consent];
                    }
                }
                [NSClassFromString(@"Flurry") startSession:info[@"sdk_key"] withSessionBuilder:[[[NSClassFromString(@"FlurrySessionBuilder") new] withCrashReporting:YES] withLogLevel:ATFlurryLogLevelDebug]];
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary*> *assets, NSError *error))completion {
    _customEvent = [ATFlurryCustomEvent new];
    _customEvent.unitID = info[@"ad_space"];
    _customEvent.requestCompletionBlock = completion;
    _customEvent.requestNumber = [info[@"request_num"] longValue];
    NSDictionary *extraInfo = info[kAdapterCustomInfoExtraKey];
    _customEvent.requestExtra = extraInfo;
    for (NSInteger i = 0; i < [info[@"request_num"] integerValue]; i++) {
        id<ATFlurryAdNative> nativeAd = [[NSClassFromString(@"FlurryAdNative") alloc] initWithSpace:info[@"ad_space"]];
        nativeAd.adDelegate = _customEvent;
        [nativeAd fetchAd];
        [_nativeAds addObject:nativeAd];
    }
}
@end
