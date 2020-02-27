//
//  BaiduMobAdPreroll.h
//  BaiduMobAdSDK
//
//  Created by Yang,Dingjia on 2019/3/25.
//  Copyright © 2019 Baidu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BaiduMobAdPrerollDelegate.h"

@interface BaiduMobAdPreroll : NSObject
/**
 *  委托对象
 */
@property (nonatomic ,weak) id<BaiduMobAdPrerollDelegate> delegate;
/**
 *  应用的APPID
 */
@property(nonatomic, copy) NSString *publisherId;
/**
 *  设置/获取代码位id
 */
@property(nonatomic, copy) NSString *adId;
/**
 *  设置贴片baseview
 */
@property(nonatomic, strong) UIView *renderBaseView;

/**
 *  位置信息
 */
@property (nonatomic, assign) BOOL enableLocation;

/**
 设置静音（默认非静音）
 
 @param mute YES静音 NO非静音
 */
@property (nonatomic, assign) BOOL mute;

/**
 *  使用controller present 落地页
 */
@property (nonatomic, weak) UIViewController *presentAdViewController;

/**
 *  请求广告
 */
- (void)load;

/**
 *  关闭广告（stop视频，普通广告请remove）
 */
- (void)close;

/**
 当前播放时长

 @return 视频播放时长
 */
- (NSTimeInterval)currentTime;

/**
 视频总时长

 @return 视频总时长
 */
- (NSTimeInterval)duration;

/**
 * 对返回的广告单元，需先判断BaiduMobMaterialType再决定使用何种渲染组件
 */
- (NSString *)adMaterialType;


/**
 * @brief 重新布局，根据触发时目前新尺寸，用于横竖屏切换
 *
 */
- (void)reSize;


/**
 * @brief 重新布局.动画式变化
 *
 * @param duration 动画时长
 * @param frame 目标的尺寸
 */
- (void)reSizeInAnimateDuration:(double)duration targetFrame:(CGRect)frame;
@end
