//
//  ATMopubCustomEvent.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 16/05/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMopubCustomEvent.h"
#import "ATNativeADCache.h"

@implementation ATMopubCustomEvent
- (UIViewController *)viewControllerForPresentingModalView {
    return [UIApplication sharedApplication].delegate.window.rootViewController;
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
    ATNativeADCache *cache = (ATNativeADCache*)self.adView.nativeAd;
    extra[kATADDelegateExtraNetworkPlacementIDKey] = cache.unitGroup.content[@"unitid"];
    return extra;
}
@end
