//
//  ATStartAppRewardedVideoCustomEvent.m
//  AnyThinkStartAppRewardedVideoAdapter
//
//  Created by Martin Lau on 2020/3/18.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATStartAppRewardedVideoCustomEvent.h"
#import "Utilities.h"
#import "ATRewardedVideoManager.h"

@interface ATStartAppRewardedVideoCustomEvent()
@property(nonatomic, readonly) BOOL closed;
@end
@implementation ATStartAppRewardedVideoCustomEvent
- (void) didLoadAd:(id<ATSTAAbstractAd>)ad {
    [ATLogger logMessage:@"StartAppRewardedVideo::didLoadAd:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoaded:ad adExtra:nil];
}

- (void) failedLoadAd:(id<ATSTAAbstractAd>)ad withError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"StartAppRewardedVideo::failedLoadAd:withError:%@", error] type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoadFailed:error != nil ? error : [NSError errorWithDomain:@"com.anythink.StartAppRewardedVideoLoading" code:100001 userInfo:@{NSLocalizedDescriptionKey:@"StartApp failed to load ad", NSLocalizedFailureReasonErrorKey:@"StartApp failed to load ad"}]];
}

- (void) didShowAd:(id<ATSTAAbstractAd>)ad {
    [ATLogger logMessage:@"StartAppRewardedVideo::didShowAd:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

- (void) failedShowAd:(id<ATSTAAbstractAd>)ad withError:(NSError *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"StartAppRewardedVideo::failedShowAd:withError:%@", error] type:ATLogTypeExternal];
    [self trackRewardedVideoAdPlayEventWithError:error];
}

- (void) didCloseAd:(id<ATSTAAbstractAd>)ad {
    [ATLogger logMessage:@"StartAppRewardedVideo::didCloseAd:" type:ATLogTypeExternal];
    if (!_closed) {
        _closed = YES;
        [self trackRewardedVideoAdCloseRewarded:self.rewardGranted];
    }
}

- (void) didClickAd:(id<ATSTAAbstractAd>)ad {
    [ATLogger logMessage:@"StartAppRewardedVideo::didClickAd:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdClick];
    //if the click leads to external browser, the close delegate method will not be called
    if (!_closed) {
        _closed = YES;
        [self trackRewardedVideoAdCloseRewarded:self.rewardGranted];
    }
}

- (void) didCloseInAppStore:(id<ATSTAAbstractAd>)ad {
    [ATLogger logMessage:@"StartAppRewardedVideo::didCloseInAppStore:" type:ATLogTypeExternal];
    if (!_closed) {
        _closed = YES;
        [self trackRewardedVideoAdCloseRewarded:self.rewardGranted];
    }
}

- (void) didCompleteVideo:(id<ATSTAAbstractAd>)ad {
    [ATLogger logMessage:@"StartAppRewardedVideo::didCompleteVideo:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdVideoEnd];
    [self trackRewardedVideoAdRewarded];
}


- (NSString *)networkUnitId {
    return self.serverInfo[@"ad_tag"];
}
@end
