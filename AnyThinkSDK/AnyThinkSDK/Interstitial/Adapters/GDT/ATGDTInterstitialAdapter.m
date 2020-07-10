//
//  ATGDTInterstitialAdapter.m
//  AnyThinkGDTInterstitialAdapter
//
//  Created by Martin Lau on 21/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATGDTInterstitialAdapter.h"
#import "ATAPI+Internal.h"
#import "ATGDTInterstitialCustomEvent.h"
@interface ATGDTInterstitialAdapter()
@property (nonatomic, readonly) ATGDTInterstitialCustomEvent *customEvent;
@property (nonatomic, readonly) id<ATGDTMobInterstitial> interstitial;
@property (nonatomic, readonly) id<ATGDTUnifiedInterstitialAd> unifiedInterstitialAd;
@end
@implementation ATGDTInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return [info[@"unit_version"] integerValue] == 2 ? ((id<ATGDTUnifiedInterstitialAd>)customObject).isAdValid : ((id<ATGDTMobInterstitial>)customObject).isReady;
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    id<ATGDTMobInterstitial> gdtInterstitial = interstitial.customObject;
    interstitial.customEvent.delegate = delegate;
    if ([interstitial.unitGroup.content[@"unit_version"] integerValue] == 2) {
        if ([interstitial.unitGroup.content[@"is_fullscreen"] integerValue] == 1) {
            [(id<ATGDTUnifiedInterstitialAd>)gdtInterstitial presentFullScreenAdFromRootViewController:viewController];
        } else {
            [(id<ATGDTUnifiedInterstitialAd>)gdtInterstitial presentAdFromRootViewController:viewController];
        }
    } else {
        [gdtInterstitial presentFromRootViewController:viewController];
    }
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary *)info {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameGDT]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameGDT];
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"GDTSDKConfig") sdkVersion] forNetwork:kNetworkNameGDT];
            [NSClassFromString(@"GDTSDKConfig") registerAppId:info[@"app_id"]];
        }
    }
    return self;
}

-(void) loadADWithInfo:(id)info completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"GDTMobInterstitial") != nil && NSClassFromString(@"GDTUnifiedInterstitialAd") != nil) {
        _customEvent = [[ATGDTInterstitialCustomEvent alloc] initWithUnitID:info[@"unit_id"] customInfo:info];
        _customEvent.requestCompletionBlock = completion;
        if ([info[@"unit_version"] integerValue] == 2) {
            _unifiedInterstitialAd = [[NSClassFromString(@"GDTUnifiedInterstitialAd") alloc] initWithPlacementId:info[@"unit_id"]];
            _unifiedInterstitialAd.delegate = _customEvent;
            _unifiedInterstitialAd.videoAutoPlayOnWWAN = [info[@"video_autoplay"] boolValue];
            _unifiedInterstitialAd.videoMuted = [info[@"video_muted"] boolValue];
            if (info[@"video_duration"] != nil) { _unifiedInterstitialAd.maxVideoDuration = [info[@"video_duration"] integerValue]; }
            if ([info[@"is_fullscreen"] integerValue] == 1) {
                [_unifiedInterstitialAd loadFullScreenAd];
            } else {
                [_unifiedInterstitialAd loadAd];
            }
        } else {
            _interstitial = [[NSClassFromString(@"GDTMobInterstitial") alloc] initWithAppId:info[@"app_id"] placementId:info[@"unit_id"]];
            _interstitial.delegate = _customEvent;
            [_interstitial loadAd];
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"GDT"]}]);
    }
}
@end
