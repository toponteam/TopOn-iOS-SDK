//
//  ATUnityAdsRewardedVideoCustomEvent.m
//  AnyThinkUnityAdsRewardedVideoAdapter
//
//  Created by Martin Lau on 11/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATUnityAdsRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "Utilities.h"

extern NSString *const kATUnityAdsRVLoadedNotification;
extern NSString *const kATUnityAdsRVFailedToLoadNotification;
extern NSString *const kATUnityAdsRVPlayStartNotification;
extern NSString *const kATUnityAdsRVClickNotification;
extern NSString *const kATUnityAdsRVCloseNotification;
extern NSString *const kATUnityAdsRVNotificationUserInfoPlacementIDKey;
extern NSString *const kATUnityAdsRVNotificationUserInfoErrorKey;
extern NSString *const kATUnityAdsRVNotificationUserInfoRewardedFlag;

@interface ATUnityAdsRewardedVideoCustomEvent()
@property(nonatomic, readonly) BOOL requestFinished;
@end
@implementation ATUnityAdsRewardedVideoCustomEvent

-(instancetype) initWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super initWithInfo:serverInfo localInfo:localInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadedNotification:) name:kATUnityAdsRVLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFailedToLoadNotification:) name:kATUnityAdsRVFailedToLoadNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStartPlayingNotification:) name:kATUnityAdsRVPlayStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCloseNotification:) name:kATUnityAdsRVCloseNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClickNotification:) name:kATUnityAdsRVClickNotification object:nil];
    }
    return self;
}

-(void) handleLoadedNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATUnityAdsRVNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && !_requestFinished) {
        [self trackRewardedVideoAdLoaded:self adExtra:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATUnityAdsRVLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATUnityAdsRVFailedToLoadNotification object:nil];
        _requestFinished = YES;
    }
}

-(void) handleFailedToLoadNotification:(NSNotification*)notification {
    [self trackRewardedVideoAdLoadFailed:notification.userInfo[kATUnityAdsRVNotificationUserInfoPlacementIDKey]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATUnityAdsRVLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kATUnityAdsRVFailedToLoadNotification object:nil];
    _requestFinished = YES;
}

-(void) handleStartPlayingNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATUnityAdsRVNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID]) {
        [self trackRewardedVideoAdShow];
        [self trackRewardedVideoAdVideoStart];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATUnityAdsRVPlayStartNotification object:nil];
    }
}

-(void) handleClickNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATUnityAdsRVNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID]) {
        [self trackRewardedVideoAdClick];
    }
}

-(void) handleCloseNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATUnityAdsRVNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID]) {
        self.rewardGranted = [notification.userInfo[kATUnityAdsRVNotificationUserInfoRewardedFlag] boolValue];
        [self trackRewardedVideoAdVideoEnd];
        if(self.rewardGranted){
            [self trackRewardedVideoAdRewarded];
        }
        [self trackRewardedVideoAdCloseRewarded:self.rewardGranted];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATUnityAdsRVClickNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATUnityAdsRVCloseNotification object:nil];
    }
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"placement_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"placement_id"];
//    return extra;
//}

@end
