//
//  ATBaiduInterstitialAdapter.h
//  AnyThinkBaiduInterstitialAdapter
//
//  Created by Martin Lau on 2018/11/30.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ATBaiduInterstitialAdapter : NSObject
@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);
@end

typedef enum {
    BaiduMobAdTypeFeed = 0, // 默认 请求普通信息流广告
    BaiduMobAdTypePortrait = 1,  // 竖版小视频广告
    BaiduMobAdTypeRewardVideo = 2,  // 激励视频
    BaiduMobAdTypeFullScreenVideo = 3   // 全屏视频
} ATBaiduMobAdType;

/**
 *  广告展示失败类型枚举
 */
typedef enum _BaiduMobFailReason {
    BaiduMobFailReason_NOAD = 0,// 没有推广返回
    BaiduMobFailReason_EXCEPTION,//网络或其它异常
    BaiduMobFailReason_FRAME//广告尺寸或元素异常，不显示广告
} ATBaiduMobFailReason;

typedef enum _BaiduMobAdInterstitialType {
    BaiduMobAdViewTypeInterstitialOther = 5,
    BaiduMobAdViewTypeInterstitialBeforeVideo = 7,
    BaiduMobAdViewTypeInterstitialPauseVideo = 8
    
} BaiduMobAdInterstitialType;

@protocol BaiduMobAdInterstitialDelegate;
@protocol ATBaiduMobAdInterstitial<NSObject>
@property (nonatomic ,assign) id<BaiduMobAdInterstitialDelegate> delegate;
@property (nonatomic) BaiduMobAdInterstitialType interstitialType;
@property (nonatomic) BOOL isReady;
@property (nonatomic,copy) NSString* AdUnitTag;
@property (nonatomic, readonly) NSString* Version;
- (void)loadAndDisplayUsingKeyWindow:(UIWindow *)keyWindow;
- (void)load;
- (void)presentFromRootViewController:(UIViewController *)rootViewController;
- (void)loadUsingSize:(CGRect)rect;
- (void)presentFromView:(UIView *)view;
@end

@protocol BaiduMobAdInterstitialDelegate <NSObject>
@required
- (NSString *)publisherId;
@optional
- (NSString *)channelId;
- (BOOL) enableLocation;
- (void)interstitialSuccessToLoadAd:(id<ATBaiduMobAdInterstitial>)interstitial;
- (void)interstitialFailToLoadAd:(id<ATBaiduMobAdInterstitial>)interstitial;
- (void)interstitialWillPresentScreen:(id<ATBaiduMobAdInterstitial>)interstitial;
- (void)interstitialSuccessPresentScreen:(id<ATBaiduMobAdInterstitial>)interstitial;
- (void)interstitialFailPresentScreen:(id<ATBaiduMobAdInterstitial>)interstitial withError:(NSInteger) reason;
- (void)interstitialDidAdClicked:(id<ATBaiduMobAdInterstitial>)interstitial;
- (void)interstitialDidDismissScreen:(id<ATBaiduMobAdInterstitial>)interstitial;
- (void)interstitialDidDismissLandingPage:(id<ATBaiduMobAdInterstitial>)interstitial;
@end

@protocol BaiduMobAdExpressFullScreenVideoDelegate;
@protocol ATBaiduMobAdExpressFullScreenVideo <NSObject>
@property (nonatomic, weak) id <BaiduMobAdExpressFullScreenVideoDelegate> delegate;
@property (nonatomic, copy) NSString *publisherId;
@property (nonatomic, copy) NSString *AdUnitTag;
@property (nonatomic, assign) BOOL enableLocation;
@property (nonatomic, assign) ATBaiduMobAdType adType;
- (void)load;
- (BOOL)isReady;
- (void)show;
- (void)showFromViewController:(UIViewController *)controller;
@end


@protocol BaiduMobAdExpressFullScreenVideoDelegate <NSObject>
@optional
- (void)fullScreenVideoAdLoadSuccess:(id<ATBaiduMobAdExpressFullScreenVideo>)video;
- (void)fullScreenVideoAdLoadFail:(id<ATBaiduMobAdExpressFullScreenVideo>)video;
- (void)fullScreenVideoAdLoaded:(id<ATBaiduMobAdExpressFullScreenVideo>)video;
- (void)fullScreenVideoAdLoadFailed:(id<ATBaiduMobAdExpressFullScreenVideo>)video withError:(ATBaiduMobFailReason)reason;
- (void)fullScreenVideoAdDidStarted:(id<ATBaiduMobAdExpressFullScreenVideo>)video;
- (void)fullScreenVideoAdShowFailed:(id<ATBaiduMobAdExpressFullScreenVideo>)video withError:(ATBaiduMobFailReason)reason;
- (void)fullScreenVideoAdDidPlayFinish:(id<ATBaiduMobAdExpressFullScreenVideo>)video;
- (void)fullScreenVideoAdDidClose:(id<ATBaiduMobAdExpressFullScreenVideo>)video withPlayingProgress:(CGFloat)progress;
- (void)fullScreenVideoAdDidSkip:(id<ATBaiduMobAdExpressFullScreenVideo>)video withPlayingProgress:(CGFloat)progress;
- (void)fullScreenVideoAdDidClick:(id<ATBaiduMobAdExpressFullScreenVideo>)video withPlayingProgress:(CGFloat)progress;
@end
