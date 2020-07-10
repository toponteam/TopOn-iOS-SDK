//
//  ATInmobiInterstitialAdapter.m
//  AnyThinkInmobiInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/8.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATInmobiInterstitialAdapter.h"
#import "ATInmobiInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATAPI+Internal.h"
#import "ATAppSettingManager.h"
@interface ATInmobiInterstitialAdapter()
@property(nonatomic, readonly) ATInmobiInterstitialCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATIMInterstitial> interstitial;
@property(nonatomic, readonly) NSDictionary *info;
@property(nonatomic, readonly) void (^LoadCompletionBlock)(NSArray<NSDictionary*> *assets, NSError *error);
@end

static NSString *const kUnitIDKey = @"unit_id";
static NSString *const kATInmobiSDKInitedNotification = @"com.anythink.InMobiInitNotification";
@implementation ATInmobiInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id<ATIMInterstitial>)customObject info:(NSDictionary*)info {
    return [customObject isReady];
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    [((id<ATIMInterstitial>)interstitial.customObject) showFromViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{ [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"IMSdk") getVersion] forNetwork:kNetworkNameInmobi]; });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    info = [NSMutableDictionary dictionaryWithDictionary:info];
    if (NSClassFromString(@"IMInterstitial") != nil && NSClassFromString(@"IMSdk") != nil) {
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
                        completion(nil, error != nil ? error : [NSError errorWithDomain:@"com.anythink.InmobiBannerLoading" code:0 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load ad", NSLocalizedFailureReasonErrorKey:@"IMSDK has failed to initialize"}]);
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
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Inmobi"]}]);
    }
}

-(void) handleInitNotification:(NSNotification*)notification {
    [self loadADUsingInfo:self.info completion:self.LoadCompletionBlock];
}

-(void) loadADUsingInfo:(NSDictionary*)info completion:(void (^)(NSArray<NSDictionary*> *assets, NSError *error))completion {
    _customEvent = [[ATInmobiInterstitialCustomEvent alloc] initWithUnitID:info[kUnitIDKey] customInfo:info];
    _customEvent.requestNumber = 1;
    _customEvent.requestCompletionBlock = completion;
    _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
    _interstitial = (id<ATIMInterstitial>)[[NSClassFromString(@"IMInterstitial") alloc] initWithPlacementId:[info[kUnitIDKey] integerValue]  delegate:_customEvent];
    [_interstitial load];
}
@end
