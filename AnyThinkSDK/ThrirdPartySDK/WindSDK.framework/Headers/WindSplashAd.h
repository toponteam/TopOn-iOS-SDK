//
//  WindSplashAd.h
//  WindSDK
//
//  Created by happyelements on 2018/7/30.
//  Copyright © 2018 Codi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class WindSplashAd;


@protocol WindSplashAdDelegate <NSObject>

@optional
/**
 *  开屏广告成功展示
 */
-(void)onSplashAdSuccessPresentScreen:(WindSplashAd *)splashAd;

/**
 *  开屏广告展示失败
 */
-(void)onSplashAdFailToPresent:(WindSplashAd *)splashAd withError:(NSError *)error;


/**
 *  开屏广告点击回调
 */
- (void)onSplashAdClicked:(WindSplashAd *)splashAd;

/**
 *  开屏广告将要关闭回调
 */
- (void)onSplashAdWillClosed:(WindSplashAd *)splashAd;

/**
 *  开屏广告关闭回调
 */
- (void)onSplashAdClosed:(WindSplashAd *)splashAd;

@end

@interface WindSplashAd : NSObject

@property (nonatomic,weak) id<WindSplashAdDelegate> delegate;

/**
 *  拉取广告超时时间，默认为3秒
 *  详解：拉取广告超时时间，开发者调用loadAd方法以后会立即展示app的启动图，然后在该超时时间内，如果广告拉
 *  取成功，则立马展示开屏广告，否则放弃此次广告展示机会。
 */
@property (nonatomic, assign) int fetchDelay;


/**
 *  开屏广告的背景色
 *  可以设置开屏图片来作为开屏加载时的默认图片
 */
@property (nonatomic, copy) UIColor *backgroundColor;




- (instancetype)initWithPlacementId:(NSString *)placementId;

@property (nonatomic,strong, readonly) NSString *placementId;

@property (nonatomic,strong) NSString *userId;



/**
 *  广告发起请求并展示在Window中
 *  详解：[可选]发起拉取广告请求,并将获取的广告以全屏形式展示在传入的Window参数中
 */
-(void)loadAdAndShow;


/**
 *  广告发起请求并展示在Window中, 同时在屏幕底部设置应用自身的Logo页面或是自定义View
 *  详解：[可选]发起拉取广告请求,并将获取的广告以半屏形式展示在传入的Window的上半部，剩余部分展示传入的bottomView
 *       请注意bottomView需设置好宽高，所占的空间不能过大，并保证广告界面的高度大于360
 *  @param bottomView 自定义底部View，可以在此View中设置应用Logo
 *
 */
-(void)loadAdAndShowWithBottomView:(UIView *)bottomView;



/**
 *  广告发起请求并展示在Window中, 同时在屏幕底部设置应用自身的Logo页面
 *  详解：[logo会自动读取应用图标]
 *
 @param title 设置标题
 @param description 设置描述信息
 */
- (void)loadADAndShowWithTitle:(NSString *)title description:(NSString *)description;

@end
