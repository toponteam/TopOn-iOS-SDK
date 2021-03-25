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

@protocol ATGDTMobInterstitialDelegate <NSObject>
@end
@protocol ATGDTMobInterstitial<NSObject>
@property (nonatomic, assign) BOOL isGpsOn;
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, weak) id<ATGDTMobInterstitialDelegate> delegate;
- (instancetype)initWithAppId:(NSString *)appId placementId:(NSString *)placementId;
- (void)loadAd;
- (void)presentFromRootViewController:(UIViewController *)rootViewController;
@end

@protocol GDTUnifiedInterstitialAdDelegate <NSObject>
@end
@protocol ATGDTUnifiedInterstitialAd<NSObject>
@property (nonatomic, readonly) BOOL isAdValid;
@property (nonatomic, weak) id<GDTUnifiedInterstitialAdDelegate> delegate;
@property (nonatomic, assign) BOOL videoAutoPlayOnWWAN;
@property (nonatomic, readonly) NSString *placementId;
@property (nonatomic, assign) BOOL videoMuted;
@property (nonatomic) NSInteger maxVideoDuration;
@property (nonatomic) NSInteger minVideoDuration;
@property (nonatomic, assign) BOOL detailPageVideoMuted;
@property (nonatomic, assign, readonly) BOOL isVideoAd;
- (instancetype)initWithPlacementId:(NSString *)placementId;
- (void)loadAd;
- (void)presentAdFromRootViewController:(UIViewController *)rootViewController;
- (void)loadFullScreenAd;
- (void)presentFullScreenAdFromRootViewController:(UIViewController *)rootViewController;
@end
