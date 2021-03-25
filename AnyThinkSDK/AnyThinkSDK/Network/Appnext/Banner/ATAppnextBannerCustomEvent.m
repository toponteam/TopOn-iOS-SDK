//
//  ATAppnextBannerCustomEvent.m
//  AnyThinkAppnextBannerAdapter
//
//  Created by Martin Lau on 2018/10/15.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAppnextBannerCustomEvent.h"
#import "Utilities.h"
#import "ATBannerManager.h"

@implementation ATAppnextBannerCustomEvent
- (void) onAppnextBannerLoadedSuccessfully {
    [ATLogger logMessage:@"AppnextBanner::onAppnextBannerLoadedSuccessfully" type:ATLogTypeExternal];

    [self trackBannerAdLoaded:_anBannerView adExtra:nil];
}

- (void) onAppnextBannerError:(NSInteger) error {
    [ATLogger logMessage:[NSString stringWithFormat:@"AppnextBanner::onAppnextBannerError:%ld", error] type:ATLogTypeExternal];
    [self trackBannerAdLoadFailed:[NSError errorWithDomain:@"com.anythink.AppnextBanner" code:error userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadBannerADMsg, NSLocalizedFailureReasonErrorKey:@"Appnext has failed to load banner."}]];
}

- (void) onAppnextBannerClicked {
    [ATLogger logMessage:@"AppnextBanner::onAppnextBannerClicked" type:ATLogTypeExternal];
    [self trackBannerAdClick];
}

- (void) onAppnextBannerImpressionReported {
    [ATLogger logMessage:@"AppnextBanner::onAppnextBannerImpressionReported" type:ATLogTypeExternal];
    [self trackBannerAdImpression];
}

/// This is an override method, for more detailsplease refer to ATBannerCustomEvent.h
- (BOOL)sendImpressionTrackingIfNeed {
    return YES;
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
