//
//  ATUnityAdsInterstitialCustomEvent.m
//  AnyThinkUnityAdsInterstitialAdapter
//
//  Created by Martin Lau on 2018/12/25.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATUnityAdsInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATAPI.h"
#import "ATInterstitialManager.h"

@interface ATUnityAdsInterstitialCustomEvent()
@property(nonatomic, readonly) BOOL requestFinished;
@end
@implementation ATUnityAdsInterstitialCustomEvent

-(instancetype) initWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super initWithInfo:serverInfo localInfo:localInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadedNotification:) name:kATUnityAdsInterstitialLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFailedToLoadNotification:) name:kATUnityAdsInterstitialFailedToLoadNotification object:nil];
        
    }
    return self;
}
-(void) registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStartPlayingNotification:) name:kATUnityAdsInterstitialPlayStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCloseNotification:) name:kATUnityAdsInterstitialCloseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClickNotification:) name:kATUnityAdsInterstitialClickNotification object:nil];
}
-(void) handleLoadedNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATUnityAdsInterstitialNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && !_requestFinished) {
        [self trackInterstitialAdLoaded:self adExtra:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATUnityAdsInterstitialLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATUnityAdsInterstitialFailedToLoadNotification object:nil];
        _requestFinished = YES;
    }
}

-(void) handleFailedToLoadNotification:(NSNotification*)notification {
    [self trackInterstitialAdLoadFailed:notification.userInfo[kATUnityAdsInterstitialNotificationUserInfoErrorKey]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATUnityAdsInterstitialLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATUnityAdsInterstitialFailedToLoadNotification object:nil];
    _requestFinished = YES;
}

-(void) handleStartPlayingNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATUnityAdsInterstitialNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.interstitial != nil) {
        [self trackInterstitialAdShow];
        [self trackInterstitialAdVideoStart];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATUnityAdsInterstitialPlayStartNotification object:nil];
    }
}

-(void) handleClickNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATUnityAdsInterstitialNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.interstitial != nil) {
        [self trackInterstitialAdClick];
    }
}

-(void) handleCloseNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATUnityAdsInterstitialNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.interstitial != nil) {
        [super trackInterstitialAdClose];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATUnityAdsInterstitialClickNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATUnityAdsInterstitialCloseNotification object:nil];
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
