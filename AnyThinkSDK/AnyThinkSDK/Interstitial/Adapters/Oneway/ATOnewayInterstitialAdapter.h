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

@protocol OneWaySDK<NSObject>
+ (void)configure:(NSString *)publishId;
+ (void)debugLog:(BOOL)debugLog;
+ (NSString *)getVersion;
+ (BOOL)isConfigured;
@end

#pragma mark - interstitial image
@protocol oneWaySDKInterstitialAdDelegate <NSObject>
- (void)oneWaySDKInterstitialAdReady;
- (void)oneWaySDKInterstitialAdDidShow:(NSString *)tag;
- (void)oneWaySDKInterstitialAdDidClose:(NSString *)tag withState:(NSNumber *)state;
- (void)oneWaySDKInterstitialAdDidClick:(NSString *)tag;
- (void)oneWaySDKDidError:(NSInteger)error withMessage:(NSString *)message;
@end

@protocol OWInterstitialAd<NSObject>
+ (void)initWithDelegate:(id<oneWaySDKInterstitialAdDelegate>)delegate;
+ (BOOL)isReady;
+ (void)show:(UIViewController *)viewController;
+ (void)show:(UIViewController *)viewController tag:(NSString *)tag;
@end
