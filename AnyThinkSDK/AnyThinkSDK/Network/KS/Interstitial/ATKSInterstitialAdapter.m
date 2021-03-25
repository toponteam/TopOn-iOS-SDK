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
#import "ATKSBaseManager.h"

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
        [ATKSBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if(NSClassFromString(kKSInterstitialClassName) != nil){
        _customEvent = [[ATKSInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
        _interstitial = [[NSClassFromString(kKSInterstitialClassName) alloc]initWithPosId:serverInfo[@"position_id"]];
        _interstitial.shouldMuted = [serverInfo[@"video_muted"] boolValue];
        _interstitial.delegate = _customEvent;
        [_interstitial loadAdData];
    }else{
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"KS"]}]);
    }
}

@end
