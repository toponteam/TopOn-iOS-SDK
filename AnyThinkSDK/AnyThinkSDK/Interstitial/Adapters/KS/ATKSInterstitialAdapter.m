//
//  ATKSInterstitialAdapter.m
//  AnyThinkSDK
//
//  Created by Topon on 2019/9/10.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATKSInterstitialAdapter.h"
#import "ATKSInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
#import <objc/runtime.h>
#import "ATAdManager+Interstitial.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Internal.h"

static NSString *const kKSInterstitialClassName = @"KSFullscreenVideoAd";

@interface ATKSInterstitialAdapter ()
@property(nonatomic, readonly) ATKSInterstitialCustomEvent *customEvent;
@property(nonatomic, readonly) id<ATKSFullscreenVideoAd> interstitial;
@end
@implementation ATKSInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id<ATKSFullscreenVideoAd>)customObject info:(NSDictionary*)info {
    return ((id<ATKSFullscreenVideoAd>)customObject).isValid;
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    [((id<ATKSFullscreenVideoAd>)interstitial.customObject) showAdFromRootViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if(self != nil){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameKS]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameKS];
                [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"KSAdSDKManager") SDKVersion] forNetwork:kNetworkNameKS];
                [NSClassFromString(@"KSAdSDKManager") setAppId:serverInfo[@"app_id"]];
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if(NSClassFromString(kKSInterstitialClassName) != nil){
        _customEvent = [[ATKSInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
        _interstitial = [[NSClassFromString(kKSInterstitialClassName) alloc]initWithPosId:serverInfo[@"position_id"]];
        _interstitial.delegate = _customEvent;
        [_interstitial loadAdData];
    }else{
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"KS"]}]);

    }
}

@end
