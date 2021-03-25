//
//  ATBaiduSplashAdapter.h
//  AnyThinkBaiduSplashAdapter
//
//  Created by Martin Lau on 2018/12/21.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATBaiduSplashAdapter : NSObject
@end

@protocol BaiduMobAdSplashDelegate;
@protocol ATBaiduMobAdSplash<NSObject>
@property (nonatomic ,assign) id<BaiduMobAdSplashDelegate> delegate;
@property (nonatomic,copy) NSString* AdUnitTag;
@property (nonatomic) BOOL canSplashClick;
@property (nonatomic, readonly) NSString* Version;
@property (nonatomic) CGSize adSize;
- (void)loadAndDisplayUsingKeyWindow:(UIWindow *)keyWindow;
- (void)loadAndDisplayUsingContainerView:(UIView *)view;
- (void)load;
- (void)showInContainerView:(UIView *)view;

@end

@protocol BaiduMobAdSplashDelegate <NSObject>
@required
- (NSString *)publisherId;
@optional
- (NSString*) channelId;
-(BOOL) enableLocation;
- (void)splashSuccessPresentScreen:(id<ATBaiduMobAdSplash>)splash;
- (void)splashlFailPresentScreen:(id<ATBaiduMobAdSplash>)splash withError:(NSInteger) reason;
- (void)splashDidClicked:(id<ATBaiduMobAdSplash>)splash;
- (void)splashDidDismissScreen:(id<ATBaiduMobAdSplash>)splash;
- (void)splashDidDismissLp:(id<ATBaiduMobAdSplash>)splash;
- (void)splashDidReady:(id<ATBaiduMobAdSplash>)splash
             AndAdType:(NSString *)adType
         VideoDuration:(NSInteger)videoDuration;
- (void)splashAdLoadSuccess:(id<ATBaiduMobAdSplash>)splash;
- (void)splashAdLoadFail:(id<ATBaiduMobAdSplash>)splash;
@end
