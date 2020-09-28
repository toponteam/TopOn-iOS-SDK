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

-(instancetype)initWithPublisherID:(NSString*)publisherID unitID:(NSString *)unitID serverInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    self = [super initWithInfo:serverInfo localInfo:localInfo];
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
     [self trackSplashAdLoaded:splash];
//    [self handleAssets:@{kAdAssetsCustomObjectKey:splash, kAdAssetsCustomEventKey:self, kAdAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"" }];
    [_window addSubview:_containerView];
//    if (self.ad == nil) { if ([self.delegate respondsToSelector:@selector(splashDidShowForPlacementID:extra:)]) { [self.delegate splashDidShowForPlacementID:self.unitID extra:[self delegateExtra]]; } }
    [self trackSplashAdShow];
}

- (void)splashlFailPresentScreen:(id<ATBaiduMobAdSplash>)splash withError:(NSInteger) reason {
    [ATLogger logMessage:[NSString stringWithFormat:@"BaiduSplash::splashlFailPresentScreen:%ld", reason] type:ATLogTypeExternal];
    [self.splashView removeFromSuperview];
    [self trackSplashAdLoadFailed:[NSError errorWithDomain:@"com.anythink.BaiduSplash" code:reason userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadSplashADMsg, NSLocalizedFailureReasonErrorKey:@"BaiduSDK has failed to load splash."}]];
}

- (void)splashDidClicked:(id<ATBaiduMobAdSplash>)splash {
    [ATLogger logMessage:@"BaiduSplash::splashDidClicked:" type:ATLogTypeExternal];
    [self trackSplashAdClick];
}

- (void)splashDidDismissScreen:(id<ATBaiduMobAdSplash>)splash {
    [ATLogger logMessage:@"BaiduSplash::splashDidDismissScreen:" type:ATLogTypeExternal];
    [_containerView removeFromSuperview];
    [self trackSplashAdClosed];
}

- (void)splashDidDismissLp:(id<ATBaiduMobAdSplash>)splash {
    [ATLogger logMessage:@"BaiduSplash::splashDidDismissLp:" type:ATLogTypeExternal];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"ad_place_id"];
}
//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.ad.unitGroup.content[@"ad_place_id"];
//    return extra;
//}
@end
