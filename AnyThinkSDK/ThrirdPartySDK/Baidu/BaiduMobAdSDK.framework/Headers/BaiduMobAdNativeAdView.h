//
//  BaiduMobAdNativeAdView.h
//  BaiduMobAdSdk
//
//  Created by lishan04 on 15-1-6.
//
//

#import <UIKit/UIKit.h>
#import "BaiduMobAdCommonConfig.h"
@class BaiduMobAdNativeVideoBaseView;
@class BaiduMobAdNativeAdObject;
@class BaiduMobAdNativeWebView;
@interface BaiduMobAdNativeAdView : UIView

/**
 * 小图
 */
@property (strong, nonatomic) UIImageView *iconImageView;

/**
 * 大图
 */
@property (strong, nonatomic) UIImageView *mainImageView;

/**
 多图
 */
@property (strong, nonatomic) NSMutableArray *morePicsArray;

/**
 * 广告标示
 */
@property (strong, nonatomic) UIImageView *adLogoImageView;

/**
 * 百度广告logo
 */
@property (strong, nonatomic) UIImageView *baiduLogoImageView;

/**
 * 标题 view
 */
@property (strong, nonatomic) UILabel *titleLabel;

/**
 * 描述 view
 */
@property (strong, nonatomic) UILabel *textLabel;

/**
 * 品牌名称 view
 */
@property (strong, nonatomic) UILabel *brandLabel;

/**
 * 视频 view
 */
@property (strong, nonatomic) BaiduMobAdNativeVideoBaseView *videoView;

/**
 * web view
 */
@property (strong, nonatomic) BaiduMobAdNativeWebView *webView;

/**
 *  展示用的vc, 可以不传
 */
@property (nonatomic, weak) UIViewController *presentAdViewController;

/**
 *  广告数据对象
*/
@property (nonatomic, strong, readonly) BaiduMobAdNativeAdObject *object;

/**
 常规大图信息流 MaterialType是NORMAL的初始化方法
 
 @param frame 信息流视图大小
 @param brandLabel 品牌名称
 @param titleLabel 标题
 @param textLabel 描述
 @param iconView 图标
 @param mainView 大图
 @return 信息流视图
 */
- (instancetype)initWithFrame:(CGRect)frame
          brandName:(UILabel *)brandLabel
              title:(UILabel *)titleLabel
               text:(UILabel *)textLabel
               icon:(UIImageView *)iconView
          mainImage:(UIImageView *)mainView;

/**
 * 多图信息流，MaterialType是NORMAL的初始化方法
 */
- (instancetype)initWithFrame:(CGRect)frame
          brandName:(UILabel *)brandLabel
              title:(UILabel *)titleLabel
               text:(UILabel *)textLabel
               icon:(UIImageView *)iconView
          mainImage:(UIImageView *)mainView
           morepics:(NSMutableArray *)imageViewArray;

/**
 * 信息流视频
 * 推荐使用SDK的BaiduMobAdNativeVideoView视频组件，也可自定义视频view传入
 */
- (instancetype)initWithFrame:(CGRect)frame
          brandName:(UILabel *)brandLabel
              title:(UILabel *)titleLabel
               text:(UILabel *)textLabel
               icon:(UIImageView *)iconView
          videoView:(BaiduMobAdNativeVideoBaseView *)videoView;

- (instancetype)initWithFrame:(CGRect)frame
          brandName:(UILabel *)brandLabel
              title:(UILabel *)titleLabel
               text:(UILabel *)textLabel
               icon:(UIImageView *)iconView
          mainImage:(UIImageView *)mainView
          videoView:(BaiduMobAdNativeVideoBaseView *)videoView;
/**
 * 信息流模板
 */
- (instancetype)initWithFrame:(CGRect)frame
            webview:(BaiduMobAdNativeWebView *) webView;

/**
 * 广告渲染
 */
- (void)loadAndDisplayNativeAdWithObject:(BaiduMobAdNativeAdObject *)object completion:(BaiduMobAdViewCompletionBlock)completionBlock;

/**
 曝光事件，必传
 */
- (void)trackImpression;

/**
 手动触发视频播放 仅在WiFi自动播放场景下生效

 @return 视频播放状态，是否播放中 YES正常播放  NO未播放
 */
- (BOOL)render;

/**
 设置信息流点击响应事件

 @param deal YES需开发者手动添加点击事件  默认NO，SDK管理点击事件
 */
+ (void)dealTapGesture:(BOOL) deal;

@end
