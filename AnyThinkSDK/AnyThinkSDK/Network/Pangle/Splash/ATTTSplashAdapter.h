//
//  ATTTSplashAdapter.h
//  AnyThinkTTSplashAdapter
//
//  Created by Martin Lau on 2018/12/21.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol BUSplashZoomOutViewDelegate;

@protocol ATBUSplashZoomOutView<NSObject>

@property (nonatomic, weak) id<BUSplashZoomOutViewDelegate> delegate;

@end

@interface ATTTSplashAdapter : NSObject

@end

@protocol BUSplashAdDelegate;
@protocol ATBUSplashAdView<NSObject>
@property (nonatomic, copy, readonly, nonnull) NSString *slotID;
@property (nonatomic, assign) NSTimeInterval tolerateTimeout;
@property (nonatomic, assign) BOOL hideSkipButton;
@property (nonatomic, readonly) id<ATBUSplashZoomOutView> zoomOutView;
@property (nonatomic, weak, nullable) id<BUSplashAdDelegate> delegate;
@property (nonatomic) BOOL needSplashZoomOutAd;
@property (nonatomic, weak) UIViewController *rootViewController;
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;
- (instancetype)initWithSlotID:(NSString *)slotID frame:(CGRect)frame;
- (void)loadAdData;
@end

@protocol BUSplashAdDelegate <NSObject>
@optional
- (void)spalshAdDidClick:(id<ATBUSplashAdView>)spalshAd;
- (void)spalshAdDidClose:(id<ATBUSplashAdView>)spalshAd;
- (void)spalshAdWillClose:(id<ATBUSplashAdView>)spalshAd;
- (void)spalshAdDidLoad:(id<ATBUSplashAdView>)spalshAd;
- (void)spalshAd:(id<ATBUSplashAdView>)spalshAd didFailWithError:(NSError *)error;
- (void)spalshAdWillVisible:(id<ATBUSplashAdView>)spalshAd;
@end

@protocol BUSplashZoomOutViewDelegate <NSObject>
/**
 This method is called when splash ad is clicked.
 */
- (void)splashZoomOutViewAdDidClick:(id<ATBUSplashZoomOutView>)splashAd;

/**
 This method is called when splash ad is closed.
 */
- (void)splashZoomOutViewAdDidClose:(id<ATBUSplashZoomOutView>)splashAd;

/**
This method is called when spalashAd automatically dimiss afte countdown equals to zero
*/
- (void)splashZoomOutViewAdDidAutoDimiss:(id<ATBUSplashZoomOutView>)splashAd;

/**
 This method is called when another controller has been closed.
 @param interactionType : open appstore in app or open the webpage or view video ad details page.
 */
- (void)splashZoomOutViewAdDidCloseOtherController:(id<ATBUSplashZoomOutView>)splashAd interactionType:(int)interactionType;

@end

@protocol BUNativeExpressSplashViewDelegate;
@protocol BUNativeExpressSplashView <NSObject>
@property (nonatomic, weak, nullable) id<BUNativeExpressSplashViewDelegate> delegate;
@property (nonatomic, assign) NSTimeInterval tolerateTimeout;
@property (nonatomic, assign) BOOL hideSkipButton;
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;
@property (nonatomic, copy, readonly) NSDictionary *mediaExt;
- (instancetype)initWithSlotID:(NSString *)slotID adSize:(CGSize)adSize rootViewController:(UIViewController *)rootViewController;
- (void)loadAdData;
- (void)removeSplashView;
@end

@protocol BUNativeExpressSplashViewDelegate <NSObject>
- (void)nativeExpressSplashViewDidLoad:(id<BUNativeExpressSplashView>)splashAdView;
- (void)nativeExpressSplashView:(id<BUNativeExpressSplashView>)splashAdView didFailWithError:(NSError * _Nullable)error;
- (void)nativeExpressSplashViewRenderSuccess:(id<BUNativeExpressSplashView>)splashAdView;
- (void)nativeExpressSplashViewRenderFail:(id<BUNativeExpressSplashView>)splashAdView error:(NSError * __nullable)error;
- (void)nativeExpressSplashViewWillVisible:(id<BUNativeExpressSplashView>)splashAdView;
- (void)nativeExpressSplashViewDidClick:(id<BUNativeExpressSplashView>)splashAdView;
- (void)nativeExpressSplashViewDidClickSkip:(id<BUNativeExpressSplashView>)splashAdView;
- (void)nativeExpressSplashViewDidClose:(id<BUNativeExpressSplashView>)splashAdView;
- (void)nativeExpressSplashViewFinishPlayDidPlayFinish:(id<BUNativeExpressSplashView>)splashView didFailWithError:(NSError *)error;
@end

NS_ASSUME_NONNULL_END
