//
//  ATAdmobInterstitialAdapter.m
//  AnyThinkAdmobInterstitialAdapter
//
//  Created by Martin Lau on 25/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdmobInterstitialAdapter.h"
#import "ATAdmobInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAppSettingManager.h"
#import "ATAdmobBaseManager.h"

@interface ATAdmobInterstitialAdapter()
@property(nonatomic, readonly) ATAdmobInterstitialCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATGADInterstitial> interstitial;
@end
@implementation ATAdmobInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return ((id<ATGADInterstitial>)customObject).isReady;
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    id<ATGADInterstitial> admobInterstitial = interstitial.customObject;
    interstitial.customEvent.delegate = delegate;
    [admobInterstitial presentFromRootViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATAdmobBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"GADInterstitial") != nil && NSClassFromString(@"GADRequest") != nil) {
        _customEvent = [[ATAdmobInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        _interstitial = [[NSClassFromString(@"GADInterstitial") alloc] initWithAdUnitID:serverInfo[@"unit_id"]];
        _interstitial.delegate = _customEvent;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_interstitial loadRequest:[NSClassFromString(@"GADRequest") request]];
        });
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Admob"]}]);
    }
}
@end
