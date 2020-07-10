//
//  ATOnewayRewardedVideoAdapter.h
//  AnyThinkOnewayRewardedVideoAdapter
//
//  Created by Martin Lau on 30/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kATOnewayRVReadyNotification;
extern NSString *const kATOnewayRVShowNotification;
extern NSString *const kATOnewayRVClickNotification;
extern NSString *const kATOnewayRVFinishNotification;
extern NSString *const kATOnewayRVCloseNotification;
extern NSString *const kATOnewayRVErrorNotification;

extern NSString *const kATOnewayRVNotificationUserInfoTagKey;
extern NSString *const kATOnewayRVNotificationUserInfoMessageKey;
extern NSString *const kATOnewayRVNotificationUserInfoErrorCodeKey;
extern NSString *const kATOnewayRVNotificationUserInfoStateKey;
extern NSString *const kATOnewayRVNotificationUserInfoSessionKey;

@interface ATOnewayRewardedVideoAdapter : NSObject
@end

@protocol OneWaySDK<NSObject>
+ (void)configure:(NSString *)publishId;
+ (void)debugLog:(BOOL)debugLog;
+ (NSString *)getVersion;
+ (BOOL)isConfigured;
@end

@protocol oneWaySDKRewardedAdDelegate <NSObject>
@end

@protocol OWRewardedAd<NSObject>
+ (void)initWithDelegate:(id<oneWaySDKRewardedAdDelegate>)delegate;
+ (BOOL)isReady;
+ (void)show:(UIViewController *)viewController;
+ (void)show:(UIViewController *)viewController tag:(NSString *)tag;
@end
