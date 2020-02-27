//
//  BaiduMobAdNative.h
//  BaiduMobAdSdk
//
//  Created by lishan04 on 15-1-8.
//
//

#import <Foundation/Foundation.h>
#import "BaiduMobAdNativeAdDelegate.h"
@class BaiduMobAdNativeAdView;

@interface BaiduMobAdNative : NSObject

/**
 *  应用的APPID
 */
@property(nonatomic, copy) NSString *publisherId;

/**
 *  设置/获取代码位id
 */
@property(nonatomic, copy) NSString *adId;

/**
 * 原生广告delegate
 */
@property (nonatomic ,weak) id<BaiduMobAdNativeAdDelegate> delegate;

/**
 * 针对视频缓存delegate
 * 适用于小视频，信息流视频不建议使用
 */
@property (nonatomic ,weak) id<BaiduMobAdNativeCacheDelegate> cacheDelegate;

/**
 * 模版高度，仅用于信息流模版广告
 */
@property (nonatomic ,strong) NSNumber *baiduMobAdsHeight;

/**
 * 模版宽度，仅用于信息流模版广告
 */
@property (nonatomic ,strong) NSNumber *baiduMobAdsWidth;

/**
 *  使用controller present 落地页
 */
@property (nonatomic, weak) UIViewController *presentAdViewController;

/**
 * 广告请求成功后是否缓存视频物料，YES:缓存 NO:不缓存。默认缓存
 */
@property (nonatomic ,assign) BOOL isCacheVideo;

/**
 *  请求原生广告
 *  注意广告的展示存在有效期，单次检索后须在一定时间内展示在页面上
 */
- (void)requestNativeAds;

@end
