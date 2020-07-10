//
//  ATOnewayInterstitialAdapter.h
//  AnyThinkOnewayInterstitialAdapter
//
//  Created by Martin Lau on 30/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATOnewayInterstitialAdapter : NSObject
@end

extern NSString *const kATOnewayInterstitialReadyNotification;
extern NSString *const kATOnewayInterstitialShowNotification;
extern NSString *const kATOnewayInterstitialClickNotification;
extern NSString *const kATOnewayInterstitialFinishNotification;
extern NSString *const kATOnewayInterstitialCloseNotification;
extern NSString *const kATOnewayInterstitialErrorNotification;

extern NSString *const kATOnewayInterstitialImageReadyNotification;
extern NSString *const kATOnewayInterstitialImageShowNotification;
extern NSString *const kATOnewayInterstitialImageClickNotification;
extern NSString *const kATOnewayInterstitialImageFinishNotification;
extern NSString *const kATOnewayInterstitialImageCloseNotification;
extern NSString *const kATOnewayInterstitialImageErrorNotification;

extern NSString *const kATOnewayInterstitialNotificationUserInfoTagKey;
extern NSString *const kATOnewayInterstitialNotificationUserInfoMessageKey;
extern NSString *const kATOnewayInterstitialNotificationUserInfoErrorCodeKey;
extern NSString *const kATOnewayInterstitialNotificationUserInfoStateKey;
extern NSString *const kATOnewayInterstitialNotificationUserInfoSessionKey;

@protocol OneWaySDK<NSObject>
+ (void)configure:(NSString *)publishId;
+ (void)debugLog:(BOOL)debugLog;
+ (NSString *)getVersion;
+ (BOOL)isConfigured;
@end

#pragma mark - interstitial image
@protocol oneWaySDKInterstitialAdDelegate <NSObject>
@end

@protocol oneWaySDKInterstitialImageAdDelegate <NSObject>
@end

@protocol OWInterstitialAd<NSObject>
+ (void)initWithDelegate:(id<oneWaySDKInterstitialAdDelegate>)delegate;
+ (BOOL)isReady;
+ (void)show:(UIViewController *)viewController;
+ (void)show:(UIViewController *)viewController tag:(NSString *)tag;
@end
