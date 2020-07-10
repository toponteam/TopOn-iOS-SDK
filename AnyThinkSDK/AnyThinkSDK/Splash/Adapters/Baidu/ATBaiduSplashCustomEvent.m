//
//  ATBaiduSplashCustomEvent.m
//  AnyThinkBaiduSplashAdapter
//
//  Created by Martin Lau on 2018/12/21.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATBaiduSplashCustomEvent.h"
#import "Utilities.h"
#import "ATSplashManager.h"
#import "ATSplashDelegate.h"
@interface ATBaiduSplashCustomEvent()
@property(nonatomic, readonly) NSString *publisherID;
@end
@implementation ATBaiduSplashCustomEvent
-(instancetype)initWithPublisherID:(NSString*)publisherID unitID:(NSString *)unitID customInfo:(NSDictionary *)customInfo {
    self = [super initWithUnitID:unitID customInfo:customInfo];
    if (self != nil) {
        _publisherID = publisherID;
    }
    return self;
}

- (NSString *)publisherId {
    return _publisherID;
}

- (void)splashSuccessPresentScreen:(id<ATBaiduMobAdSplash>)splash {
    [ATLogger logMessage:@"BaiduSplash::splashSuccessPresentScreen:" type:ATLogTypeExternal];
    [self handleAssets:@{kAdAssetsCustomObjectKey:splash, kAdAssetsCustomEventKey:self, kAdAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"" }];
    [_window addSubview:_containerView];
}

- (void)splashlFailPresentScreen:(id<ATBaiduMobAdSplash>)splash withError:(NSInteger) reason {
    [ATLogger logMessage:[NSString stringWithFormat:@"BaiduSplash::splashlFailPresentScreen:%ld", reason] type:ATLogTypeExternal];
    [self.splashView removeFromSuperview];
    [self handleLoadingFailure:[NSError errorWithDomain:@"com.anythink.BaiduSplash" code:reason userInfo:@{NSLocalizedDescriptionKey:@"ATSDK has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"BaiduSDK has failed to load splash."}]];
}

- (void)splashDidClicked:(id<ATBaiduMobAdSplash>)splash {
    [ATLogger logMessage:@"BaiduSplash::splashDidClicked:" type:ATLogTypeExternal];
    [self trackClick];
    if ([self.delegate respondsToSelector:@selector(splashDidClickForPlacementID:extra:)]) { [self.delegate splashDidClickForPlacementID:self.ad.placementModel.placementID extra:[self delegateExtra]]; }
}

- (void)splashDidDismissScreen:(id<ATBaiduMobAdSplash>)splash {
    [ATLogger logMessage:@"BaiduSplash::splashDidDismissScreen:" type:ATLogTypeExternal];
    [_containerView removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(splashDidCloseForPlacementID:extra:)]) { [self.delegate splashDidCloseForPlacementID:self.ad.placementModel.placementID extra:[self delegateExtra]];
    }

}

- (void)splashDidDismissLp:(id<ATBaiduMobAdSplash>)splash {
    [ATLogger logMessage:@"BaiduSplash::splashDidDismissLp:" type:ATLogTypeExternal];
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.ad.unitGroup.content[@"unit_id"];
    return extra;
}
@end
