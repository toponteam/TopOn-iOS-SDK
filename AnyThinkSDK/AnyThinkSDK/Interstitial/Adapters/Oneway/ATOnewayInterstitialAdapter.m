//
//  ATOnewayInterstitialAdapter.m
//  AnyThinkOnewayInterstitialAdapter
//
//  Created by Martin Lau on 30/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATOnewayInterstitialAdapter.h"
#import "ATOnewayInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
#import "ATAdAdapter.h"
@interface ATOnewayInterstitialAdapter()
@property(nonatomic, readonly) ATOnewayInterstitialCustomEvent *customEvent;
@end
@implementation ATOnewayInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return [NSClassFromString(@"OWInterstitialAd") isReady];
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    [NSClassFromString(@"OWInterstitialAd") show:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameOneway]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameOneway];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"OneWaySDK") getVersion] forNetwork:kNetworkNameOneway];
            [NSClassFromString(@"OneWaySDK") configure:info[@"publisher_id"]];
        }
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"OWInterstitialAd") != nil) {
        _customEvent = [[ATOnewayInterstitialCustomEvent alloc] initWithUnitID:info[@"publisher_id"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        if ([NSClassFromString(@"OWInterstitialAd") isReady]) {
            NSArray<id<ATAd>>* ads = [[ATInterstitialManager sharedManager] adsWithPlacementID:((ATPlacementModel*)info[kAdapterCustomInfoPlacementModelKey]).placementID];
            __block id<ATAd> ad = nil;
            [ads enumerateObjectsUsingBlock:^(id<ATAd>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.unitID isEqualToString:info[@"publisher_id"]]) {
                    ad = obj;
                    *stop = YES;
                }
            }];
            if (ad == nil) {
                completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewarded video.", NSLocalizedFailureReasonErrorKey:@"OWRewardedAd can't load interstitial ad this time, please relaunch the app."}]);
            } else {
                [_customEvent oneWaySDKInterstitialAdReady];
            }
            
        } else {
            if ([[ATInterstitialManager sharedManager] firstLoadFlagForNetwork:kNetworkNameOneway]) {
                completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial ad.", NSLocalizedFailureReasonErrorKey:@"OWInterstitialAd class' initWithDelegate: method has been invoked before and its isReady method returns NO at the moment; please try again later to check it."}]);
            } else {
                [[ATInterstitialManager sharedManager] setFirstLoadFlagForNetwork:kNetworkNameOneway];
                [NSClassFromString(@"OWInterstitialAd") initWithDelegate:_customEvent];
            }
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Oneway"]}]);
    }
}
@end
