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
#import "ATAdLoader+HeaderBidding.h"
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

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameFacebook]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameFacebook];
            [[ATAPI sharedInstance] setVersion:@"" forNetwork:kNetworkNameFacebook];
        }
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"FBInterstitialAd") != nil) {
        _customEvent = [[ATFacebookInterstitialCustomEvent alloc] initWithUnitID:info[@"unit_id"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        _interstitialAd = [[NSClassFromString(@"FBInterstitialAd") alloc] initWithPlacementID:info[@"unit_id"]];
        _interstitialAd.delegate = _customEvent;
        
        ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)info[kAdapterCustomInfoUnitGroupModelKey];
        NSString *requestID = info[kAdapterCustomInfoRequestIDKey];
        if ([unitGroupModel bidTokenWithRequestID:requestID] != nil) {
            [_interstitialAd loadAdWithBidPayload:[unitGroupModel bidTokenWithRequestID:requestID]];
            [unitGroupModel setBidTokenUsedFlagForRequestID:requestID];
        } else {
            [_interstitialAd loadAd];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Facebook"]}]);
    }
}
@end
