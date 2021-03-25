//
//  ATKidozRewardedVideoCustomEvent.m
//  AnyThinkKidozAdapter
//
//  Created by Topon on 12/23/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATKidozRewardedVideoCustomEvent.h"
#import "ATLogger.h"

@interface ATKidozRewardedVideoCustomEvent()
@property(nonatomic, readonly) BOOL requestFinished;
@end

@implementation ATKidozRewardedVideoCustomEvent

-(instancetype) initWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super initWithInfo:serverInfo localInfo:localInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadedNotification:) name:kATKidozRewardedVideoLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFailedToLoadNotification:) name:kATKidozRewardedVideoFailedToLoadNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShowNotification:) name:kATKidozRewardedVideoShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCloseNotification:) name:kATKidozRewardedVideoCloseNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRewardNotification:) name:kATKidozRewardedVideoRewardNotification object:nil];
    }
    return self;
}

-(void) handleLoadedNotification:(NSNotification*)notification {
    if (!_requestFinished) {
        [self trackRewardedVideoAdLoaded:self adExtra:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATKidozRewardedVideoLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATKidozRewardedVideoFailedToLoadNotification object:nil];
        _requestFinished = YES;
    }
}

-(void) handleFailedToLoadNotification:(NSNotification*)notification {
    if (!_requestFinished) {
        [self trackRewardedVideoAdLoadFailed:notification.userInfo[kATKidozRewardedVideoNotificationUserInfoErrorKey]];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATKidozRewardedVideoLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATKidozRewardedVideoFailedToLoadNotification object:nil];
        _requestFinished = YES;
    }
}

-(void) handleShowNotification:(NSNotification*)notification {
    if (self.rewardedVideo != nil) {
        [self trackRewardedVideoAdShow];
        [self trackRewardedVideoAdVideoStart];
    }
}

-(void) handleRewardNotification:(NSNotification*)notification {
    if (self.rewardedVideo != nil) {
        [self trackRewardedVideoAdVideoEnd];
        [self trackRewardedVideoAdRewarded];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATKidozRewardedVideoRewardNotification object:nil];
    }
}

-(void) handleCloseNotification:(NSNotification*)notification {
    if (self.rewardedVideo != nil) {
        [self trackRewardedVideoAdCloseRewarded:self.rewardGranted];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATKidozRewardedVideoCloseNotification object:nil];
    }
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
