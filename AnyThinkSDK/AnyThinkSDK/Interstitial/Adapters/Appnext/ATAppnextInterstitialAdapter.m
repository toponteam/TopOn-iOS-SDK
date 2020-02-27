//
//  ATAppnextInterstitialAdapter.m
//  AnyThinkAppnextInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/16.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAppnextInterstitialAdapter.h"
#import "ATAppnextInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
@interface ATAppnextInterstitialAdapter()
@property(nonatomic, readonly) ATAppnextInterstitialCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATAppnextAd> interstitial;
@end
@implementation ATAppnextInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id<ATAppnextAd>)customObject info:(NSDictionary*)info {
    return customObject.adIsLoaded;
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    [interstitial.customObject showAd];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"AppnextSDKApi") getSDKVersion] forNetwork:kNetworkNameAppnext];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameAppnext]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameAppnext];
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"AppnextInterstitialAd") != nil) {
        _customEvent = [[ATAppnextInterstitialCustomEvent alloc] initWithUnitID:info[@"placement_id"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        
        _interstitial = [[NSClassFromString(@"AppnextInterstitialAd") alloc] initWithPlacementID:info[@"placement_id"]];
        _interstitial.delegate = _customEvent;
        [_interstitial loadAd];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Appnext"]}]);
    }
}
@end
