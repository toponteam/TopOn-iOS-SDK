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

@implementation ATVungleBannerCustomEvent
-(instancetype) initWithUnitID:(NSString *)unitID serverInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo  {
    self = [super initWithInfo:serverInfo localInfo:localInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadNotification:) name:kVungleBannerLoadNotification object:nil];

    }
    return self;
}

-(void) registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShowNotification:) name:kVungleBannerShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClickNotification:) name:kVungleBannerClickNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCloseNotification:) name:kVungleBannerCloseNotification object:nil];
}

-(void) handleLoadNotification:(NSNotification*)notification {
    if ([notification.userInfo[kVungleBannerNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kVungleBannerLoadNotification object:nil];
        [self trackBannerAdLoaded:nil adExtra:@{kBannerAssetsCustomEventKey:self}];
    }
}

-(void) handleShowNotification:(NSNotification*)notification {
    if ([notification.userInfo[kVungleBannerNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kVungleBannerShowNotification object:nil];
        [self trackBannerAdImpression];
    }
}

-(void) handleClickNotification:(NSNotification*)notification {
    if ([notification.userInfo[kVungleBannerNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kVungleBannerClickNotification object:nil];
        [self trackBannerAdClick];
    }
}

-(void) handleCloseNotification:(NSNotification*)notification {
    if ([notification.userInfo[kVungleBannerNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kVungleBannerCloseNotification object:nil];
    }
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"placement_id"];
}
@end
