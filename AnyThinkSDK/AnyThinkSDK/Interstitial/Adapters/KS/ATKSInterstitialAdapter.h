//
//  ATKSInterstitialAdapter.h
//  AnyThinkSDK
//
//  Created by Topon on 2019/9/10.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ATKSAdSDKLogLevel) {
    KSAdSDKLogLevelAll      =       0,
    KSAdSDKLogLevelVerbose,  // 此类别的日记不会记录到日志文件中
    KSAdSDKLogLevelDebug,
    KSAdSDKLogLevelVerify,
    KSAdSDKLogLevelInfo,
    KSAdSDKLogLevelWarn,
    KSAdSDKLogLevelError,
    KSAdSDKLogLevelOff,
};

@interface ATKSInterstitialAdapter : NSObject
@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);

@end

@protocol ATKSAdUserInfo <NSObject>
@property (nonatomic, assign) long userId;           // 用户id，目前是必填
@property (nonatomic, copy) NSString *gender;         // 用户性别，选填 F: 女性 M:男性
@property (nonatomic, copy) NSArray *interestArray;   // 用户兴趣，选填
@end

@protocol ATKSAdSDKManager <NSObject>
@property (nonatomic, readonly, class) NSString *SDKVersion;
+ (void)setAppId:(NSString *)appId;
+ (void)setAppName:(NSString *)appName;
+ (void)setUserInfoBlock:(void(^)(id<ATKSAdUserInfo>))userInfoBlock;
+ (void)setLoglevel:(ATKSAdSDKLogLevel)level;
+ (NSString *)appId;
@end

@protocol ATKSVideoAd <NSObject>
@property (nonatomic, readonly) BOOL isValid;
- (void)loadAdData;
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController;
@end

@protocol KSFullscreenVideoAdDelegate;

@protocol ATKSFullscreenVideoAd <ATKSVideoAd>

@property (nonatomic, weak, nullable) id<KSFullscreenVideoAdDelegate> delegate;

- (instancetype)initWithPosId:(NSString *)posId;
@end

@protocol KSFullscreenVideoAdDelegate <NSObject>
- (void)fullscreenVideoAdDidLoad:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd;
- (void)fullscreenVideoAd:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error;
- (void)fullscreenVideoAdVideoDidLoad:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd;
- (void)fullscreenVideoAdWillVisible:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd;
- (void)fullscreenVideoAdDidVisible:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd;
- (void)fullscreenVideoAdWillClose:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd;
- (void)fullscreenVideoAdDidClose:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd;
- (void)fullscreenVideoAdDidClick:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd;
- (void)fullscreenVideoAdDidPlayFinish:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error;
- (void)fullscreenVideoAdDidClickSkip:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd;
- (void)fullscreenVideoAdStartPlay:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd;
@end


