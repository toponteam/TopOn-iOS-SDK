//
//  ATAppnextRewardedVideoCustomEvent.m
//  AnyThinkAppnextRewardedVideoAdapter
//
//  Created by Martin Lau on 2018/10/17.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAppnextRewardedVideoCustomEvent.h"
#import "Utilities.h"
#import "ATRewardedVideoManager.h"

@interface ATAppnextRewardedVideoCustomEvent()
@property(nonatomic, readonly) BOOL rewarded;
@end
@implementation ATAppnextRewardedVideoCustomEvent
- (void) adLoaded:(id<ATAppnextAd>)ad {
    [ATLogger logMessage:@"AppnextRewardedVideo::adLoaded:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdLoaded:ad adExtra:nil];
}

- (void) adOpened:(id<ATAppnextAd>)ad {
    [ATLogger logMessage:@"AppnextRewardedVideo::adOpened:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

- (void) adClosed:(id<ATAppnextAd>)ad {
    [ATLogger logMessage:@"AppnextRewardedVideo::adClosed:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdCloseRewarded:_rewarded];
}

- (void) adClicked:(id<ATAppnextAd>)ad {
    [ATLogger logMessage:@"AppnextRewardedVideo::adClicked:" type:ATLogTypeExternal];
    [self trackRewardedVideoAdClick];
}

- (void) adUserWillLeaveApplication:(id<ATAppnextAd>)ad {
    [ATLogger logMessage:@"AppnextRewardedVideo::adUserWillLeaveApplication:" type:ATLogTypeExternal];
}

- (void) adError:(id<ATAppnextAd>)ad error:(NSString *)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"AppnextRewardedVideo::adError:error:%@", error] type:ATLogTypeExternal];
    NSError *errorObj = [NSError errorWithDomain:@"com.anythink.AppNextRewardedVideoLoading" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load rewarded video ad.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"%@", error]}];
    [self trackRewardedVideoAdLoadFailed:errorObj];
}

- (void) videoEnded:(id<ATAppnextAd>)ad {
    [ATLogger logMessage:@"AppnextRewardedVideo::videoEnded:" type:ATLogTypeExternal];
    _rewarded = YES;
    [self trackRewardedVideoAdVideoEnd];
    [self trackRewardedVideoAdRewarded];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"placement_id"];
}

//-(NSDictionary*)delegateExtra {
//    NSMutableDictionary* extra = [[super delegateExtra] mutableCopy];
//    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.rewardedVideo.unitGroup.content[@"placement_id"];
//    return extra;
//}
@end
