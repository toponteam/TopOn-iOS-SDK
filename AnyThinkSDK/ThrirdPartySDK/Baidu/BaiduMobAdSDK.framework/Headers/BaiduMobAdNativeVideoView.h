//
//
//  Created by lishan04 on 15-11-1.
//  Copyright (c) 2015 lishan04. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaiduMobAdCommonConfig.h"
#import "BaiduMobAdNativeVideoBaseView.h"
#import "BaiduMobAdNativeVideoViewDelegate.h"

@class BaiduMobAdNativeAdObject;
@interface BaiduMobAdNativeVideoView : BaiduMobAdNativeVideoBaseView
@property BOOL supportControllerView;
@property BOOL supportActImage;

@property (nonatomic, strong) UIButton *btnLP; // 点击查看详情按钮
@property (nonatomic, strong) UIButton *btnReplay; // 重播按钮
@property (nonatomic, weak) id <BaiduMobAdNativeVideoViewDelegate> videoDelegate; //视频事件delegate

/**
 初始化方法

 @param frame videoView尺寸
 @param object BaiduMobAdNativeAdObject
 @return BaiduMobAdVideoView
 */
- (instancetype)initWithFrame:(CGRect)frame andObject:(BaiduMobAdNativeAdObject *)object;

/**
 开始播放
 */
- (void)play;

/**
 暂停播放
 */
- (void)pause;

/**
 销毁播放器
 */
- (void)stop;

/**
 重新播放
 */
- (void)replay;

/**
 是否播放中

 @return isPlaying
 */
- (BOOL)isPlaying;

/**
 设置静音

 @param mute YES静音   NO非静音
 */
- (void)setVideoMute:(BOOL)mute;

/**
 刷新视图frame
 */
- (void)reSize;

/**
发送视频状态
一定要向BaiduMobAdNativeAdObject发送视频状态事件和当前视频播放的位置，只有在第一次播放才需要发送
*/
- (void)sendVideoEvent:(BaiduAdNativeVideoEvent)event currentTime:(NSTimeInterval) currentTime;


/**
触发播放，仅设置wifi自动播放后生效。建议屏幕滑动停止后调用
*/
- (BOOL)render;

#pragma mark - Deprecate
- (BOOL)handleScrollStop BaiduMobAdDEPRECATED_MSG("已废弃");

@end
