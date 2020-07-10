//
//  BaiduMobAdInterstitialDelegate.h
//  BaiduMobAdWebSDK
//
//  Created by deng jinxiang on 13-8-1.
//
//
#import <Foundation/Foundation.h>
#import "BaiduMobAdCommonConfig.h"

@class BaiduMobAdNative;
@class BaiduMobAdNativeAdView;
@class BaiduMobAdNativeAdObject;

@protocol BaiduMobAdNativeAdDelegate <NSObject>

@optional
/**
 *  应用在mssp.baidu.com上的APPID
 */
- (NSString *)publisherId;

/**
 * 广告位id
 */
- (NSString *)apId;

/**
 * 模版高度，仅用于信息流模版广告
 */
- (NSNumber *)baiduMobAdsHeight;

/**
 * 模版宽度，仅用于信息流模版广告
 */
- (NSNumber *)baiduMobAdsWidth;

/**
 *  渠道ID
 */
- (NSString *)channelId;

/**
 *  启动位置信息
 */
- (BOOL) enableLocation;//如果enable，plist 需要增加NSLocationWhenInUseUsageDescription

/**
 * 广告请求成功
 * 请求成功的BaiduMobAdNativeAdObject数组，如果只成功返回一条原生广告，数组大小为1
 */
- (void)nativeAdObjectsSuccessLoad:(NSArray *)nativeAds nativeAd:(BaiduMobAdNative *)nativeAd;

/**
 *  广告请求失败
 *  失败的类型 BaiduMobFailReason
 */
- (void)nativeAdsFailLoad:(BaiduMobFailReason)reason nativeAd:(BaiduMobAdNative *)nativeAd;

/**
 *  广告曝光回调
 */
- (void)nativeAdExposure:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object;

/**
 *  广告点击
 */
- (void)nativeAdClicked:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object;

/**
 *  广告详情页关闭
 */
- (void)didDismissLandingPage:(UIView *)nativeAdView;

#pragma mark - Deprecated

- (void)nativeAdObjectsSuccessLoad:(NSArray *)nativeAds BaiduMobAdDEPRECATED_MSG("已废弃，请使用nativeAdObjectsSuccessLoad:nativeAd:");

- (void)nativeAdsFailLoad:(BaiduMobFailReason)reason BaiduMobAdDEPRECATED_MSG("已废弃，请使用nativeAdsFailLoad:nativeAd:");

- (void)nativeAdClicked:(UIView *)nativeAdView BaiduMobAdDEPRECATED_MSG("已废弃，请使用nativeAdClicked:nativeAdDataObject:");

@end

#pragma mark - 视频缓存delegate

@protocol BaiduMobAdNativeCacheDelegate <NSObject>

@optional
/**
 *  视频缓存成功
 */
- (void)nativeVideoAdCacheSuccess:(BaiduMobAdNative *)nativeAd;

/**
 *  视频缓存失败
 */
- (void)nativeVideoAdCacheFail:(BaiduMobAdNative *)nativeAd withError:(BaiduMobFailReason)reason;

@end
