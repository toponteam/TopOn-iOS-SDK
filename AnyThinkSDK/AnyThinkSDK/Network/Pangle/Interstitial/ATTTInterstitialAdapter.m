//
//  ATTTInterstitialAdapter.m
//  AnyThinkTTInterstitialAdapter
//
//  Created by Martin Lau on 25/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATTTInterstitialAdapter.h"
#import "ATTTInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Interstitial.h"
#import "ATPangleBaseManager.h"

@interface ATTTInterstitialAdapter()
@property(nonatomic, readonly) id<ATBUFullscreenVideoAd> fullscreenVideo;
@property(nonatomic, readonly) id<ATBUNativeExpressInterstitialAd> expressInterstitial;
@property(nonatomic, readonly) id<ATBUNativeExpressFullscreenVideoAd> expressFullScreenVideo;
@property(nonatomic, readonly) ATTTInterstitialCustomEvent *customEvent;
@end

@implementation ATTTInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return ((id<ATBUNativeExpressFullscreenVideoAd>)customObject).adValid;
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    //Here for full screen video ad, we also use id<ATWMInterstitialAd>, for the presenting methods are the same.
    interstitial.customEvent.delegate = delegate;
    [interstitial.customObject showAdFromRootViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATPangleBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"BUFullscreenVideoAd") != nil && NSClassFromString(@"BUNativeExpressFullscreenVideoAd") != nil && NSClassFromString(@"BUNativeExpressInterstitialAd") != nil) {
        _customEvent = [[ATTTInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        NSDictionary *extraInfo = localInfo;
        CGSize adSize = [extraInfo[kATInterstitialExtraAdSizeKey] respondsToSelector:@selector(CGSizeValue)] ? [extraInfo[kATInterstitialExtraAdSizeKey] CGSizeValue] : CGSizeMake(300.0f, 300.0f);
        // Interstitial
        if ([serverInfo[@"layout_type"] integerValue] == 1) {
            _expressInterstitial = [[NSClassFromString(@"BUNativeExpressInterstitialAd")alloc] initWithSlotID:serverInfo[@"slot_id"] adSize:adSize];
            _expressInterstitial.delegate = _customEvent;
            [_expressInterstitial loadAdData];
        } else {
            // Interstitial Video
            if ([serverInfo[@"is_video"] boolValue]) {
                _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
                if ([serverInfo[@"personalized_template"]integerValue] == 1) {
                    _expressFullScreenVideo = [[NSClassFromString(@"BUNativeExpressFullscreenVideoAd") alloc] initWithSlotID:serverInfo[@"slot_id"]];
                    _expressFullScreenVideo.delegate = _customEvent;
                    [_expressFullScreenVideo loadAdData];
                } else {
                    _fullscreenVideo = [[NSClassFromString(@"BUFullscreenVideoAd") alloc] initWithSlotID:serverInfo[@"slot_id"]];
                    _fullscreenVideo.delegate = _customEvent;
                    [_fullscreenVideo loadAdData];
                }
            }
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"TT"]}]);
    }
}

@end
