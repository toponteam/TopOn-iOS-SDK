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
static NSString *const kATInmobiSDKInitedNotification = @"com.anythink.InMobiInitNotification";

@interface ATInmobiNativeAdapter()
@property(nonatomic, readonly) id<ATIMNative> nativeAd;
@property(nonatomic, readonly) ATInmobiCustomEvent *customEvent;
@property(nonatomic, readonly) NSDictionary *info;
@property(nonatomic, readonly) void (^LoadCompletionBlock)(NSArray<NSDictionary*> *assets, NSError *error);
@end

@implementation ATInmobiNativeAdapter
+(Class) rendererClass {
    return [ATInmobiNativeADRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"IMSdk") getVersion] forNetwork:kNetworkNameInmobi];
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary*> *assets, NSError *error))completion {
    if (NSClassFromString(@"IMSdk") != nil && NSClassFromString(@"IMNative") != nil) {
        [[ATAPI sharedInstance] inspectInitFlagForNetwork:kNetworkNameInmobi usingBlock:^NSInteger(NSInteger currentValue) {
            if (currentValue == 0) {//not inited
//                [[ATAPI sharedInstance] setInitFlag:1 forNetwork:kNetworkNameInmobi];
                BOOL set = NO;
                BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set];
                if (set) { [NSClassFromString(@"IMSdk") updateGDPRConsent:@{@"gdpr_consent_available":limit ? @"false" : @"true", @"gdpr":[[ATAPI sharedInstance] inDataProtectionArea] ? @"1" : @"0"}]; }
                [NSClassFromString(@"IMSdk") initWithAccountID:info[@"app_id"] andCompletionHandler:^(NSError *error) {
                    if (error == nil) {
                        [[ATAPI sharedInstance] setInitFlag:2 forNetwork:kNetworkNameInmobi];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kATInmobiSDKInitedNotification object:nil];
                        [self loadADUsingInfo:info completion:completion];
                    } else {
                        completion(nil, error != nil ? error : [NSError errorWithDomain:@"com.anythink.InmobiNativeLoading" code:0 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load ad", NSLocalizedFailureReasonErrorKey:@"IMSDK has failed to initialize"}]);
                    }
                }];
                return 1;
            } else if (currentValue == 1) {//initing
                self->_info = info;
                self->_LoadCompletionBlock = completion;
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInitNotification:) name:kATInmobiSDKInitedNotification object:nil];
                return currentValue;
            } else if (currentValue == 2) {//inited
                [self loadADUsingInfo:info completion:completion];
                return currentValue;
            }
            return currentValue;
        }];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load native ad.", NSLocalizedFailureReasonErrorKey:@"This might be due to Inmobi SDK not being imported or it's imported but a unsupported version is being used."}]);
    }
}

-(void) handleInitNotification:(NSNotification*)notification {
    [self loadADUsingInfo:self.info completion:self.LoadCompletionBlock];
}

-(void) loadADUsingInfo:(NSDictionary*)info completion:(void (^)(NSArray<NSDictionary*> *assets, NSError *error))completion {
    _customEvent = [ATInmobiCustomEvent new];
    _customEvent.unitID = info[@"unit_id"];
    _customEvent.requestCompletionBlock = completion;
    _customEvent.requestExtra = info[kAdapterCustomInfoExtraKey];
    _customEvent.requestNumber = 1;
    _nativeAd = [[NSClassFromString(@"IMNative") alloc] initWithPlacementId:[info[@"unit_id"] longLongValue] delegate:self->_customEvent];
    [_nativeAd load];
}
@end
