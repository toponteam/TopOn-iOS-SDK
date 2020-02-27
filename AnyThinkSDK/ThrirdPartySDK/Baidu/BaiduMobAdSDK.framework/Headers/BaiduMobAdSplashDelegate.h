//
//  BaiduMobAdSplashDelegate.h
//  BaiduMobAdSDK
//
//  Created by LiYan on 16/5/25.
//  Copyright © 2016年 Baidu Inc. All rights reserved.
//

#import "BaiduMobAdCommonConfig.h"
#import <Foundation/Foundation.h>

@class BaiduMobAdSplash;

@protocol BaiduMobAdSplashDelegate <NSObject>

@required
/**
 *  应用的APPID
 */
- (NSString *)publisherId;

@optional

/**
 *  渠道id
 */
- (NSString *)channelId;

/**
 *  启动位置信息
 */
- (BOOL)enableLocation;


/**
 *  广告展示成功
 */
- (void)splashSuccessPresentScreen:(BaiduMobAdSplash *)splash;

/**
 *  广告展示失败
 */
- (void)splashlFailPresentScreen:(BaiduMobAdSplash *)splash withError:(BaiduMobFailReason) reason;

/**
 *  广告被点击
 */
- (void)splashDidClicked:(BaiduMobAdSplash *)splash;

/**
 *  广告展示结束
 */
- (void)splashDidDismissScreen:(BaiduMobAdSplash *)splash;

/**
 *  广告详情页消失
 */
- (void)splashDidDismissLp:(BaiduMobAdSplash *)splash;

/**
 *  广告加载完成
 *  adType:广告类型 BaiduMobMaterialType
 *  videoDuration:视频时长，仅广告为视频时出现。非视频类广告默认0。 单位ms
 */
- (void)splashDidReady:(BaiduMobAdSplash *)splash
             AndAdType:(NSString *)adType
         VideoDuration:(NSInteger)videoDuration;

/**
 * 开屏广告请求成功
 *
 * @param splash 开屏广告对象
 */
- (void)splashAdLoadSuccess:(BaiduMobAdSplash *)splash;

/**
 * 开屏广告请求失败
 *
 * @param splash 开屏广告对象
 */
- (void)splashAdLoadFail:(BaiduMobAdSplash *)splash;

@end
