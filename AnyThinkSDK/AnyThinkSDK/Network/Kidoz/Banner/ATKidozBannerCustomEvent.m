//
//  ATKidozBannerCustomEvent.m
//  AnyThinkKidozAdapter
//
//  Created by Topon on 12/23/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATKidozBannerCustomEvent.h"
#import "ATLogger.h"

@interface ATKidozBannerCustomEvent()
@property(nonatomic, readonly) BOOL requestFinished;
@end

@implementation ATKidozBannerCustomEvent

-(instancetype) initWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super initWithInfo:serverInfo localInfo:localInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadedNotification:) name:kATKidozBannerLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFailedToLoadNotification:) name:kATKidozBannerFailedToLoadNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShowNotification:) name:kATKidozBannerShowNotification object:nil];
    }
    return self;
}

-(void) handleLoadedNotification:(NSNotification*)notification {
    if (!_requestFinished) {
        [self trackBannerAdLoaded:self.kidozBannerView adExtra:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATKidozBannerLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATKidozBannerFailedToLoadNotification object:nil];
        _requestFinished = YES;
    }
}

-(void) handleFailedToLoadNotification:(NSNotification*)notification {
    if (!_requestFinished) {
        [self trackBannerAdLoadFailed:notification.userInfo[kATKidozBannerNotificationUserInfoErrorKey]];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATKidozBannerLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kATKidozBannerFailedToLoadNotification object:nil];
        _requestFinished = YES;
    }
}

-(void) handleShowNotification:(NSNotification*)notification {
    if (self.banner != nil) {
        [self trackBannerAdImpression];
    }
}

-(void) removedFromWindow {
    [super removedFromWindow];
    [[NSClassFromString(@"KidozSDK") instance] hideBanner];
    self.kidozBannerView = nil;
}

- (void)cleanup {
    [super cleanup];
    [[NSClassFromString(@"KidozSDK") instance] hideBanner];
    self.kidozBannerView = nil;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
