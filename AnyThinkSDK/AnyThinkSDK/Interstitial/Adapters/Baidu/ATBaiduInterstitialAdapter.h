//
//  ATBaiduInterstitialAdapter.h
//  AnyThinkBaiduInterstitialAdapter
//
//  Created by Martin Lau on 2018/11/30.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ATBaiduInterstitialAdapter : NSObject

@end

@protocol BaiduMobAdSetting<NSObject>
@property BOOL supportHttps;
@property BOOL trackCrash;
+ (void)setLpStyle:(NSInteger)style;
+ (instancetype)sharedInstance;
+ (void)setMaxVideoCacheCapacityMb:(NSInteger)capacity;
@end

typedef enum _BaiduMobAdInterstitialType {
    BaiduMobAdViewTypeInterstitialOther = 5,
    BaiduMobAdViewTypeInterstitialBeforeVideo = 7,
    BaiduMobAdViewTypeInterstitialPauseVideo = 8
    
} BaiduMobAdInterstitialType;

@protocol BaiduMobAdInterstitialDelegate;
@protocol ATBaiduMobAdInterstitial<NSObject>
@property (nonatomic ,assign) id<BaiduMobAdInterstitialDelegate> delegate;
@property (nonatomic) BaiduMobAdInterstitialType interstitialType;
@property (nonatomic) BOOL isReady;
@property (nonatomic,copy) NSString* AdUnitTag;
@property (nonatomic, readonly) NSString* Version;
- (void)loadAndDisplayUsingKeyWindow:(UIWindow *)keyWindow;
- (void)load;
- (void)presentFromRootViewController:(UIViewController *)rootViewController;
- (void)loadUsingSize:(CGRect)rect;
- (void)presentFromView:(UIView *)view;
@end

@protocol BaiduMobAdInterstitialDelegate <NSObject>
@required
- (NSString *)publisherId;
@optional
- (NSString *)channelId;
- (BOOL) enableLocation;
- (void)interstitialSuccessToLoadAd:(id<ATBaiduMobAdInterstitial>)interstitial;
- (void)interstitialFailToLoadAd:(id<ATBaiduMobAdInterstitial>)interstitial;
- (void)interstitialWillPresentScreen:(id<ATBaiduMobAdInterstitial>)interstitial;
- (void)interstitialSuccessPresentScreen:(id<ATBaiduMobAdInterstitial>)interstitial;
- (void)interstitialFailPresentScreen:(id<ATBaiduMobAdInterstitial>)interstitial withError:(NSInteger) reason;
- (void)interstitialDidAdClicked:(id<ATBaiduMobAdInterstitial>)interstitial;
- (void)interstitialDidDismissScreen:(id<ATBaiduMobAdInterstitial>)interstitial;
- (void)interstitialDidDismissLandingPage:(id<ATBaiduMobAdInterstitial>)interstitial;
@end
