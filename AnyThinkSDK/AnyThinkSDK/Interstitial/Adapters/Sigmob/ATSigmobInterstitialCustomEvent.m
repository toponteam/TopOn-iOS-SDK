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
-(instancetype) initWithUnitID:(NSString *)unitID customInfo:(NSDictionary *)customInfo {
    self = [super initWithUnitID:unitID customInfo:customInfo];
    if (self != nil) {
        _usesRewardedVideo = ([customInfo[kAdapterCustomInfoExtraKey] isKindOfClass:[NSDictionary class]] && [customInfo[kAdapterCustomInfoExtraKey][kATInterstitialExtraUsesRewardedVideo] boolValue]) ? [customInfo[kAdapterCustomInfoExtraKey][kATInterstitialExtraUsesRewardedVideo] boolValue] : NO;
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
        [self handleAssets:@{kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kInterstitialAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:self}];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobInterstitialLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobInterstitialFailedToLoadNotification object:nil];
    }
}

-(void) handleFailedToLoadNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobInterstitialNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID]) {
        [self handleLoadingFailure:notification.userInfo[kATSigmobInterstitialNotificationUserInfoErrorKey]];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobInterstitialLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobInterstitialFailedToLoadNotification object:nil];
    }
}

-(void) handlePlayErrorNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobInterstitialNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.interstitial != nil) {
        if ([self.delegate respondsToSelector:@selector(interstitialDidFailToPlayVideoForPlacementID:error:extra:)]) {
            [self.delegate interstitialDidFailToPlayVideoForPlacementID:self.interstitial.placementModel.placementID error:[NSError errorWithDomain:@"com.anythink.SigmobInterstitialVideoPlayingFailure" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to play video for interstitial", NSLocalizedFailureReasonErrorKey:@"SigmobInterstitialVideo failed to play video"}] extra:[self delegateExtra]];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobInterstitialPlayStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobInterstitialPlayEndNotification object:nil];
    }
}

-(void) handleStartPlayingNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobInterstitialNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.interstitial != nil) {
        [self trackShow];
        if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
        if ([self.delegate respondsToSelector:@selector(interstitialDidStartPlayingVideoForPlacementID:extra:)]) {
            [self.delegate interstitialDidStartPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobInterstitialPlayStartNotification object:nil];
    }
}

-(void) handleEndPlayingNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobInterstitialNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.interstitial != nil) {
        [self trackVideoEnd];
        if ([self.delegate respondsToSelector:@selector(interstitialDidEndPlayingVideoForPlacementID:extra:)]) {
            [self.delegate interstitialDidEndPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobInterstitialPlayEndNotification object:nil];
    }
}

-(void) handleClickNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobInterstitialNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.interstitial != nil) {
        [self trackClick];
        if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
            [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
        }
    }
}

-(void) handleCloseNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobInterstitialNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.interstitial != nil) {
        [super handleClose];
        if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) {
            [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobInterstitialClickNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobInterstitialCloseNotification object:nil];
    }
}
-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.interstitial.unitGroup.content[@"placement_id"];
    return extra;
}
@end
