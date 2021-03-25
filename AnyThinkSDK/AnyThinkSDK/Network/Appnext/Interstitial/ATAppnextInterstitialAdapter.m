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
#import "ATAppnextBaseManager.h"

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

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATAppnextBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"AppnextInterstitialAd") != nil) {
        _customEvent = [[ATAppnextInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        
        _interstitial = [[NSClassFromString(@"AppnextInterstitialAd") alloc] initWithPlacementID:serverInfo[@"placement_id"]];
        _interstitial.delegate = _customEvent;
        [_interstitial loadAd];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Appnext"]}]);
    }
}
@end
