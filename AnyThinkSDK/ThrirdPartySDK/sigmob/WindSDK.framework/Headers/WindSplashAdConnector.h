//
//  Header.h
//  WindSDK
//
//  Created by happyelements on 2018/8/1.
//  Copyright © 2018 Codi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WindProtocol.h"

@protocol WindSplashAdAdapter;



@protocol WindSplashAdConnector<WindAdRequestProtocol>

@optional

/**
 *  开屏广告初始化成功
 */
- (void)adapterDidSetUpSplashAd:(id<WindSplashAdAdapter>)splashAdAdapter;

/**
 *  开屏广告初始化失败
 */
- (void)adapter:(id<WindSplashAdAdapter>)splashAdAdapter didFailToSetUpSplashAd:(NSError *)error;

/**
 *  开屏广告成功展示
 */
-(void)adapterDidSuccessPresentScreen:(id<WindSplashAdAdapter>)splashAdAdapter;

/**
 *  开屏广告展示失败
 */
-(void)adapterDidFailToPresent:(id<WindSplashAdAdapter>)splashAdAdapter withError:(NSError *)error;

/**
 *  应用进入后台时回调
 *  详解: 当点击下载应用时会调用系统程序打开，应用切换到后台
 */
- (void)adapterDidApplicationWillEnterBackground:(id<WindSplashAdAdapter>)splashAdAdapter;

/**
 *  开屏广告点击回调
 */
- (void)adapterDidClicked:(id<WindSplashAdAdapter>)splashAdAdapter;

/**
 *  开屏广告将要关闭回调
 */
- (void)adapterDidWillClosed:(id<WindSplashAdAdapter>)splashAdAdapter;

/**
 *  开屏广告关闭回调
 */
- (void)adapterDidClosed:(id<WindSplashAdAdapter>)splashAdAdapter;

@end
