//
//  ATBaiduNativeAdapter.h
//  AnyThinkBaiduNativeAdapter
//
//  Created by Martin Lau on 2019/7/23.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATBaiduNativeAdapter : NSObject

@end

@protocol BaiduMobAdNativeAdDelegate <NSObject>
@optional
- (NSString *)publisherId;
- (NSString*)apId;
- (NSNumber*)baiduMobAdsHeight;
- (NSNumber*)baiduMobAdsWidth;
- (NSString *)channelId;
- (BOOL) enableLocation;
- (void)nativeAdObjectsSuccessLoad:(NSArray *)nativeAds; // baidu废弃
- (void)nativeAdsFailLoad:(NSInteger) reason; //baidu废弃
- (void)nativeAdClicked:(UIView *)nativeAdView;
- (void)didDismissLandingPage:(UIView *)nativeAdView;
@end

@protocol ATBaiduMobAdNative<NSObject>
@property(nonatomic, copy) NSString *publisherId;
@property (nonatomic ,assign) BOOL isCacheVideo;
@property(nonatomic, copy) NSString *adId;
//@property (nonatomic ,weak) id<BaiduMobAdNativeCacheDelegate> cacheDelegate;
@property (nonatomic ,weak) id<BaiduMobAdNativeAdDelegate> delegate;
@property (nonatomic ,retain)  NSNumber *baiduMobAdsHeight;
@property (nonatomic ,retain)  NSNumber *baiduMobAdsWidth;
@property (nonatomic, strong)  UIViewController *presentAdViewController;
- (void)requestNativeAds;
@end

typedef NS_ENUM(NSInteger, ATBaiduMertialType) {
    ATBaiduMertialTypeNormal,
    ATBaiduMertialTypeVideo,
    ATBaiduMertialTypeHTML,
    ATBaiduMertialTypeGIF
};

typedef NS_ENUM(NSInteger, ATBaiduNativeAdActionType) {
    ATBaiduNativeAdActionTypeLP,
    ATBaiduNativeAdActionTypeDL
};

@protocol ATBaiduMobAdNativeAdObject<NSObject>
@property (copy, nonatomic)  NSString *title;
@property (copy, nonatomic)  NSString *text;
@property (copy, nonatomic) NSString *iconImageURLString;
@property (copy, nonatomic) NSString *mainImageURLString;
@property (copy, nonatomic) NSString *adLogoURLString;
@property (copy, nonatomic) NSString *baiduLogoURLString;
@property (strong, nonatomic) NSArray *morepics;
@property (copy, nonatomic)  NSString *videoURLString;
@property (copy, nonatomic)  NSNumber *videoDuration;
@property (copy, nonatomic)  NSString *brandName;
@property (copy, nonatomic)  NSNumber *autoPlay;
@property ATBaiduMertialType materialType;
@property (nonatomic)   ATBaiduNativeAdActionType actType;
@property (copy, nonatomic)  NSString *w;
@property (copy, nonatomic)  NSString *h;
-(BOOL) isExpired;
@property (nonatomic, assign)  UIViewController *presentAdViewController;
- (void)trackVideoEvent:(NSInteger)event withCurrentTime:(NSTimeInterval)currentPlaybackTime;
- (void)trackImpression:(UIView *)view;
-(void)handleClick:(UIView*)view;
@end

@protocol ATBaiduMobAdNativeWebView<NSObject>
- (instancetype)initWithFrame:(CGRect)frame andObject:(id<ATBaiduMobAdNativeAdObject>)object;
@end

@protocol ATBaiduMobAdNativeVideoBaseView<NSObject>
- (BOOL)isPlaying;
- (void)play;
- (void)pause;
- (void)stop;
- (BOOL)render;
- (BOOL)handleScrollStop;
- (void)sendVideoEvent:(NSInteger)event currentTime:(NSTimeInterval) currentTime;
@end

@protocol ATBaiduMobAdNativeVideoView<ATBaiduMobAdNativeVideoBaseView>
@property(nonatomic) CGRect            frame;
@property BOOL supportControllerView;
@property BOOL supportActImage;
@property (nonatomic, retain)   UIButton *btnLP;
@property (nonatomic, retain)   UIButton *btnReplay;
- (instancetype)initWithFrame:(CGRect)frame andObject:(id<ATBaiduMobAdNativeAdObject>)object;
- (void)sendVideoEvent:(NSInteger)event currentTime:(NSTimeInterval) currentTime;
@end

@protocol ATBaiduMobAdNativeAdView<NSObject>
-(id)initWithFrame:(CGRect)frame
         brandName:(UILabel *) brandLabel
             title:(UILabel *) titleLabel
              text:(UILabel *) textLabel
              icon:(UIImageView *) iconView
         mainImage:(UIImageView *) mainView;
-(id)initWithFrame:(CGRect)frame
         brandName:(UILabel *) brandLabel
             title:(UILabel *) titleLabel
              text:(UILabel *) textLabel
              icon:(UIImageView *) iconView
         mainImage:(UIImageView *) mainView
         videoView:(id<ATBaiduMobAdNativeVideoBaseView>) videoView;
-(id)initWithFrame:(CGRect)frame
           webview:(id<ATBaiduMobAdNativeWebView>) webView;
@property (strong, nonatomic)  UIImageView *iconImageView;
@property (strong, nonatomic)  UIImageView *mainImageView;
@property (strong, nonatomic)  UIImageView *adLogoImageView;
@property (strong, nonatomic)  UIImageView *baiduLogoImageView;
@property (strong, nonatomic)  UILabel *titleLabel;
@property (strong, nonatomic)  UILabel *textLabel;
@property (strong, nonatomic)  UILabel *brandLabel;
@property (strong, nonatomic)  id<ATBaiduMobAdNativeVideoBaseView> videoView;
@property (strong, nonatomic)  id<ATBaiduMobAdNativeWebView> webView;
@property (nonatomic, strong)  UIViewController *presentAdViewController;
- (void)loadAndDisplayNativeAdWithObject:(id<ATBaiduMobAdNativeAdObject>)object completion:(void(^)(NSArray*))completionBlock;
- (void)trackImpression;
- (BOOL)render;
+ (void)dealTapGesture:(BOOL) deal;
@end
