//
//  ATKSBaseManager.h
//  AnyThinkKuaiShouAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATNetworkBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATKSBaseManager : ATNetworkBaseManager

@end

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

NS_ASSUME_NONNULL_END
