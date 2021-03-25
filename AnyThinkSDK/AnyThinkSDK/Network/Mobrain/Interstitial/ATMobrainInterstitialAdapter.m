//
//  ATMobrainInterstitialAdapter.m
//  AnyThinkMobrainAdapter
//
//  Created by Topon on 2/1/21.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import "ATMobrainInterstitialAdapter.h"
#import "ATMobrainInterstitialCustomEvent.h"
#import "ATMobrainInterstitialApis.h"
#import "ATMobrainBaseManager.h"
#import "ATAPI+Internal.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Interstitial.h"

@interface ATMobrainInterstitialAdapter ()
@property (nonatomic, readonly) id<ATABUInterstitialAd> interstitialAd;
@property (nonatomic, readonly) id<ATABUFullscreenVideoAd> fullscreenVideoAd;
@property (nonatomic, readonly) ATMobrainInterstitialCustomEvent *customEvent;
@end

@implementation ATMobrainInterstitialAdapter

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return customObject != nil;
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    
    NSDictionary *slotInfo = [NSJSONSerialization JSONObjectWithData:[interstitial.unitGroup.content[@"slot_info"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    if ([slotInfo[@"common"][@"unit_type"] integerValue] == 1) {
        [(id<ATABUFullscreenVideoAd>)interstitial.customObject showAdFromRootViewController:viewController];
    }else {
        [(id<ATABUInterstitialAd>)interstitial.customObject showAdFromRootViewController:viewController];
    }
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATMobrainBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(@"ABUInterstitialAd") != nil && NSClassFromString(@"ABUFullscreenVideoAd") != nil) {
        _customEvent = [[ATMobrainInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        NSDictionary *slotInfo = [NSJSONSerialization JSONObjectWithData:[serverInfo[@"slot_info"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        if ([slotInfo[@"common"][@"unit_type"] integerValue] == 1) {
            _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
            _fullscreenVideoAd = [[NSClassFromString(@"ABUFullscreenVideoAd") alloc] initWithAdUnitID:serverInfo[@"slot_id"]];
            _fullscreenVideoAd.getExpressAdIfCan = [slotInfo[@"common"][@"ad_style_type"] boolValue];
            _fullscreenVideoAd.delegate = _customEvent;
            __weak typeof(self) weakself = self;
            //当前配置拉取成功，直接loadAdData
            if (_fullscreenVideoAd.hasAdConfig) {
                [_fullscreenVideoAd loadAdData];
            } else {
                //当前配置未拉取成功，在成功之后会调用该callback
                [_fullscreenVideoAd setConfigSuccessCallback:^{
                    [weakself.fullscreenVideoAd loadAdData];
                }];
            }
        } else {
            CGSize adSize = [localInfo[kATInterstitialExtraAdSizeKey] respondsToSelector:@selector(CGSizeValue)] ? [localInfo[kATInterstitialExtraAdSizeKey] CGSizeValue] : CGSizeMake(300.0f, 300.0f);
            
            _interstitialAd = [[NSClassFromString(@"ABUInterstitialAd") alloc] initWithAdUnitID:serverInfo[@"slot_id"] size:adSize];
            _interstitialAd.delegate = _customEvent;
            __weak typeof(self) weakself = self;
            //当前配置拉取成功，直接loadAdData
            if (_interstitialAd.hasAdConfig) {
                [_interstitialAd loadAdData];
            } else {
                //当前配置未拉取成功，在成功之后会调用该callback
                [_interstitialAd setConfigSuccessCallback:^{
                    [weakself.interstitialAd loadAdData];
                }];
            }
        }
    } else {
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Mobrain"]}]);
    }
}


@end
