//
//  ATVungleInterstitialCustomEvent.m
//  AnyThinkVungleInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/9.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATVungleInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"


@interface ATVungleInterstitialCustomEvent()
@end
@implementation ATVungleInterstitialCustomEvent
-(ATNativeADSourceType) adSourceType {
    return ATNativeADSourceTypeVideo;
}

-(void) handlerPlayError:(NSError*)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"VungleInterstitial::play error:%@", error] type:ATLogTypeExternal];
    [self trackInterstitialAdShowFailed:error];
}

-(void) handleLoadNotification:(NSNotification*)notification {
    if ([notification.userInfo[kVungleInterstitialNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID]) {
        [ATLogger logMessage:@"VungleInterstitial::load" type:ATLogTypeExternal];
//        [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kAdAssetsCustomObjectKey:self.unitID}];
        [self trackInterstitialAdLoaded:self.unitID adExtra:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kVungleInterstitialLoadNotification object:nil];
    }
}

-(void) handleShowNotification:(NSNotification*)notification {
    if ([notification.userInfo[kVungleInterstitialNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.interstitial != nil) {
        [ATLogger logMessage:@"VungleInterstitial::show" type:ATLogTypeExternal];
        [self trackInterstitialAdShow];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kVungleInterstitialShowNotification object:nil];
    }
}

-(void) handleClickNotification:(NSNotification*)notification {
    if ([notification.userInfo[kVungleInterstitialNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.interstitial != nil) {
        [ATLogger logMessage:@"VungleInterstitial::show" type:ATLogTypeExternal];
        [self trackInterstitialAdClick];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kVungleInterstitialShowNotification object:nil];
    }
}

-(void) handleCloseNotification:(NSNotification*)notification {
    if ([notification.userInfo[kVungleInterstitialNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.interstitial != nil) {
        [ATLogger logMessage:@"VungleInterstitial::close" type:ATLogTypeExternal];
        
        [self trackInterstitialAdClose];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kVungleInterstitialCloseNotification object:nil];
    }
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShowNotification:) name:kVungleInterstitialShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClickNotification:) name:kVungleInterstitialClickNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCloseNotification:) name:kVungleInterstitialCloseNotification object:nil];
}
-(instancetype) initWithInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo adapter:(ATVungleInterstitialAdapter*)adapter {
    self = [super initWithInfo:serverInfo localInfo:localInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadNotification:) name:kVungleInterstitialLoadNotification object:nil];
        
    }
    return self;
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"placement_id"];
}

@end
