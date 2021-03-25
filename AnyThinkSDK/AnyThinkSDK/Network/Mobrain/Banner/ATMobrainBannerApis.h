//
//  ATMobrainBannerApis.h
//  AnyThinkSDK
//
//  Created by Jason on 2021/2/2.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#ifndef ATMobrainBannerApis_h
#define ATMobrainBannerApis_h
#import <Foundation/Foundation.h>

@protocol ABUBannerAdDelegate <NSObject>

@end

@protocol ATABUBannerAd

@property (nonatomic, weak, nullable) id<ABUBannerAdDelegate> delegate;

/**
 The carousel interval, in seconds, is set in the range of 30~120s, and is passed during initialization. If it does not meet the requirements, it will not be in carousel ad.
 !!!Some Ad SDK is not support interval，eg:AdMob.So it is valid if the SDK
  supported.
 */
@property (nonatomic, assign, readonly) NSInteger autoRefreshTime;

/**
 required.
 Root view controller for handling ad actions.
 Action method includes 'pushViewController' and 'presentViewController'.
 */
@property (nonatomic, weak, readwrite) UIViewController * _Nullable rootViewController;

/// adSize
@property (nonatomic, assign, readonly) CGSize adSize;

/**
 Is a express Ad
 返回是否为模板广告，一般如果有返回值在收到visiable方法可用
 Generally if there is a return value available in the receive method "AdDidVisible"
 */
@property (nonatomic, assign, readonly) BOOL hasExpressAdGot;

/// Configure whether the request is successful
@property (nonatomic, assign, readonly) BOOL hasAdConfig;

/// Description
/// @param adUnitID adUnitID
/// @param rootViewController rootViewController
/// @param adsize adsize The adsize should be equal to the ad size configured by the platform.
/// @param autoRefreshTime The carousel interval, in seconds, is set in the range of 30~120s, and is passed during initialization. If it does not meet the requirements, it will not be in carousel ad.There is no effect when ads are not supported
/// 广告刷新间隔，范围 [30, 120] 秒，默认值 30 秒。设 0 则不刷新。当广告不支持时设置无用
- (instancetype _Nonnull)initWithAdUnitID:(NSString *_Nonnull)adUnitID
            rootViewController:(UIViewController *_Nonnull)rootViewController
                        adSize:(CGSize)adsize autoRefreshTime:(NSInteger)autoRefreshTime;

/// load Ad
- (void)loadAdData;


/**
 在hasAdConfig为NO的情况下需要传入该callback，并在callback中loadAdData，具体使用参考demo
 */
- (void)setConfigSuccessCallback:(void(^_Nullable)(void))callback;


/// 返回显示广告对应的Adn（该接口需要在bannerAdViewDidBecomVisible之后会返回对应的adn），当广告加载中未显示会返回-2，当没有权限访问该部分会放回-3
- (NSUInteger)getAdNetworkPlaformId;
/// 返回显示广告对应的rit（该接口需要在bannerAdViewDidBecomVisible之后会返回对应的rit），当广告加载中未显示会返回-2，当没有权限访问该部分会放回-3
- (NSString *_Nullable)getAdNetworkRitId;
/// 返回显示广告对应的ecpm（该接口需要在bannerAdViewDidBecomVisible之后会返回对应的ecpm）），当未在平台配置ecpm会返回-1，当广告加载中未显示会返回-2，当没有权限访问该部分会放回-3 单位：分
- (NSString *_Nullable)getPreEcpm;

@end
#endif /* ATMobrainBannerApis_h */
