//
//  ATSigmobSplashCustomEvent.m
//  AnyThinkSigmobSplashAdapter
//
//  Created by Martin Lau on 2019/9/9.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATSigmobSplashCustomEvent.h"
#import "Utilities.h"
#import "ATSplashManager.h"
#import "ATSplashDelegate.h"

@implementation ATSigmobSplashCustomEvent
- (void)onSplashAdSuccessPresentScreen:(id<ATWindSplashAd>)splashAd {
    [ATLogger logMessage:@"SigmobSplash::onSplashAdSuccessPresentScreen:" type:ATLogTypeExternal];
    [self trackSplashAdShow];
}

- (void)onSplashAdDidLoad:(id<ATWindSplashAd>)splashAd {
    [ATLogger logMessage:@"SigmobSplash::onSplashAdDidLoad:" type:ATLogTypeExternal];
    [self trackSplashAdLoaded:splashAd adExtra:nil];
}

- (void)onSplashAdFailToPresent:(id<ATWindSplashAd>)splashAd withError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"SigmobSplash::onSplashAdFailToPresent:withError:%@", error] type:ATLogTypeExternal];
    [self trackSplashAdLoadFailed:error != nil ? error : [NSError errorWithDomain:@"com.anythink.SigmobSplashLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load splash", NSLocalizedFailureReasonErrorKey:@"Sigmob has failed to load splash"}]];
}

- (void)onSplashAdClicked:(id<ATWindSplashAd>)splashAd {
    [ATLogger logMessage:@"SigmobSplash::onSplashAdClicked:" type:ATLogTypeExternal];
    [self trackSplashAdClick];
}

- (void)onSplashAdWillClosed:(id<ATWindSplashAd>)splashAd {
    [ATLogger logMessage:@"SigmobSplash::onSplashAdWillClosed:" type:ATLogTypeExternal];
}

- (void)onSplashAdClosed:(id<ATWindSplashAd>)splashAd {
    [ATLogger logMessage:@"SigmobSplash::onSplashAdClosed:" type:ATLogTypeExternal];
    [self trackSplashAdClosed];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"placement_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.ad.unitGroup.content[@"placement_id"];
//    return extra;
//}
@end
