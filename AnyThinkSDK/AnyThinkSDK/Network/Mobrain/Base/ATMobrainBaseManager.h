//
//  ATMobrainBaseManager.h
//  AnyThinkMobrainAdapter
//
//  Created by Topon on 2/1/21.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import <AnyThinkSDK/AnyThinkSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATMobrainBaseManager : ATNetworkBaseManager

@end

// 三方Adn枚举
typedef NS_ENUM (NSInteger, ATABUAdnType) {
    ABUAdnNoPermission = -3,    // 无权限访问
    ABUAdnNoData = -2,  // 暂时无真实数据，未获取到最佳广告，一般在未展示之前提前调用
    ABUAdnNone = 0,     // 未知adn
    ABUAdnPangle = 1,   // 穿山甲adn
    ABUAdnAdmob = 2,    // 谷歌Admob
    ABUAdnGDT = 3,      // 腾讯广点通adn
    ABUAdnBaidu = 4,    // 百度adn
    ABUAdnUnity = 5,    // unity adn
    ABUAdnSigmob = 6,   // Sigmob adn
    ABUAdnKs = 7,       // 快手Adn
    ABUAdnMTG = 8,      // Mintegral adn
};

typedef NS_ENUM (NSInteger, ATABUAdSDKLogLevel) {
    ABUAdSDKLogLevelNone,
    ABUAdSDKLogLevelError,
    ABUAdSDKLogLevelDebug
};

typedef NS_ENUM (NSInteger, ATABUAdSDKLogLanguage) {
    ABUAdSDKLogLanguageCH,
    ABUAdSDKLogLanguageEN
};

@protocol ATABUSize <NSObject>
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
- (NSDictionary *)dictionaryValue;
@end

@protocol ATABUAdSDKManager <NSObject>
@property (nonatomic, copy, readonly, class) NSString *SDKVersion;
+ (void)setAppID:(NSString *)appID;
+ (void)setIsPaidApp:(BOOL)isPaidApp;
+ (void)setExtDeviceData:(NSString *)extraDeviceStr;
+ (void)setLoglevel:(ATABUAdSDKLogLevel)level language:(ATABUAdSDKLogLanguage)language;
+ (NSString *)appID;
+ (BOOL)isPaidApp;

@end

NS_ASSUME_NONNULL_END
