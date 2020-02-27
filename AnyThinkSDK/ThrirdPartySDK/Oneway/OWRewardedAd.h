//
//  OWRewardedAd.h
//  OneWaySDK
//
//  Created by lch on 2017/11/30.
//  Copyright © 2017年 mobi.oneway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWAdsBase.h"

@protocol oneWaySDKRewardedAdDelegate <NSObject>

- (void)oneWaySDKRewardedAdReady;

- (void)oneWaySDKRewardedAdDidShow:(NSString *)tag;

- (void)oneWaySDKRewardedAdDidClose:(NSString *)tag withState:(NSNumber *)state;

- (void)oneWaySDKRewardedAdDidClick:(NSString *)tag;

- (void)oneWaySDKDidError:(OneWaySDKError)error withMessage:(NSString *)message;

@end


@interface OWRewardedAd : OWAdsBase

+ (void)show:(UIViewController *)viewController adType:(OneWaySDKAdType)adType fullScreen:(BOOL)isFullScreen tag:(NSString *)tag NS_UNAVAILABLE;
+ (void)initWithDelegate:(id)delegate type:(OneWaySDKAdType)type NS_UNAVAILABLE;
+ (BOOL)isReady:(OneWaySDKAdType)adType NS_UNAVAILABLE;

/**
 初始化广告位
 
 @param delegate 接收广告回调的代理
 */
+ (void)initWithDelegate:(id<oneWaySDKRewardedAdDelegate>)delegate;

/**
 用于判断广告是否已经准备好
 
 @return 广告是否已经准备好
 */
+ (BOOL)isReady;

/**
 使用默认的配置播放广告
 
 @param viewController 需要展示广告的的viewController.
 */
+ (void)show:(UIViewController *)viewController;

/**
 自定义show接口,用于配置相关自定义参数.
 
 @param viewController 需要展示广告的的viewController.
 @param isFullScreen 广告是否全屏样式.
 @param tag 自定义tag,回调时传给开发者,用于优化广告点击.
 */
+ (void)show:(UIViewController *)viewController tag:(NSString *)tag;
@end
