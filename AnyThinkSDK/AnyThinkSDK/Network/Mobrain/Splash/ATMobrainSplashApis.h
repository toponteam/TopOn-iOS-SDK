//
//  ATMobrainSplashApis.h
//  AnyThinkSDK
//
//  Created by Jason on 2021/2/2.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#ifndef ATMobrainSplashApis_h
#define ATMobrainSplashApis_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ATMobrainBaseManager.h"

@protocol ABUSplashAdDelegate <NSObject>

@end

@protocol ATABUSplashUserData <NSObject>

@property (nonatomic, assign) ATABUAdnType adnType;   // adn类型
@property (nonatomic, copy) NSString * _Nonnull rit;    // adn对应代码位
@property (nonatomic, copy) NSString * _Nonnull appID;  // adn对应appID
@property (nonatomic, copy) NSString * _Nullable appKey;    // adn对应appKey, 没有时可不传

@end

@protocol ATABUSplashAd <NSObject>


/// The unique identifier of splash ad.
@property (nonatomic, copy, readonly, nonnull) NSString *adUnitID;

/// Maximum allowable load timeout, default 3s, unit s.
@property (nonatomic, assign) NSTimeInterval tolerateTimeout;

///  Get a express Ad if SDK can.Default is NO.
@property (nonatomic, assign, readwrite) BOOL getExpressAdIfCan;

/// Is a express Ad Generally if there is a return value available in the receive method "AdDidVisible"
@property (nonatomic, assign, readonly) BOOL hasExpressAdGot;


/**
 The delegate for receiving state change messages.
 */
@property (nonatomic, weak, nullable) id<ABUSplashAdDelegate> delegate;


/// Root view controller for handling ad actions.
@property (nonatomic, weak) UIViewController * _Nullable rootViewController;

/// Whether the splash ad data can be showed.Only check when you call API "show".
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;

/// Initializes splash ad with slot id and frame.
/// @param adUnitID the unique identifier of splash ad
- (instancetype _Nonnull )initWithAdUnitID:(NSString *_Nonnull)adUnitID;

/// Load splash ad datas.
- (void)loadAdData;

/// 返回显示广告对应的Adn（该接口需要在splashAdWillVisible之后会返回对应的adn），当广告加载中未显示会返回-2，当没有权限访问该部分会放回-3
- (ATABUAdnType)getAdNetworkPlaformId;
/// 返回显示广告对应的rit（该接口需要在splashAdWillVisible之后会返回对应的rit），当广告加载中未显示会返回-2，当没有权限访问该部分会放回-3
- (NSString *_Nullable)getAdNetworkRitId;
/// 返回显示广告对应的ecpm（该接口需要在splashAdWillVisible之后会返回对应的ecpm）），当未在平台配置ecpm会返回-1，当广告加载中未显示会返回-2，当没有权限访问该部分会放回-3 单位：分
- (NSString *_Nullable)getPreEcpm;

/**
 Display video ad.
 @param window : root window for displaying ad, must be key window.
 */
- (void)showInWindow:(UIWindow *_Nullable)window;


/**
 Optional:
在广告位配置拉取失败后，会使用传入的rit和appID兜底，进行广告加载，需要在创建manager时就调用该接口（仅支持穿山甲/MTG/Ks/GDT/百度）,
 */
- (void)setUserData:(id<ATABUSplashUserData> _Nonnull)userData error:(NSError **)error;

/**
Required, destory the ad when ad close.
*/
- (void)destoryAd;
@end
#endif /* ATMobrainSplashApis_h */
