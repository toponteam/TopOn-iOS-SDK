//
//  BaiduMobAdSmartFeedView.h
//  BaiduMobAdSDK
//
//  Created by Bao,Shiwei on 2019/7/24.
//  Copyright © 2019 Baidu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaiduMobAdNativeAdObject.h"
#import "BaiduMobAdCommonConfig.h"

@interface BaiduMobAdSmartFeedView : UIView

/**
 * @brief 初始化智能优选组件
 *
 * @param object 信息流广告对象
 * @param frame frame,注意，以传入宽计算高度，会重新设置frame的高。添加到界面重新获取height
 * @return 模板组件
 */
- (instancetype)initWithObject:(BaiduMobAdNativeAdObject *)object
                         frame:(CGRect)frame;

/**
 * @brief 初始化智能优选组件
 *
 * @param object 信息流广告对象
 * @param frame frame,注意，以传入宽计算高度，会重新设置frame的高。添加到界面重新获取height
 * @param color 弱网下图片的默认背景色，若不传，将用浅灰色默认替代
 * @return 模板组件
 */
- (instancetype)initWithObject:(BaiduMobAdNativeAdObject *)object
                         frame:(CGRect)frame
          imageBackgroundColor:(UIColor *)color;

/**
 * @brief 组件的宽度
 *
 * @return 宽度
 */
- (CGFloat)viewWidth;

/**
 * @brief 组件的高度
 *
 * @return 高度
 */
- (CGFloat)viewHeight;

/**
 * @brief 是否已渲染完毕
 *
 * @return YES/NO
 */
- (BOOL)isReady;

/**
 * @brief 修改相关细节参数，组件尺寸后/字体字号，重新刷新渲染效果。注意组件高度有可能改变
 *
 */
- (void)reSize;

/**
 设置静音

 @param mute YES静音   NO非静音
 */
- (void)setVideoMute:(BOOL)mute;

/**
 * @brief 触发曝光检查
 *
 */
- (void)trackImpression;

/**
 * @brief 执行点击行为
 *
 */
- (void)handleClick;

/**
触发播放，仅设置wifi自动播放后生效。建议屏幕滑动停止后调用
*/
- (BOOL)render;

//TODO:修改如下字段后，必须调用一次reSize方法，部分属性会影响高度，注意修改后viewHeight会改变
//logo配置
@property (nonatomic, assign) CGFloat iconWidth;
@property (nonatomic, assign) CGFloat iconHeight;
@property (nonatomic, assign) CGFloat iconLeft;
@property (nonatomic, assign) CGFloat iconTop;
@property (nonatomic, assign) CGFloat iconRight;
@property (nonatomic, assign) CGFloat iconBottom;

//标题配置
@property (nonatomic, assign) CGFloat titleLeft;
@property (nonatomic, assign) CGFloat titleTop;
@property (nonatomic, assign) CGFloat titleWidth;
@property (nonatomic, assign) CGFloat titleHeight;
@property (nonatomic, assign) CGFloat titleRight;
@property (nonatomic, assign) CGFloat titleBottom;
@property (nonatomic, assign) CGFloat titleFontSize;//系统默认字体
@property (nonatomic, assign) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;

//主素材：大图、视频、三图首图
@property (nonatomic, assign) CGFloat mainMaterialLeft;
@property (nonatomic, assign) CGFloat mainMaterialTop;
@property (nonatomic, assign) CGFloat mainMaterialWidth;
@property (nonatomic, assign) CGFloat mainMaterialHeight;
@property (nonatomic, assign) CGFloat mainMaterialRight;
@property (nonatomic, assign) CGFloat mainMaterialBottom;

//三图的中图
@property (nonatomic, assign) CGFloat centerPicLeft;
@property (nonatomic, assign) CGFloat centerPicTop;
@property (nonatomic, assign) CGFloat centerPicWidth;
@property (nonatomic, assign) CGFloat centerPicHeight;
@property (nonatomic, assign) CGFloat centerPicRight;
@property (nonatomic, assign) CGFloat centerPicBottom;

//三图的右图
@property (nonatomic, assign) CGFloat lastPicLeft;
@property (nonatomic, assign) CGFloat lastPicTop;
@property (nonatomic, assign) CGFloat lastPicWidth;
@property (nonatomic, assign) CGFloat lastPicHeight;
@property (nonatomic, assign) CGFloat lastPicRight;
@property (nonatomic, assign) CGFloat lastPicBottom;

//底部品牌字样,建议不更改
@property (nonatomic, assign) CGFloat brandLeft;
@property (nonatomic, assign) CGFloat brandWidth;
@property (nonatomic, assign) CGFloat brandHeight;
@property (nonatomic, assign) CGFloat brandBottom;
@property (nonatomic, assign) CGFloat brandFontSize;
@property (nonatomic, assign) UIFont *brandFont;
@property (nonatomic, strong) UIColor *brandColor;

#pragma mark - Deprecated

///已废弃，请及时替换mainMaterial*
@property (nonatomic, assign) CGFloat mainPicLeft BaiduMobAdDEPRECATED_MSG("已废弃，请及时更换mainMaterial");
@property (nonatomic, assign) CGFloat mainPicTop BaiduMobAdDEPRECATED_MSG("已废弃，请及时更换mainMaterial");
@property (nonatomic, assign) CGFloat mainPicWidth BaiduMobAdDEPRECATED_MSG("已废弃，请及时更换mainMaterial");
@property (nonatomic, assign) CGFloat mainPicHeight BaiduMobAdDEPRECATED_MSG("已废弃，请及时更换mainMaterial");
@property (nonatomic, assign) CGFloat mainPicRight BaiduMobAdDEPRECATED_MSG("已废弃，请及时更换mainMaterial");
@property (nonatomic, assign) CGFloat mainPicBottom BaiduMobAdDEPRECATED_MSG("已废弃，请及时更换mainMaterial");

@end
