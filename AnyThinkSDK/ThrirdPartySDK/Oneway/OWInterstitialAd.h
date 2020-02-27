//
//  OWIntestitialAd.h
//  OneWaySDK
//
//  Created by lch on 2017/11/30.
//  Copyright © 2017年 mobi.oneway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWAdsBase.h"
@protocol oneWaySDKInterstitialAdDelegate <NSObject>

- (void)oneWaySDKInterstitialAdReady;

- (void)oneWaySDKInterstitialAdDidShow:(NSString *)tag;

- (void)oneWaySDKInterstitialAdDidClose:(NSString *)tag withState:(NSNumber *)state;

- (void)oneWaySDKInterstitialAdDidClick:(NSString *)tag;

- (void)oneWaySDKDidError:(OneWaySDKError)error withMessage:(NSString *)message;

@end

@interface OWInterstitialAd : OWAdsBase
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)initialize NS_UNAVAILABLE;
+ (void)initWithDelegate:(id)delegate type:(OneWaySDKAdType)type NS_UNAVAILABLE;
+ (void)show:(UIViewController *)viewController adType:(OneWaySDKAdType)adType fullScreen:(BOOL)isFullScreen tag:(NSString *)tag NS_UNAVAILABLE;
+ (BOOL)isReady:(OneWaySDKAdType)adType NS_UNAVAILABLE;
/**
 初始化广告位
 
 @param delegate 接收广告回调的代理
 */
+ (void)initWithDelegate:(id<oneWaySDKInterstitialAdDelegate>)delegate;

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
