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
@interface ATTTInterstitialAdapter()
@property(nonatomic, readonly) id<ATBUInterstitialAd> interstitial;
@property(nonatomic, readonly) id<ATBUFullscreenVideoAd> fullscreenVideo;
@property(nonatomic, readonly) id<ATBUNativeExpressInterstitialAd> expressInterstitial;
@property(nonatomic, readonly) id<ATBUNativeExpressFullscreenVideoAd> expressFullScreenVideo;
@property(nonatomic, readonly) ATTTInterstitialCustomEvent *customEvent;
@end

@implementation ATTTInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return ((id<ATBUInterstitialAd>)customObject).adValid || ((id<ATBUNativeExpressFullscreenVideoAd>)customObject).adValid;
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    //Here for full screen video ad, we also use id<ATWMInterstitialAd>, for the presenting methods are the same.
    if ([interstitial.customObject isKindOfClass:NSClassFromString(@"BUNativeExpressFullscreenVideoAd")]) {
        id<ATBUNativeExpressFullscreenVideoAd> ttInterstitial = interstitial.customObject;
        interstitial.customEvent.delegate = delegate;
        [ttInterstitial showAdFromRootViewController:viewController];
    } else {
        id<ATBUInterstitialAd> ttInterstitial = interstitial.customObject;
        interstitial.customEvent.delegate = delegate;
        [ttInterstitial showAdFromRootViewController:viewController];
    }
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameTT]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameTT];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"BUAdSDKManager") SDKVersion] forNetwork:kNetworkNameTT];
            [NSClassFromString(@"BUAdSDKManager") setAppID:info[@"app_id"]];
        }
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"BUFullscreenVideoAd") != nil && NSClassFromString(@"BUInterstitialAd") != nil && NSClassFromString(@"BUNativeExpressInterstitialAd") != nil) {
        _customEvent = [[ATTTInterstitialCustomEvent alloc] initWithUnitID:info[@"slot_id"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        NSDictionary *extraInfo = info[kAdapterCustomInfoExtraKey];
        CGSize adSize = [extraInfo[kATInterstitialExtraAdSizeKey] respondsToSelector:@selector(CGSizeValue)] ? [extraInfo[kATInterstitialExtraAdSizeKey] CGSizeValue] : CGSizeMake(300.0f, 300.0f);
        if ([info[@"layout_type"] integerValue] == 1) {
            _expressInterstitial = [[NSClassFromString(@"BUNativeExpressInterstitialAd")alloc] initWithSlotID:info[@"slot_id"] adSize:adSize];
            _expressInterstitial.delegate = _customEvent;
            [_expressInterstitial loadAdData];
        } else {
            if ([info[@"is_video"] boolValue]) {
                _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
                if ([info[@"personalized_template"]integerValue] == 1) {
                    _expressFullScreenVideo = [[NSClassFromString(@"BUNativeExpressFullscreenVideoAd") alloc] initWithSlotID:info[@"slot_id"]];
                    _expressFullScreenVideo.delegate = _customEvent;
                    [_expressFullScreenVideo loadAdData];
                } else {
                    _fullscreenVideo = [[NSClassFromString(@"BUFullscreenVideoAd") alloc] initWithSlotID:info[@"slot_id"]];
                    _fullscreenVideo.delegate = _customEvent;
                    [_fullscreenVideo loadAdData];
                }
            } else {
                _interstitial = [[NSClassFromString(@"BUInterstitialAd") alloc] initWithSlotID:info[@"slot_id"] size:[NSClassFromString(@"BUSize") sizeBy:[info[@"media_size"] integerValue]]];
                _interstitial.delegate = _customEvent;
                [_interstitial loadAdData];
            }
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"TT"]}]);
    }
}

@end
