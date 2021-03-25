//
//  ATKidozInterstitialCustomEvent.m
//  AnyThinkKidozAdapter
//
//  Created by Topon on 12/23/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATKidozInterstitialCustomEvent.h"
#import "ATLogger.h"

@interface ATKidozInterstitialCustomEvent()
@property(nonatomic, readonly) BOOL requestFinished;
@end

@implementation ATKidozInterstitialCustomEvent

-(instancetype) initWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super initWithInfo:serverInfo localInfo:localInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadedNotification:) name:kATKidozInterstitialLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFailedToLoadNotification:) name:kATKidozInterstitialFailedToLoadNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShowNotification:) name:kATKidozInterstitialShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCloseNotification:) name:kATKidozInterstitialCloseNotification object:nil];
    }
    return self;
}

-(void) handleLoadedNotification:(NSNotification*)notification {
    if (!_requestFinished) {
        [self trackInterstitialAdLoaded:self adExtra:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATKidozInterstitialLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATKidozInterstitialFailedToLoadNotification object:nil];
        _requestFinished = YES;
    }
}

-(void) handleFailedToLoadNotification:(NSNotification*)notification {
    if (!_requestFinished) {
        [self trackInterstitialAdLoadFailed:notification.userInfo[kATKidozInterstitialNotificationUserInfoErrorKey]];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATKidozInterstitialLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATKidozInterstitialFailedToLoadNotification object:nil];
        _requestFinished = YES;
    }
}

-(void) handleShowNotification:(NSNotification*)notification {
    if (self.interstitial != nil) {
        [self trackInterstitialAdShow];
    }
}

-(void) handleCloseNotification:(NSNotification*)notification {
    if (self.interstitial != nil) {
        [self trackInterstitialAdClose];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATKidozInterstitialCloseNotification object:nil];
    }
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
