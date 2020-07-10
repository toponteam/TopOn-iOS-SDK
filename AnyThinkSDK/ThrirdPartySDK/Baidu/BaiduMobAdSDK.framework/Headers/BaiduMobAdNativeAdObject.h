//
//  BaiduMobAdNativeAdObject.h
//  BaiduMobNativeSDK
//
//  Created by lishan04 on 15-5-26.
//  Copyright (c) 2015年 lishan04. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaiduMobAdCommonConfig.h"

@interface BaiduMobAdNativeAdObject : NSObject

/**
 * 标题 text
 */
@property (copy, nonatomic) NSString *title;
/**
 * 描述 text
 */
@property (copy, nonatomic) NSString *text;
/**
 * 小图 url
 */
@property (copy, nonatomic) NSString *iconImageURLString;
/**
 * 大图 url
 */
@property (copy, nonatomic) NSString *mainImageURLString;

/**
 * 广告标识图标 url
 */
@property (copy, nonatomic) NSString *adLogoURLString;

/**
 * 百度logo图标 url
 */
@property (copy, nonatomic) NSString *baiduLogoURLString;

/**
 * 多图信息流的image url array
 */
@property (strong, nonatomic) NSArray *morepics;
/**
 * 视频url
 */
@property (copy, nonatomic) NSString *videoURLString;
/**
 * 视频时长，单位为s
 */
@property (strong, nonatomic) NSNumber *videoDuration;
/**
 * 自动播放
 */
@property (strong, nonatomic) NSNumber *autoPlay;
/**
 * 品牌名称，若广告返回中无品牌名称则为空
 */
@property (copy, nonatomic) NSString *brandName;
/**
* 开发者配置可接受视频后，对返回的广告单元，需先判断BaiduMobMaterialType再决定使用何种渲染组件
 */
@property (assign, nonatomic) BaiduMobMaterialType materialType;

/**
 * 返回广告单元的点击类型
 */
@property (assign, nonatomic) BaiduMobNativeAdActionType actType;

/**
 * 大图图片宽
 */
@property (copy, nonatomic) NSString *w;
/**
 * 大图图片高
 */
@property (copy, nonatomic) NSString *h;
/**
 价格标签
 */
@property (copy, nonatomic) NSString *ECPMLevel;

#pragma mark - 智能优选
/**
 信息流广告样式类型
 */
@property (nonatomic, assign) BaiduMobAdSmartFeedStyleType style_type;
/**
 标记信息流广告容器宽高是px还是比例 0：无、1：像素、2：比例
 */
@property (nonatomic, assign) BaiduMobAdSmartFeedSizeType size_type;
/**
 信息流广告容器宽
 */
@property (nonatomic, assign) int container_width;
/**
 信息流广告容器高
 */
@property (nonatomic, assign) int container_height;


/**
 *  广告价格标签
 */
- (NSString *)getECPMLevel;

/**
 * 是否过期，默认为false，30分钟后过期，需要重新请求广告
 */
- (BOOL)isExpired;

/**
 * 发送视频广告相关日志
 * @param currentPlaybackTime 播放器当前时间，单位为s
 */
- (void)trackVideoEvent:(BaiduAdNativeVideoEvent)event withCurrentTime:(NSTimeInterval)currentPlaybackTime;

/**
 * 发送展现
 */
- (void)trackImpression:(UIView *)view;

/**
 * 发送点击
 */
- (void)handleClick:(UIView *)view;

@end
