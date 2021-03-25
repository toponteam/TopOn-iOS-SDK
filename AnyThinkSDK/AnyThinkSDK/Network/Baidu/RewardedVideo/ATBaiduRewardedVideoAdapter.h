//
//  ATBaiduRewardedVideoAdapter.h
//  AnyThinkBaiduRewardedVideoAdapter
//
//  Created by Martin Lau on 2018/11/30.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ATBaiduRewardedVideoAdapter : NSObject
@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);
@end

@protocol BaiduMobAdRewardVideoDelegate;
@protocol ATBaiduMobAdRewardVideo<NSObject>
@property (nonatomic, weak) id <BaiduMobAdRewardVideoDelegate> delegate;
@property (nonatomic, copy) NSString *publisherId;
@property (nonatomic, copy) NSString *AdUnitTag;
@property (nonatomic, assign) BOOL enableLocation;
- (void)load;
- (BOOL)isReady;
- (void)show;
- (void)showFromViewController:(UIViewController *)controller;
@end

@protocol BaiduMobAdRewardVideoDelegate <NSObject>
@optional
- (void)rewardedAdLoadSuccess:(id<ATBaiduMobAdRewardVideo>)video;
- (void)rewardedVideoAdLoaded:(id<ATBaiduMobAdRewardVideo>)video;
- (void)rewardedVideoAdLoadFailed:(id<ATBaiduMobAdRewardVideo>)video withError:(NSInteger)reason;
- (void)rewardedVideoAdDidStarted:(id<ATBaiduMobAdRewardVideo>)video;
- (void)rewardedVideoAdShowFailed:(id<ATBaiduMobAdRewardVideo>)video withError:(NSInteger)reason;
- (void)rewardedVideoAdDidPlayFinish:(id<ATBaiduMobAdRewardVideo>)video;
- (void)rewardedVideoAdDidClose:(id<ATBaiduMobAdRewardVideo>)video withPlayingProgress:(CGFloat)progress;
- (void)rewardedVideoAdDidClick:(id<ATBaiduMobAdRewardVideo>)video withPlayingProgress:(CGFloat)progress;
@end

