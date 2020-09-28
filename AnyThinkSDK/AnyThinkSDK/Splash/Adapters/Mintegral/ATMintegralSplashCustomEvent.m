//
//  ATMintegralSplashCustomEvent.m
//  AnyThinkMintegralSplashAdapter
//
//  Created by Martin Lau on 2020/6/9.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATMintegralSplashCustomEvent.h"
#import "Utilities.h"
#import "ATSplashManager.h"
#import "ATSplashDelegate.h"

@implementation ATMintegralSplashCustomEvent
- (void)splashADPreloadSuccess:(id<ATMTGSplashAD>)splashAD {
    [ATLogger logMessage:@"MintegralSplash::splashADPreloadSuccess:" type:ATLogTypeExternal];
    if (_timeRemaining > [[NSDate date] timeIntervalSinceDate:_loadStartingDate]) {
        [self trackSplashAdLoaded:splashAD];
//        [self handleAssets:@{kAdAssetsCustomObjectKey:splashAD, kAdAssetsCustomEventKey:self, kAdAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @""}];
        [splashAD showInKeyWindow:_window customView:_containerView];
    } else {
        [self trackSplashAdLoadFailed:[NSError errorWithDomain:@"com.anythink.MintegralSplashLoading" code:0 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load splash", NSLocalizedFailureReasonErrorKey:@"It took too long for MTGSDK to load splash"}]];
    }
}

- (void)splashADPreloadFail:(id<ATMTGSplashAD>)splashAD error:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"MintegralSplash::splashADPreloadFail:error:%@", error] type:ATLogTypeExternal];
    [self trackSplashAdLoadFailed:error != nil ? error : [NSError errorWithDomain:@"com.anythink.MintegralSplashLoading" code:0 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load splash", NSLocalizedFailureReasonErrorKey:@"MTGSDK has failed to load splash"}]];
}

- (void)splashADLoadSuccess:(id<ATMTGSplashAD>)splashAD { [ATLogger logMessage:@"MintegralSplash::splashADLoadSuccess" type:ATLogTypeExternal]; }

- (void)splashADLoadFail:(id<ATMTGSplashAD>)splashAD error:(NSError *)error { [ATLogger logMessage:[NSString stringWithFormat:@"MintegralSplash::splashADLoadFail:error:%@", error] type:ATLogTypeExternal]; }

- (void)splashADShowSuccess:(id<ATMTGSplashAD>)splashAD {
    [ATLogger logMessage:@"MintegralSplash::splashADShowSuccess" type:ATLogTypeExternal];
    
    [self trackSplashAdShow];
}

- (void)splashADShowFail:(id<ATMTGSplashAD>)splashAD error:(NSError *)error { [ATLogger logMessage:[NSString stringWithFormat:@"MintegralSplash::splashADShowFail:error:%@", error] type:ATLogTypeExternal]; }

- (void)splashADDidLeaveApplication:(id<ATMTGSplashAD>)splashAD { [ATLogger logMessage:@"MintegralSplash::splashADDidLeaveApplication" type:ATLogTypeExternal]; }

- (void)splashADDidClick:(id<ATMTGSplashAD>)splashAD {
    [ATLogger logMessage:@"MintegralSplash::splashADDidClick" type:ATLogTypeExternal];
    [self trackSplashAdClick];
}

- (void)splashADWillClose:(id<ATMTGSplashAD>)splashAD { [ATLogger logMessage:@"MintegralSplash::splashADWillClose" type:ATLogTypeExternal]; }

- (void)splashADDidClose:(id<ATMTGSplashAD>)splashAD {
    [ATLogger logMessage:@"MintegralSplash::splashADDidClose" type:ATLogTypeExternal];
    [self trackSplashAdClosed];
}

- (void)splashAD:(id<ATMTGSplashAD>)splashAD timeLeft:(NSUInteger)time { [ATLogger logMessage:[NSString stringWithFormat:@"MintegralSplash::splashAD:timeLeft:%ld", time] type:ATLogTypeExternal]; }

- (NSString *)networkUnitId {
    return self.serverInfo[@"unitid"];
}

//-(NSDictionary*)delesgateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.ad.unitGroup.content[kNetworkUnitIdKey];
//    return extra;
//}
@end
