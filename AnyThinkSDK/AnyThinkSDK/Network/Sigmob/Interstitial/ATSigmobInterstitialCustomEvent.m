//
//  ATSigmobInterstitialCustomEvent.m
//  AnyThinkSigmobInterstitialAdapter
//
//  Created by Martin Lau on 2019/9/10.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATSigmobInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
#import "ATSigmobInterstitialAdapter.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Interstitial.h"

@implementation ATSigmobInterstitialCustomEvent
-(instancetype) initWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super initWithInfo:serverInfo localInfo:localInfo];
    if (self != nil) {
        _usesRewardedVideo = ([localInfo isKindOfClass:[NSDictionary class]] && [localInfo[kATInterstitialExtraUsesRewardedVideo] boolValue]) ? [localInfo[kATInterstitialExtraUsesRewardedVideo] boolValue] : NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadedNotification:) name:kATSigmobInterstitialLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFailedToLoadNotification:) name:kATSigmobInterstitialFailedToLoadNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStartPlayingNotification:) name:kATSigmobInterstitialPlayStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEndPlayingNotification:) name:kATSigmobInterstitialPlayEndNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePlayErrorNotification:) name:kATSigmobInterstitialFailedToPlayNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCloseNotification:) name:kATSigmobInterstitialCloseNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClickNotification:) name:kATSigmobInterstitialClickNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataLoadedNotification:) name:kATSigmobInterstitialDataLoadedNotification object:nil];
    }
    return self;
}

-(void) handleDataLoadedNotification:(NSNotification*)notification {
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

-(void) handleLoadedNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobInterstitialNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID]) {
//        [self handleAssets:@{kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kInterstitialAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:self}];
        [self trackInterstitialAdLoaded:self adExtra:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobInterstitialLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobInterstitialFailedToLoadNotification object:nil];
    }
}

-(void) handleFailedToLoadNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobInterstitialNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID]) {
        [self trackInterstitialAdLoadFailed:notification.userInfo[kATSigmobInterstitialNotificationUserInfoErrorKey]];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobInterstitialLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobInterstitialFailedToLoadNotification object:nil];
    }
}

-(void) handlePlayErrorNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobInterstitialNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.interstitial != nil) {
        [self trackInterstitialAdDidFailToPlayVideo:[NSError errorWithDomain:@"com.anythink.SigmobInterstitialVideoPlayingFailure" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to play video for interstitial", NSLocalizedFailureReasonErrorKey:@"SigmobInterstitialVideo failed to play video"}]];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobInterstitialPlayStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobInterstitialPlayEndNotification object:nil];
    }
}

-(void) handleStartPlayingNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobInterstitialNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.interstitial != nil) {
        [self trackInterstitialAdShow];
        [self trackInterstitialAdVideoStart];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobInterstitialPlayStartNotification object:nil];
    }
}

-(void) handleEndPlayingNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobInterstitialNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.interstitial != nil) {
        [self trackInterstitialAdVideoEnd];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobInterstitialPlayEndNotification object:nil];
    }
}

-(void) handleClickNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobInterstitialNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.interstitial != nil) {
        [self trackInterstitialAdClick];
    }
}

-(void) handleCloseNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobInterstitialNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.interstitial != nil) {
        [super trackInterstitialAdClose];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobInterstitialClickNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobInterstitialCloseNotification object:nil];
    }
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"placement_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"placement_id"];
//    return extra;
//}
@end
