//
//  ATVungleBannerCustomEvent.m
//  AnyThinkVungleBannerAdapter
//
//  Created by Martin Lau on 2020/6/9.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATVungleBannerCustomEvent.h"
#import "Utilities.h"
#import "ATBannerManager.h"
#import "ATVungleBannerAdapter.h"
static NSString *const kVungleSDKInitializationNotification = @"com.anythink.VungleDelegateInit";
static NSString *const kVungleLoadNotification = @"com.anythink.VungleDelegateLoaded";
static NSString *const kVungleShowNotification = @"com.anythink.VungleDelegateShown";
static NSString *const kVungleCloseNotification = @"com.anythink.VungleDelegateClose";
static NSString *const kVungleNotificationUserInfoPlacementIDKey = @"placement_id";
static NSString *const kVungleNotificationUserInfoErrorKey = @"error";
static NSString *const kVungleNotificationUserInfoVideoCompletedFlagKey = @"video_completed";
static NSString *const kVungleNotificationUserInfoClickFlagKey = @"clicked";

@implementation ATVungleBannerCustomEvent
-(instancetype) initWithUnitID:(NSString *)unitID serverInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo  {
    self = [super initWithInfo:serverInfo localInfo:localInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadNotification:) name:kVungleLoadNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCloseNotification:) name:kVungleCloseNotification object:nil];
    }
    return self;
}

-(void) handleLoadNotification:(NSNotification*)notification {
    if ([notification.userInfo[kVungleNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kVungleLoadNotification object:nil];
//        [self handleAssets:@{kBannerAssetsCustomEventKey:self}];
        [self trackBannerAdLoaded:nil adExtra:@{kBannerAssetsCustomEventKey:self}];
    }
}

-(void) handleCloseNotification:(NSNotification*)notification {
    if ([notification.userInfo[kVungleNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kVungleCloseNotification object:nil];
        if ([notification.userInfo[kVungleNotificationUserInfoClickFlagKey] boolValue]) {
            [self trackBannerAdClick];
        }
    }
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"placement_id"];
}
@end
