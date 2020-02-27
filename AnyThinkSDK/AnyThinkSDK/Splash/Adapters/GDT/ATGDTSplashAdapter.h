//
//  ATGDTSplashAdapter.h
//  AnyThinkGDTSplashAdapter
//
//  Created by Martin Lau on 2018/12/20.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATGDTSplashAdapter : NSObject

@end

@protocol ATGDTSDKConfig<NSObject>
+ (NSString *)sdkVersion;
@end

@protocol ATGDTSplashAd;
@protocol GDTSplashAdDelegate <NSObject>
@optional
- (void)splashAdSuccessPresentScreen:(id<ATGDTSplashAd>)splashAd;
- (void)splashAdFailToPresent:(id<ATGDTSplashAd>)splashAd withError:(NSError *)error;
- (void)splashAdApplicationWillEnterBackground:(id<ATGDTSplashAd>)splashAd;
- (void)splashAdExposured:(id<ATGDTSplashAd>)splashAd;
- (void)splashAdClicked:(id<ATGDTSplashAd>)splashAd;
- (void)splashAdWillClosed:(id<ATGDTSplashAd>)splashAd;
- (void)splashAdClosed:(id<ATGDTSplashAd>)splashAd;
- (void)splashAdWillPresentFullScreenModal:(id<ATGDTSplashAd>)splashAd;
- (void)splashAdDidPresentFullScreenModal:(id<ATGDTSplashAd>)splashAd;
- (void)splashAdWillDismissFullScreenModal:(id<ATGDTSplashAd>)splashAd;
- (void)splashAdDidDismissFullScreenModal:(id<ATGDTSplashAd>)splashAd;
- (void)splashAdLifeTime:(NSUInteger)time;
@end

@protocol ATGDTSplashAd<NSObject>
@property (nonatomic, weak) id<GDTSplashAdDelegate> delegate;
@property (nonatomic, assign) NSInteger fetchDelay;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, copy) UIColor *backgroundColor;
@property (nonatomic, assign) CGPoint skipButtonCenter;
- (instancetype)initWithAppId:(NSString *)appId placementId:(NSString *)placementId;
- (void)loadAdAndShowInWindow:(UIWindow *)window;
- (void)loadAdAndShowInWindow:(UIWindow *)window withBottomView:(UIView *)bottomView;
- (void)loadAdAndShowInWindow:(UIWindow *)window withBottomView:(UIView *)bottomView skipView:(UIView *)skipView;
@end
