//
//  ATInmobiNativeAdapter.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 21/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATInmobiNativeAdapter.h"
#import "ATAPI+Internal.h"
#import "ATInmobiNativeADRenderer.h"
#import "ATInmobiCustomEvent.h"
#import "NSObject+ATCustomEvent.h"
#import "NSObject+ExtraInfo.h"
#import "Utilities.h"
#import "ATNativeADOfferManager.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
NSString *const kInmobiNativeADAdapterAssetKey = @"native_ad_model";
NSString *const kInmobiNativeADAdapterEventKey = @"event";
@interface ATInmobiNativeAdapter()
@property(nonatomic, readonly) ATInmobiCustomEvent *customEvent;
@property(nonatomic, readonly) NSMutableArray<id<ATIMNative>>* natives;
@end

@implementation ATInmobiNativeAdapter
+(Class) rendererClass {
    return [ATInmobiNativeADRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        _natives = [NSMutableArray<id<ATIMNative>> arrayWithCapacity:[info[@"request_num"] longLongValue]];
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"IMSdk") getVersion] forNetwork:kNetworkNameInmobi];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameInmobi]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameInmobi];
                [NSClassFromString(@"IMSdk") initWithAccountID:info[@"app_id"]];
                if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameInmobi]) {
                    [NSClassFromString(@"IMSdk") updateGDPRConsent:@{@"gdpr_consent_available":[ATAPI sharedInstance].networkConsentInfo[kNetworkNameInmobi][kInmobiConsentStringKey], @"gdpr":[ATAPI sharedInstance].networkConsentInfo[kNetworkNameInmobi][kInmobiGDPRStringKey]}];
                } else {
                    BOOL set = NO;
                    BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                    if (set) { [NSClassFromString(@"IMSdk") updateGDPRConsent:@{@"gdpr_consent_available":limit ? @"false" : @"true", @"gdpr":[[ATAPI sharedInstance] inDataProtectionArea] ? @"1" : @"0"}]; }
                }
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary*> *assets, NSError *error))completion {
    if (NSClassFromString(@"IMNative") != nil) {
        _customEvent = [ATInmobiCustomEvent new];
        _customEvent.unitID = info[@"unit_id"];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.requestNumber = [info[@"request_num"] longLongValue];
        NSDictionary *extraInfo = info[kAdapterCustomInfoExtraKey];
        _customEvent.requestExtra = extraInfo;
        for (NSInteger i = 0; i < [info[@"request_num"] integerValue]; i++) {
            id<ATIMNative> native = [[NSClassFromString(@"IMNative") alloc] initWithPlacementId:[info[@"unit_id"] longLongValue]];
            native.delegate = _customEvent;
            [native load];
            [_natives addObject:native];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load native ad.", NSLocalizedFailureReasonErrorKey:@"This might be due to Inmobi SDK not being imported or it's imported but a unsupported version is being used."}]);
    }
}
@end
