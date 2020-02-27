//
//  OneWaySDK.h
//  OneWaySDK
//
//  Created by lch on 2016/9/5.
//  Copyright © 2016年 mobi.oneway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "OWRewardedAd.h"
#import "OWInterstitialAd.h"
#import "OWInterstitialImageAd.h"
#import "OWUserMetaData.h"

/**
 *  An enumeration for the completion state of an ad.
 */
typedef NS_ENUM(NSInteger, OneWaySDKFinishState) {
    /**
     *  A state that indicates that the ad did not successfully display.
     */
    kOneWaySDKFinishStateError,
    /**
     *  A state that indicates that the user skipped the ad.
     */
    kOneWaySDKFinishStateSkipped,
    /**
     *  A state that indicates that the ad was played entirely.
     */
    kOneWaySDKFinishStateCompleted
};


NS_ASSUME_NONNULL_BEGIN

/**
 * `oneWaySDK` is a static class with methods for preparing and showing ads.
 *
 * @warning In order to ensure expected behaviour, the delegate must always be set.
 */
@interface OneWaySDK : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)initialize NS_UNAVAILABLE;


/**
 配置 OneWaySDK .

 @param publishId 应用的唯一 publishId ,在OneWaySDK平台获取.
 */
+ (void)configure:(NSString *)publishId;


/**
 设置 log 的可见性.

 @param debugLog TRUE : 显示所有log
 */
+ (void)debugLog:(BOOL)debugLog;


/**
 获取当前SDK的版本

 @return SDK的版本
 */
+ (NSString *)getVersion;


/**
 SDK是否已经配置完成

 @return SDK是否已经配置完成
 */
+ (BOOL)isConfigured;


@end
NS_ASSUME_NONNULL_END
