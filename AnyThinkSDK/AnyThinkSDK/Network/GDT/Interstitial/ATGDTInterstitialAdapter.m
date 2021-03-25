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
#import "ATGDTBaseManager.h"

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
    id<ATGDTUnifiedInterstitialAd> gdtInterstitial = interstitial.customObject;
    interstitial.customEvent.delegate = delegate;
    if ([interstitial.unitGroup.content[@"unit_version"] integerValue] == 2) {
        if ([interstitial.unitGroup.content[@"is_fullscreen"] integerValue] == 1) {
            [gdtInterstitial presentFullScreenAdFromRootViewController:viewController];
        } else {
            [gdtInterstitial presentAdFromRootViewController:viewController];
        }
    }
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATGDTBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"GDTUnifiedInterstitialAd") != nil) {
        _customEvent = [[ATGDTInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        if ([serverInfo[@"unit_version"] integerValue] == 2) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_unifiedInterstitialAd = [[NSClassFromString(@"GDTUnifiedInterstitialAd") alloc] initWithPlacementId:serverInfo[@"unit_id"]];
                self->_unifiedInterstitialAd.delegate = self->_customEvent;
                self->_unifiedInterstitialAd.videoAutoPlayOnWWAN = [serverInfo[@"video_autoplay"] integerValue] == 1 ? YES : NO;
                self->_unifiedInterstitialAd.videoMuted = [serverInfo[@"video_muted"] boolValue];
                if (serverInfo[@"video_duration"] != nil) { self->_unifiedInterstitialAd.maxVideoDuration = [serverInfo[@"video_duration"] integerValue]; }
                if ([serverInfo[@"is_fullscreen"] integerValue] == 1) {
                    [self->_unifiedInterstitialAd loadFullScreenAd];
                } else {
                    [self->_unifiedInterstitialAd loadAd];
                }
            });
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"GDT"]}]);
    }
}
@end
