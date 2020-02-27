//
//  KSAdSDKManager.h
//  KSAdSDK
//
//  Created by 徐志军 on 2019/8/28.
//  Copyright © 2019 KuaiShou. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, KSAdSDKLogLevel) {
    KSAdSDKLogLevelAll      =       0,
    KSAdSDKLogLevelVerbose,  // 此类别的日记不会记录到日志文件中
    KSAdSDKLogLevelDebug,
    KSAdSDKLogLevelVerify,
    KSAdSDKLogLevelInfo,
    KSAdSDKLogLevelWarn,
    KSAdSDKLogLevelError,
    KSAdSDKLogLevelOff,
};

NS_ASSUME_NONNULL_BEGIN

@class KSAdUserInfo;


@interface KSAdSDKManager : NSObject
@property (nonatomic, readonly, class) NSString *SDKVersion;

/**
 Register the App key that’s already been applied before requesting an ad from TikTok Audience Network.
 @param appId : the unique identifier of the App
 */
// required
+ (void)setAppId:(NSString *)appId;
// optional
+ (void)setAppName:(NSString *)appName;
// optional
+ (void)setUserInfoBlock:(void(^)(KSAdUserInfo *))userInfoBlock;
/**
 Configure development mode.
 @param level : default BUAdSDKLogLevelNone
 */
// optional
+ (void)setLoglevel:(KSAdSDKLogLevel)level;

+ (NSString *)appId;

+ (NSString *)SDKDetailVersion;
@end

NS_ASSUME_NONNULL_END
