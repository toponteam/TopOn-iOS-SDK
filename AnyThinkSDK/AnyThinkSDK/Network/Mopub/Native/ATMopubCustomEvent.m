//
//  ATMopubCustomEvent.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 16/05/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMopubCustomEvent.h"
#import "ATNativeADCache.h"
#import "ATLogger.h"
@implementation ATMopubCustomEvent
- (UIViewController *)viewControllerForPresentingModalView {
    return [UIApplication sharedApplication].delegate.window.rootViewController;
}

- (NSString *)networkUnitId {
    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
    return cache.unitGroup.content[@"unitid"];
}

- (BOOL)sendImpressionTrackingIfNeed {
    return YES;
}

- (void)willLeaveApplicationFromNativeAd:(ATNativeADCache *)nativeAd {
    [ATLogger logMessage:@"ATMopubCustomEvent::willLeaveApplicationFromNativeAd" type:ATLogTypeInternal];
}

- (void)didDismissModalForNativeAd:(ATNativeADCache *)nativeAd {
    [ATLogger logMessage:@"ATMopubCustomEvent::didDismissModalForNativeAd" type:ATLogTypeInternal];

}

- (void)willPresentModalForNativeAd:(ATNativeADCache *)nativeAd {
    [ATLogger logMessage:@"ATMopubCustomEvent::willPresentModalForNativeAd" type:ATLogTypeInternal];

}
//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = cache.unitGroup.content[@"unitid"];
//    return extra;
//}
@end
