//
//  ATApplovinRewardedVideoAdapter.m
//  AnyThinkApplovinRewardedVideoAdapter
//
//  Created by Martin Lau on 09/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATApplovinRewardedVideoAdapter.h"
#import "ATApplovinRewardedVideoCustomEvent.h"
#import "AnyThinkRewardedVideo.h"
#import "ATRewardedVideoManager.h"
#import "ATAPI+Internal.h"
#import <objc/runtime.h>
#import "Utilities.h"
#import "ATAdManager+RewardedVideo.h"
#import "ATAdManager+Internal.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
#import "ATApplovinBaseManager.h"

@interface ATApplovinRewardedVideoAdapter()
@property(nonatomic, readonly) id<ATALIncentivizedInterstitialAd> incentivizedInterstitialAd;
@property(nonatomic, readonly) ATApplovinRewardedVideoCustomEvent *customEvent;
@end

static NSString *const kZoneIDKey = @"zone_id";
@implementation ATApplovinRewardedVideoAdapter

+(BOOL) adReadyWithCustomObject:(ATApplovinRewardedVideoCustomEvent*)customObject info:(NSDictionary*)info {
    return [customObject.incentivizedInterstitialAd isReadyForDisplay];
}

+(void) showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    ATApplovinRewardedVideoCustomEvent *customEvent = (ATApplovinRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.delegate = delegate;
    id<ATALIncentivizedInterstitialAd> incentivizedInterstitialAd = customEvent.incentivizedInterstitialAd;
    incentivizedInterstitialAd.adDisplayDelegate = customEvent;
    incentivizedInterstitialAd.adVideoPlaybackDelegate = customEvent;
    [incentivizedInterstitialAd showAndNotify:customEvent];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATApplovinBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"ALIncentivizedInterstitialAd") != nil) {
        _customEvent = [[ATApplovinRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestNumber = [serverInfo[@"request_num"] longValue];
        _customEvent.requestCompletionBlock = completion;
        _incentivizedInterstitialAd = [[NSClassFromString(@"ALIncentivizedInterstitialAd") alloc] initWithZoneIdentifier:serverInfo[kZoneIDKey] sdk:[NSClassFromString(@"ALSdk") sharedWithKey:serverInfo[@"sdkkey"]]];
        if (localInfo[kATAdLoadingExtraUserIDKey] != nil) {
            ((id<ATALSdk>)[NSClassFromString(@"ALSdk") sharedWithKey:serverInfo[@"sdkkey"]]).userIdentifier = localInfo[kATAdLoadingExtraUserIDKey];
        }
        _customEvent.incentivizedInterstitialAd = _incentivizedInterstitialAd;
        for (NSInteger i = 0; i < [serverInfo[@"request_num"] integerValue]; i++) {
            [_incentivizedInterstitialAd preloadAndNotify:_customEvent];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadRewardedVideoADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Applovin"]}]);
    }
}
@end
