//
//  ATOnewayRewardedVideoAdapter.h
//  AnyThinkOnewayRewardedVideoAdapter
//
//  Created by Martin Lau on 30/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString const* kOnewayCustomEventKey;
@interface ATOnewayRewardedVideoAdapter : NSObject
@end

@protocol OneWaySDK<NSObject>
+ (void)configure:(NSString *)publishId;
+ (void)debugLog:(BOOL)debugLog;
+ (NSString *)getVersion;
+ (BOOL)isConfigured;
@end

@protocol oneWaySDKRewardedAdDelegate <NSObject>
- (void)oneWaySDKRewardedAdReady;
- (void)oneWaySDKRewardedAdDidShow:(NSString *)tag;
- (void)oneWaySDKRewardedAdDidClose:(NSString *)tag withState:(NSNumber *)state;
- (void)oneWaySDKRewardedAdDidClick:(NSString *)tag;
- (void)oneWaySDKDidError:(NSInteger)error withMessage:(NSString *)message;
@end

@protocol OWRewardedAd<NSObject>
+ (void)initWithDelegate:(id<oneWaySDKRewardedAdDelegate>)delegate;
+ (BOOL)isReady;
+ (void)show:(UIViewController *)viewController;
+ (void)show:(UIViewController *)viewController tag:(NSString *)tag;
@end
