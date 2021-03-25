//
//  ATGoogleAdManagerInterstitialAdapter.m
//  AnyThinkAdmobInterstitialAdapter
//
//  Created by stephen on 7/27/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATGoogleAdManagerInterstitialAdapter.h"
#import "ATGoogleAdManagerInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAppSettingManager.h"
#import "ATAdmobBaseManager.h"

@interface ATGoogleAdManagerInterstitialAdapter()
@property(nonatomic, readonly) ATGoogleAdManagerInterstitialCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATDFPInterstitial> interstitial;
@end
@implementation ATGoogleAdManagerInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return ((id<ATDFPInterstitial>)customObject).isReady;
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    id<ATDFPInterstitial> admobInterstitial = interstitial.customObject;
    interstitial.customEvent.delegate = delegate;
    [admobInterstitial presentFromRootViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATAdmobBaseManager initGoogleAdManagerWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"DFPInterstitial") != nil && NSClassFromString(@"DFPRequest") != nil) {
        _customEvent = [[ATGoogleAdManagerInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        _interstitial = [[NSClassFromString(@"DFPInterstitial") alloc] initWithAdUnitID:serverInfo[@"unit_id"]];
        _interstitial.delegate = _customEvent;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_interstitial loadRequest:[NSClassFromString(@"DFPRequest") request]];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"GoogleAdManager"]}]);
    }
}
@end
