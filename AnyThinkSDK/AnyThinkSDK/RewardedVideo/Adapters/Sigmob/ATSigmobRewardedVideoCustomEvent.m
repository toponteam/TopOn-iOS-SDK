//
//  ATSigmobRewardedVideoCustomEvent.m
//  AnyThinkSigmobRewardedVideoAdapter
//
//  Created by Martin Lau on 2019/9/9.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATSigmobRewardedVideoCustomEvent.h"
#import "Utilities.h"
#import "ATRewardedVideoManager.h"
#import "ATSigmobRewardedVideoAdapter.h"

@implementation ATSigmobRewardedVideoCustomEvent
-(instancetype) initWithUnitID:(NSString *)unitID serverInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    self = [super initWithInfo:serverInfo localInfo:localInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadedNotification:) name:kATSigmobRVLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFailedToLoadNotification:) name:kATSigmobRVFailedToLoadNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStartPlayingNotification:) name:kATSigmobRVPlayStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEndPlayingNotification:) name:kATSigmobRVPlayEndNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePlayErrorNotification:) name:kATSigmobRVFailedToPlayNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCloseNotification:) name:kATSigmobRVCloseNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClickNotification:) name:kATSigmobRVClickNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataLoadedNotification:) name:kATSigmobRVDataLoadedNotification object:nil];
    }
    return self;
}

-(void) handleDataLoadedNotification:(NSNotification*)notification {
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

-(void) handleLoadedNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobRVNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID]) {
        [self trackRewardedVideoAdLoaded:self adExtra:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobRVLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobRVFailedToLoadNotification object:nil];
    }
}

-(void) handleFailedToLoadNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobRVNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID]) {
        [self trackRewardedVideoAdLoadFailed:notification.userInfo[kATSigmobRVNotificationUserInfoErrorKey]];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobRVLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobRVFailedToLoadNotification object:nil];
    }
}

-(void) handlePlayErrorNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobRVNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        NSError *error = notification.userInfo[kATSigmobRVNotificationUserInfoErrorKey];
        [self trackRewardedVideoAdPlayEventWithError:error];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobRVPlayStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobRVPlayEndNotification object:nil];
    }
}

-(void) handleStartPlayingNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobRVNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        [self trackRewardedVideoAdShow];
        [self trackRewardedVideoAdVideoStart];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobRVPlayStartNotification object:nil];
    }
}

-(void) handleEndPlayingNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobRVNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        [self trackRewardedVideoAdVideoEnd];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobRVPlayEndNotification object:nil];
    }
}

-(void) handleClickNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobRVNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        [self trackRewardedVideoAdClick];
    }
}

-(void) handleCloseNotification:(NSNotification*)notification {
    if ([notification.userInfo[kATSigmobRVNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        self.rewardGranted = [notification.userInfo[kATSigmobRVNotificationUserInfoRewardedFlag] boolValue];
        if (self.rewardGranted) {
            [self trackRewardedVideoAdRewarded];
        }
        
        [self trackRewardedVideoAdCloseRewarded:self.rewardGranted];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobRVClickNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATSigmobRVCloseNotification object:nil];
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
