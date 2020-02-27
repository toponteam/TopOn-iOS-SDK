//
//  ATGDTInterstitialAdapter.h
//  AnyThinkGDTInterstitialAdapter
//
//  Created by Martin Lau on 21/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ATGDTMediaPlayerStatus) {
    GDTMediaPlayerStatusInitial = 0,         // 初始状态
    GDTMediaPlayerStatusLoading = 1,         // 加载中
    GDTMediaPlayerStatusStarted = 2,         // 开始播放
    GDTMediaPlayerStatusPaused = 3,          // 用户行为导致暂停
    GDTMediaPlayerStatusStoped = 4,          // 播放停止
    GDTMediaPlayerStatusError = 5,           // 播放出错
};

@interface ATGDTInterstitialAdapter : NSObject

@end

@protocol ATGDTSDKConfig<NSObject>
+ (NSString *)sdkVersion;
@end


@protocol ATGDTMobInterstitial;

@protocol ATGDTMobInterstitialDelegate <NSObject>
@optional
- (void)interstitialSuccessToLoadAd:(id<ATGDTMobInterstitial>)interstitial;
- (void)interstitialFailToLoadAd:(id<ATGDTMobInterstitial>)interstitial error:(NSError *)error;
- (void)interstitialWillPresentScreen:(id<ATGDTMobInterstitial>)interstitial;
- (void)interstitialDidPresentScreen:(id<ATGDTMobInterstitial>)interstitial;
- (void)interstitialDidDismissScreen:(id<ATGDTMobInterstitial>)interstitial;
- (void)interstitialApplicationWillEnterBackground:(id<ATGDTMobInterstitial>)interstitial;
- (void)interstitialWillExposure:(id<ATGDTMobInterstitial>)interstitial;
- (void)interstitialClicked:(id<ATGDTMobInterstitial>)interstitial;
- (void)interstitialAdWillPresentFullScreenModal:(id<ATGDTMobInterstitial>)interstitial;
- (void)interstitialAdDidPresentFullScreenModal:(id<ATGDTMobInterstitial>)interstitial;
- (void)interstitialAdWillDismissFullScreenModal:(id<ATGDTMobInterstitial>)interstitial;
- (void)interstitialAdDidDismissFullScreenModal:(id<ATGDTMobInterstitial>)interstitial;
@end

@protocol ATGDTMobInterstitial<NSObject>
@property (nonatomic, assign) BOOL isGpsOn;
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, weak) id<ATGDTMobInterstitialDelegate> delegate;
- (instancetype)initWithAppId:(NSString *)appId placementId:(NSString *)placementId;
- (void)loadAd;
- (void)presentFromRootViewController:(UIViewController *)rootViewController;
@end

@protocol ATGDTUnifiedInterstitialAd;
@protocol GDTUnifiedInterstitialAdDelegate <NSObject>
@optional
- (void)unifiedInterstitialSuccessToLoadAd:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial;
- (void)unifiedInterstitialFailToLoadAd:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial error:(NSError *)error;
- (void)unifiedInterstitialWillPresentScreen:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial;
- (void)unifiedInterstitialDidPresentScreen:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial;
- (void)unifiedInterstitialDidDismissScreen:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial;
- (void)unifiedInterstitialWillLeaveApplication:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial;
- (void)unifiedInterstitialWillExposure:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial;
- (void)unifiedInterstitialClicked:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial;
- (void)unifiedInterstitialAdWillPresentFullScreenModal:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial;
- (void)unifiedInterstitialAdDidPresentFullScreenModal:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial;
- (void)unifiedInterstitialAdWillDismissFullScreenModal:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial;
- (void)unifiedInterstitialAdDidDismissFullScreenModal:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial;
//视频
- (void)unifiedInterstitialAd:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial playerStatusChanged:(ATGDTMediaPlayerStatus)status;
- (void)unifiedInterstitialAdViewWillPresentVideoVC:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial;
- (void)unifiedInterstitialAdViewDidPresentVideoVC:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial;
- (void)unifiedInterstitialAdViewWillDismissVideoVC:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial;
- (void)unifiedInterstitialAdViewDidDismissVideoVC:(id<ATGDTUnifiedInterstitialAd>)unifiedInterstitial;

@end

@protocol ATGDTUnifiedInterstitialAd<NSObject>
@property (nonatomic, readonly) BOOL isAdValid;
@property (nonatomic, weak) id<GDTUnifiedInterstitialAdDelegate> delegate;
@property (nonatomic, assign) BOOL videoAutoPlayOnWWAN;
@property (nonatomic, assign) BOOL videoMuted;
@property (nonatomic) NSInteger maxVideoDuration;
- (instancetype)initWithAppId:(NSString *)appId placementId:(NSString *)placementId;
- (void)loadAd;
- (void)presentAdFromRootViewController:(UIViewController *)rootViewController;
@end
