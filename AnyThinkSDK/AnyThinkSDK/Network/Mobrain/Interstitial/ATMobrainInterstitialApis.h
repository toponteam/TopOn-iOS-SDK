//
//  ATMobrainInterstitialApis.h
//  AnyThinkMobrainAdapter
//
//  Created by Topon on 2/1/21.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ATMobrainBaseManager.h"

#ifndef ATMobrainInterstitialApis_h
#define ATMobrainInterstitialApis_h

@protocol ABUInterstitialAdDelegate;
@protocol ATABUInterstitialAd <NSObject>
@property (nonatomic, weak, nullable) id<ABUInterstitialAdDelegate> delegate;
@property (nonatomic, getter = isAdValid, readonly) BOOL adValid;
@property (nonatomic, assign, readonly) BOOL hasExpressAdGot;
@property (nonatomic, assign, readonly) BOOL hasAdConfig;
- (void)setConfigSuccessCallback:(void (^_Nullable)(void))callback;
- (instancetype _Nonnull)initWithAdUnitID:(NSString *_Nonnull)adUnitID size:(CGSize)expectSize;
- (void)loadAdData;
- (ATABUAdnType)getAdNetworkPlaformId;
- (NSString *_Nullable)getAdNetworkRitId;
- (NSString *_Nullable)getPreEcpm;
- (BOOL)showAdFromRootViewController:(UIViewController *_Nonnull)rootViewController;
@end

@protocol ABUInterstitialAdDelegate <NSObject>
@optional
- (void)interstitialAdDidLoad:(id<ATABUInterstitialAd>_Nonnull)interstitialAd;
- (void)interstitialAd:(id<ATABUInterstitialAd>_Nonnull)interstitialAd didFailWithError:(NSError *_Nullable)error;
- (void)interstitialAdViewRenderFail:(id<ATABUInterstitialAd>_Nonnull)interstitialAd error:(NSError *__nullable)error;
- (void)interstitialAdDidVisible:(id<ATABUInterstitialAd>_Nonnull)interstitialAd;
- (void)interstitialAdDidClick:(id<ATABUInterstitialAd>_Nonnull)interstitialAd;
- (void)interstitialAdDidClose:(id<ATABUInterstitialAd>_Nonnull)interstitialAd;
- (void)interstitialAdWillPresentFullScreenModal:(id<ATABUInterstitialAd>_Nonnull)interstitialAd;
@end

@protocol ABUFullscreenVideoAdDelegate;
@protocol ATABUFullscreenVideoAd <NSObject>

@property (nonatomic, weak, nullable) id<ABUFullscreenVideoAdDelegate> delegate;

/**
Whether the splash ad data can be showed.Only check when you call API "show".
*/
@property (nonatomic, getter = isAdValid, readonly) BOOL adValid;

/**
 Required
 Get a express Ad if SDK can.Default is NO.
 必须设置且只对支持模板广告的第三方SDK有效,默认为NO.
 */
@property (nonatomic, assign, readwrite) BOOL getExpressAdIfCan;

/**
 Is a express Ad
 返回是否为模板广告，一般如果有返回值在收到visiable方法可用
 Generally if there is a return value available in the receive method "AdDidVisible"
 */
@property (nonatomic, assign, readonly) BOOL hasExpressAdGot;

/**
 返回是否包含点击回调,hasClickCallback == YES时，才会有fullscreenVideoAdDidClick回调； 在收到fullscreenVideoAdDidVisible回调后有效
 */
@property (nonatomic, assign, readonly) BOOL hasClickCallback;

/// Configure whether the request is successful
@property (nonatomic, assign, readonly) BOOL hasAdConfig;

/**
 Initializes video ad with slot id.
 @param adUnitID : the unique identifier of video ad.
 @return BUFullscreenVideoAd
 */
- (instancetype _Nonnull)initWithAdUnitID:(NSString *_Nonnull)adUnitID;

/**
 Load video ad datas.
 */
- (void)loadAdData;
/**
 在hasAdConfig为NO的情况下需要传入该callback，并在callback中loadAdData，具体使用参考demo
 */
- (void)setConfigSuccessCallback:(void (^_Nullable)(void))callback;

/// 返回显示广告对应的Adn（该接口需要在fullscreenVideoAdDidVisible之后会返回对应的adn），当广告加载中未显示会返回-2，当没有权限访问该部分会放回-3
- (ATABUAdnType)getAdNetworkPlaformId;
/// 返回显示广告对应的rit（该接口需要在fullscreenVideoAdDidVisible之后会返回对应的rit），当广告加载中未显示会返回-2，当没有权限访问该部分会放回-3
- (NSString *_Nullable)getAdNetworkRitId;
/// 返回显示广告对应的ecpm（该接口需要在fullscreenVideoAdDidVisible之后会返回对应的ecpm）），当未在平台配置ecpm会返回-1，当广告加载中未显示会返回-2，当没有权限访问该部分会放回-3 单位：分
- (NSString *_Nullable)getPreEcpm;

/**
 Display video ad.
 @param rootViewController : root view controller for displaying ad.
 @return : whether it is successfully displayed.
 */
- (BOOL)showAdFromRootViewController:(UIViewController *_Nonnull)rootViewController;

@end

@protocol ABUFullscreenVideoAdDelegate <NSObject>
@optional

/**
 This method is called when video ad material loaded successfully.
 */
- (void)fullscreenVideoAdDidLoad:(id<ATABUFullscreenVideoAd>_Nonnull)fullscreenVideoAd;

/**
 This method is called when video ad materia failed to load.
 @param error : the reason of error
 */
- (void)fullscreenVideoAd:(id<ATABUFullscreenVideoAd>_Nonnull)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error;

/**
 This method is called when cached successfully.
 */
- (void)fullscreenVideoAdDidDownLoadVideo:(id<ATABUFullscreenVideoAd>_Nonnull)fullscreenVideoAd;

/**
 This method is called when video ad slot will be showing.
 */
- (void)fullscreenVideoAdDidVisible:(id<ATABUFullscreenVideoAd>_Nonnull)fullscreenVideoAd;

/**
 This method is called when video ad is clicked.
 */
- (void)fullscreenVideoAdDidClick:(id<ATABUFullscreenVideoAd>_Nonnull)fullscreenVideoAd;

/**
 This method is called when video ad is skiped.
 */
- (void)fullscreenVideoAdDidSkip:(id<ATABUFullscreenVideoAd>_Nonnull)rewardedVideoAd;

/**
 This method is called when video ad is closed.
 */
- (void)fullscreenVideoAdDidClose:(id<ATABUFullscreenVideoAd>_Nonnull)fullscreenVideoAd;

/**
 * This method is called when FullScreen modal has been presented.Include appstore jump.
 *  弹出详情广告页
 */
- (void)fullscreenVideoAdWillPresentFullScreenModal:(id<ATABUFullscreenVideoAd>_Nonnull)fullscreenVideoAd;

@end

#endif /* ATMobrainInterstitialApis_h */
