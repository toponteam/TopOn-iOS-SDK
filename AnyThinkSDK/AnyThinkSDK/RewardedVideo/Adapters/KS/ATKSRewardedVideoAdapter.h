//
//  ATKSRewardedVideoAdapter.h
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

@interface ATKSRewardedVideoAdapter : NSObject
@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);
@end

@protocol ATKSRewardedVideoModel <NSObject>
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger amount;
@property (nonatomic, copy) NSString *extra;
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
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController showScene:(NSString *)showScene;
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController;
- (BOOL)isSameValidVideoAd:(id<ATKSVideoAd>)ad;

@end


@protocol KSRewardedVideoAdDelegate;
@protocol ATKSRewardedVideoAd <ATKSVideoAd>
@property (nonatomic, strong) id<ATKSRewardedVideoModel> rewardedVideoModel;
@property (nonatomic, weak, nullable) id<KSRewardedVideoAdDelegate> delegate;

- (instancetype)initWithPosId:(NSString *)posId rewardedVideoModel:(id<ATKSRewardedVideoModel>)rewardedVideoModel;
@end

@protocol KSRewardedVideoAdDelegate <NSObject>
- (void)rewardedVideoAdDidLoad:(id<ATKSRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAd:(id<ATKSRewardedVideoAd>)rewardedVideoAd didFailWithError:(NSError *_Nullable)error;
- (void)rewardedVideoAdVideoDidLoad:(id<ATKSRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdWillVisible:(id<ATKSRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdDidVisible:(id<ATKSRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdWillClose:(id<ATKSRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdDidClose:(id<ATKSRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdDidClick:(id<ATKSRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdDidPlayFinish:(id<ATKSRewardedVideoAd>)rewardedVideoAd didFailWithError:(NSError *_Nullable)error;
- (void)rewardedVideoAdDidClickSkip:(id<ATKSRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdStartPlay:(id<ATKSRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAd:(id<ATKSRewardedVideoAd>)rewardedVideoAd hasReward:(BOOL)hasReward;

@end

