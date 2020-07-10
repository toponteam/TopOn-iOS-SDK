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
-(instancetype) initWithUnitID:(NSString *)unitID customInfo:(NSDictionary *)customInfo {
    self = [super initWithUnitID:unitID customInfo:customInfo];
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
        [self handleAssets:@{kBannerAssetsUnitIDKey:self.unitID != nil ? self.unitID : @"", kBannerAssetsBannerViewKey:notification.userInfo[kATUnityAdsBannerNotificationUserInfoViewKey], kBannerAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:notification.userInfo[kATUnityAdsBannerNotificationUserInfoViewKey]}];
    }
}

-(void) clicked:(NSNotification*)notification {
    if ([notification.userInfo[kATUnityAdsBannerNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID]) {
        [self trackClick];
        if ([self.delegate respondsToSelector:@selector(bannerView:didClickWithPlacementID:extra:)]) {
            [self.delegate bannerView:self.bannerView didClickWithPlacementID:self.banner.placementModel.placementID extra:[self delegateExtra]];
        }
    }
}
-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.banner.unitGroup.content[@"placement_id"];
    return extra;
}
@end
