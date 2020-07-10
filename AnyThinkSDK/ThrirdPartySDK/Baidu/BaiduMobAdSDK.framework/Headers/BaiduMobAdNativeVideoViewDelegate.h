//
//  BaiduMobAdNativeVideoViewDelegate.h
//  BaiduMobAdSDK
//
//  Created by Yang,Dingjia on 2020/5/19.
//  Copyright © 2020 Baidu Inc. All rights reserved.
//

@class BaiduMobAdNativeVideoView;
@protocol BaiduMobAdNativeVideoViewDelegate <NSObject>

@optional

/**
 视频准备开始播放
 
 @param videoView self
 */
- (void)nativeVideoAdDidStartPlaying:(BaiduMobAdNativeVideoView *)videoView;

/**
 视频重播
 
 @param videoView self
 */
- (void)nativeVideoAdDidReplay:(BaiduMobAdNativeVideoView *)videoView;

/**
 视频播放完成

 @param videoView self
 */
- (void)nativeVideoAdDidComplete:(BaiduMobAdNativeVideoView *)videoView;

/**
 视频播放失败

 @param videoView self
 */
- (void)nativeVideoAdDidFailed:(BaiduMobAdNativeVideoView *)videoView;

@end
