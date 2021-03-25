//
//  ATVungleRewardedVideoCustomEvent.m
//  AnyThinkVungleRewardedVideoAdapter
//
//  Created by Martin Lau on 11/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATVungleRewardedVideoCustomEvent.h"
#import "ATRewardedVideoManager.h"
#import "ATLogger.h"

@implementation ATVungleRewardedVideoCustomEvent
-(void) handlerPlayError:(NSError*)error {
    [ATLogger logError:[NSString stringWithFormat:@"VungleRewardedVideo::handlerPlayError:%@", error] type:ATLogTypeExternal];
    [self trackRewardedVideoAdPlayEventWithError:error];
    [[ATRewardedVideoManager sharedManager] removeCustomEventForKey:self.rewardedVideo.placementModel.placementID];
}

-(instancetype) initWithUnitID:(NSString *)unitID serverInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    self = [super initWithInfo:serverInfo localInfo:localInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadNotification:) name:kVungleRewardedVideoLoadNotification object:nil];
    }
    return self;
}

-(void) registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShowNotification:) name:kVungleRewardedVideoShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClickNotification:) name:kVungleRewardedVideoClickNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRewardNotification:) name:kVungleRewardedVideoRewardNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCloseNotification:) name:kVungleRewardedVideoCloseNotification object:nil];
}

-(void) handleLoadNotification:(NSNotification*)notification {
    if ([notification.userInfo[kVungleRewardedVideoNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID]) {
        [ATLogger logMessage:@"VungleRewardedVideo::load" type:ATLogTypeExternal];
        [self trackRewardedVideoAdLoaded:self.unitID adExtra:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kVungleRewardedVideoLoadNotification object:nil];
    }
}

-(void) handleShowNotification:(NSNotification*)notification {
    if ([notification.userInfo[kVungleRewardedVideoNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        [ATLogger logMessage:@"VungleRewardedVideo::show" type:ATLogTypeExternal];
        [self trackRewardedVideoAdShow];
        [self trackRewardedVideoAdVideoStart];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kVungleRewardedVideoShowNotification object:nil];
    }
}

-(void) handleClickNotification:(NSNotification*)notification {
    if ([notification.userInfo[kVungleRewardedVideoNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        [ATLogger logMessage:@"VungleRewardedVideo::click" type:ATLogTypeExternal];
        [self trackRewardedVideoAdClick];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kVungleRewardedVideoClickNotification object:nil];
    }
}

-(void) handleRewardNotification:(NSNotification*)notification {
    if ([notification.userInfo[kVungleRewardedVideoNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        [ATLogger logMessage:@"VungleRewardedVideo::reward" type:ATLogTypeExternal];
        [self trackRewardedVideoAdRewarded];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kVungleRewardedVideoRewardNotification object:nil];
    }
}

-(void) handleCloseNotification:(NSNotification*)notification {
    if ([notification.userInfo[kVungleRewardedVideoNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.rewardedVideo != nil) {
        [ATLogger logMessage:@"VungleRewardedVideo::close" type:ATLogTypeExternal];
        [self trackRewardedVideoAdVideoEnd];
        [self trackRewardedVideoAdCloseRewarded:self.rewardGranted];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kVungleRewardedVideoCloseNotification object:nil];
    }
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"placement_id"];
}

@end
