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
    [_window addSubview:_containerView];
    [self trackSplashAdShow];
}

- (void)splashlFailPresentScreen:(id<ATBaiduMobAdSplash>)splash withError:(NSInteger) reason {
    [ATLogger logMessage:[NSString stringWithFormat:@"BaiduSplash::splashlFailPresentScreen:%ld", reason] type:ATLogTypeExternal];
    [_splashView removeFromSuperview];
    [self trackSplashAdLoadFailed:[NSError errorWithDomain:@"com.anythink.BaiduSplash" code:reason userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadSplashADMsg, NSLocalizedFailureReasonErrorKey:@"BaiduSDK has failed to load splash."}]];
}

- (void)splashDidClicked:(id<ATBaiduMobAdSplash>)splash {
    [ATLogger logMessage:@"BaiduSplash::splashDidClicked:" type:ATLogTypeExternal];
    [self trackSplashAdClick];
}

- (void)splashDidDismissScreen:(id<ATBaiduMobAdSplash>)splash {
    [ATLogger logMessage:@"BaiduSplash::splashDidDismissScreen:" type:ATLogTypeExternal];
    [_containerView removeFromSuperview];
    [_splashView removeFromSuperview];
    [self trackSplashAdClosed];
}

- (void)splashDidDismissLp:(id<ATBaiduMobAdSplash>)splash {
    [ATLogger logMessage:@"BaiduSplash::splashDidDismissLp:" type:ATLogTypeExternal];
}

- (void)splashDidReady:(id<ATBaiduMobAdSplash>)splash AndAdType:(NSString *)adType VideoDuration:(NSInteger)videoDuration {
    
}

- (void)splashAdLoadFail:(id<ATBaiduMobAdSplash>)splash {
    [ATLogger logMessage:@"BaiduSplash::splashAdLoadFail:" type:ATLogTypeExternal];

    NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:1 userInfo:nil];
    [self trackSplashAdLoadFailed:error];
}

- (void)splashAdLoadSuccess:(id<ATBaiduMobAdSplash>)splash {
    [ATLogger logMessage:@"BaiduSplash::splashAdLoadSuccess:" type:ATLogTypeExternal];
    [self trackSplashAdLoaded:splash adExtra:nil];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"ad_place_id"];
}

@end
