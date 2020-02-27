//
//  BaiduMobAdRewardVideoDelegate.h
//  BaiduMobAdSDK
//
//  Created by Yang,Dingjia on 2018/7/3.
//  Copyright © 2018年 Baidu Inc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "BaiduMobAdCommonConfig.h"

@class BaiduMobAdRewardVideo;

@protocol BaiduMobAdRewardVideoDelegate <NSObject>

@optional
#pragma mark - 广告请求delegate
/**
 * 激励视频广告请求成功
 */
- (void)rewardedAdLoadSuccess:(BaiduMobAdRewardVideo *)video;

/**
 * 激励视频广告请求失败
 */
- (void)rewardedAdLoadFail:(BaiduMobAdRewardVideo *)video;

#pragma mark - 视频缓存delegate
/**
 *  视频缓存成功
 */
- (void)rewardedVideoAdLoaded:(BaiduMobAdRewardVideo *)video;

/**
 *  视频缓存失败
 */
- (void)rewardedVideoAdLoadFailed:(BaiduMobAdRewardVideo *)video withError:(BaiduMobFailReason)reason;

#pragma mark - 视频播放delegate

/**
 *  视频开始播放
 */
- (void)rewardedVideoAdDidStarted:(BaiduMobAdRewardVideo *)video;

/**
 *  广告展示失败
 */
- (void)rewardedVideoAdShowFailed:(BaiduMobAdRewardVideo *)video withError:(BaiduMobFailReason)reason;

/**
 *  广告完成播放
 */
- (void)rewardedVideoAdDidPlayFinish:(BaiduMobAdRewardVideo *)video;

/**
 *  用户点击关闭
 @param progress 当前播放进度 单位百分比 （注意浮点数）
 */
- (void)rewardedVideoAdDidClose:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress;

/**
 *  用户点击下载/查看详情
 @param progress 当前播放进度 单位百分比
 */
- (void)rewardedVideoAdDidClick:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress;

@end

