//
//  ATStartAppInterstitialCustomEvent.m
//  AnyThinkStartAppInterstitialAdapter
//
//  Created by Martin Lau on 2020/3/19.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATStartAppInterstitialCustomEvent.h"
#import "ATInterstitialManager.h"
#import "Utilities.h"

@interface ATStartAppInterstitialCustomEvent()
@property(nonatomic, readonly) BOOL closed;
@end
@implementation ATStartAppInterstitialCustomEvent
- (void) didLoadAd:(id<ATSTAAbstractAd>)ad {
    [ATLogger logMessage:@"StartAppInterstitial::didLoadAd:" type:ATLogTypeExternal];
    [self trackInterstitialAdLoaded:ad adExtra:nil];
}

- (void) failedLoadAd:(id<ATSTAAbstractAd>)ad withError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"StartAppInterstitial::failedLoadAd:withError:%@", error] type:ATLogTypeExternal];
    [self trackInterstitialAdLoadFailed:error != nil ? error : [NSError errorWithDomain:@"com.anythink.StartAppInterstitialLoading" code:100001 userInfo:@{NSLocalizedDescriptionKey:@"StartApp failed to load ad", NSLocalizedFailureReasonErrorKey:@"StartApp failed to load ad"}]];
}

- (void) didShowAd:(id<ATSTAAbstractAd>)ad {
    [ATLogger logMessage:@"StartAppInterstitial::didShowAd:" type:ATLogTypeExternal];
    [self trackInterstitialAdShow];
    if ([self.interstitial.unitGroup.content[@"is_video"] boolValue]) {
        [self trackInterstitialAdVideoStart];
    }
}

- (void) failedShowAd:(id<ATSTAAbstractAd>)ad withError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"StartAppInterstitial::failedShowAd:withError:%@", error] type:ATLogTypeExternal];
    [self trackInterstitialAdDidFailToPlayVideo:error];
}

- (void) didCloseAd:(id<ATSTAAbstractAd>)ad {
    [ATLogger logMessage:@"StartAppInterstitial::didCloseAd:" type:ATLogTypeExternal];
    if (!_closed) {
        _closed = YES;
        [self trackInterstitialAdClose];
    }
}

- (void) didClickAd:(id<ATSTAAbstractAd>)ad {
    [ATLogger logMessage:@"StartAppInterstitial::didClickAd:" type:ATLogTypeExternal];
    [self trackInterstitialAdClick];
    //if the click leads to external browser, the close delegate method will not be called
    if (!_closed) {
        _closed = YES;
        [self trackInterstitialAdClose];
    }
}

- (void) didCloseInAppStore:(id<ATSTAAbstractAd>)ad {
    [ATLogger logMessage:@"StartAppInterstitial::didCloseInAppStore:" type:ATLogTypeExternal];
    if (!_closed) {
        _closed = YES;
        [self trackInterstitialAdClose];
    }
}

- (void) didCompleteVideo:(id<ATSTAAbstractAd>)ad {
    [ATLogger logMessage:@"StartAppInterstitial::didCompleteVideo:" type:ATLogTypeExternal];
    [self trackInterstitialAdVideoEnd];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"ad_tag"];
}

@end
