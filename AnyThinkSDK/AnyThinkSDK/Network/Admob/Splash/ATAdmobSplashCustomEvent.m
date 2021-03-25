//
//  ATAdmobSplashCustomEvent.m
//  AnyThinkAdmobSplashAdapter
//
//  Created by Topon on 9/30/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATAdmobSplashCustomEvent.h"
#import "Utilities.h"

@implementation ATAdmobSplashCustomEvent

#pragma mark - GADFullScreenContentDelegate
- (void)ad:(nonnull id<ATGADFullScreenPresentingAd>)ad
    didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"AdmobSplash::ad:didFailToPresentFullScreenContentWithError:%@",error] type:ATLogTypeExternal];
}

- (void)adDidPresentFullScreenContent:(nonnull id<ATGADFullScreenPresentingAd>)ad {
    [ATLogger logMessage:@"AdmobSplash::adDidPresentFullScreenContent" type:ATLogTypeExternal];
}

- (void)adDidDismissFullScreenContent:(nonnull id<ATGADFullScreenPresentingAd>)ad {
    [ATLogger logMessage:@"AdmobSplash::adDidDismissFullScreenContent" type:ATLogTypeExternal];
    [self trackSplashAdClosed];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"unit_id"];
}

@end
