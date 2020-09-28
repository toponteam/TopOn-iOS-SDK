//
//  ATUnityAdsBannerCustomEvent.m
//  AnyThinkUnityAdsBannerAdapter
//
//  Created by Martin Lau on 2018/12/25.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATUnityAdsBannerCustomEvent.h"
#import "Utilities.h"
#import "ATBannerManager.h"
#import "ATAPI+Internal.h"


@implementation ATUnityAdsBannerCustomEvent
-(instancetype) initWithUnitID:(NSString *)unitID serverInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    self = [super initWithInfo:serverInfo localInfo:localInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loaded:) name:kATUnityAdsBannerNotificationLoaded object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clicked:) name:kATUnityAdsBannerNotificationClick object:nil];
    }
     return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) loaded:(NSNotification*)notification {
    if ([notification.userInfo[kATUnityAdsBannerNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && notification.userInfo[kATUnityAdsBannerNotificationUserInfoViewKey] != nil) {
        [self trackBannerAdLoaded:notification.userInfo[kATUnityAdsBannerNotificationUserInfoViewKey] adExtra:@{kAdAssetsCustomObjectKey:notification.userInfo[kATUnityAdsBannerNotificationUserInfoViewKey]}];
    }
}

-(void) clicked:(NSNotification*)notification {
    if ([notification.userInfo[kATUnityAdsBannerNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID]) {
        [self trackBannerAdClick];
    }
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"placement_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.banner.unitGroup.content[@"placement_id"];
//    return extra;
//}
@end
