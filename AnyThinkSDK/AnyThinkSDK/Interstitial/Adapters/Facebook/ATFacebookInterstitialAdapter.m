//
//  ATFacebookInterstitialAdapter.m
//  AnyThinkFacebookInterstitialAdapter
//
//  Created by Martin Lau on 29/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATFacebookInterstitialAdapter.h"
#import "ATFacebookInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "ATAdAdapter.h"
@interface ATFacebookInterstitialAdapter()
@property(nonatomic, readonly) id<ATFBInterstitialAd> interstitialAd;
@property(nonatomic, readonly) ATFacebookInterstitialCustomEvent *customEvent;
@end
@implementation ATFacebookInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return ((id<ATFBInterstitialAd>)customObject).adValid;
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    [((id<ATFBInterstitialAd>)interstitial.customObject) showAdFromRootViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameFacebook]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameFacebook];
            [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameFacebook];
            [NSClassFromString(@"FBAdSettings") setAdvertiserTrackingEnabled:YES];
        }
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"FBInterstitialAd") != nil) {
        _customEvent = [[ATFacebookInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        _interstitialAd = [[NSClassFromString(@"FBInterstitialAd") alloc] initWithPlacementID:serverInfo[@"unit_id"]];
        _interstitialAd.delegate = _customEvent;
        [_interstitialAd loadAd];
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Facebook"]}]);
    }
}
@end
