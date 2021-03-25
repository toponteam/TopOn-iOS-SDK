//
//  ATChartboostInterstitialAdapter.m
//  AnyThinkChartboostInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/9.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATChartboostInterstitialAdapter.h"
#import "ATChartboostInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
#import "ATChartboostBaseManager.h"

static NSString *const kChartboostClassName = @"Chartboost";
static NSString *const kLocationKey = @"location";
static NSString *const kATChartboostInitNotification = @"com.anythink.ChartboostInitNotification";
@interface ATChartboostInterstitialAdapter()
@property(nonatomic, readonly) ATChartboostInterstitialCustomEvent *customEvent;
@property(nonatomic, readonly) void (^LoadCompletionBlock)(NSArray<NSDictionary *> *, NSError *);
@property(nonatomic, readonly) NSDictionary *info;
@property(nonatomic, readonly) NSDictionary *localInfo;
@property(nonatomic, readonly) id<ATCHBInterstitial> interstitialAd;
@end
@implementation ATChartboostInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id<ATCHBInterstitial>)customObject info:(NSDictionary*)info {
    return [customObject isCached];
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    [(id<ATCHBInterstitial>)(interstitial.customObject) showFromViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATChartboostBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"CHBInterstitial") != nil && NSClassFromString(@"Chartboost") != nil) {
        [[ATAPI sharedInstance] inspectInitFlagForNetwork:kNetworkNameChartboost usingBlock:^NSInteger(NSInteger currentValue) {
            if (currentValue == 0) {
                __block BOOL isCompletionResult = NO;
                [NSClassFromString(@"Chartboost") startWithAppId:serverInfo[@"app_id"] appSignature:serverInfo[@"app_signature"] completion:^(BOOL success) {
                    if (success) {
                        isCompletionResult = YES;
                        [[ATAPI sharedInstance] setInitFlag:2 forNetwork:kNetworkNameChartboost];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kATChartboostInitNotification object:nil];
                        [self loadAdUsingInfo:serverInfo localInfo:localInfo completion:completion];
                    }
                }];
                if (isCompletionResult) {
                    return 2;
                }else {
                    return 1;
                }
            } else if (currentValue == 1) {
                self->_info = serverInfo;
                self->_localInfo = localInfo;
                self->_LoadCompletionBlock = completion;
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInitNotification:) name:kATChartboostInitNotification object:nil];
                return currentValue;
            } else if (currentValue == 2) {
                [self loadAdUsingInfo:serverInfo localInfo:localInfo completion:completion];
                return currentValue;
            }
            return currentValue;
        }];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Chartboost"]}]);
    }
}

-(void) loadAdUsingInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo  completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    
    _customEvent = [[ATChartboostInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    _interstitialAd = [[NSClassFromString(@"CHBInterstitial") alloc] initWithLocation:serverInfo[kLocationKey] delegate:_customEvent];
    _customEvent.interstitialAd = _interstitialAd;
    [_interstitialAd cache];
}

-(void) handleInitNotification:(NSNotification*)notification {
    [self loadAdUsingInfo:_info localInfo:_localInfo completion:_LoadCompletionBlock];
}
@end
