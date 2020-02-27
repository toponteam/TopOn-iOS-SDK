//
//  ATIronSourceInterstitialAdapter.h
//  AnyThinkIronSourceInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/9.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kATIronSourceInterstitialNotificationLoaded;
extern NSString *const kATIronSourceInterstitialNotificationLoadFailed;
extern NSString *const kATIronSourceInterstitialNotificationShow;
extern NSString *const kATIronSourceInterstitialNotificationClick;
extern NSString *const kATIronSourceInterstitialNotificationClose;

extern NSString *const kATIronSourceInterstitialNotificationUserInfoInstanceID;
extern NSString *const kATIronSourceInterstitialNotificationUserInfoError;
@interface ATIronSourceInterstitialAdapter : NSObject
@end

@protocol ISDemandOnlyInterstitialDelegate <NSObject>
@end

@protocol ATIronSource<NSObject>
+ (void)setConsent:(BOOL)consent;
+ (NSString *)sdkVersion;
//demand only
+ (void)initISDemandOnly:(NSString *)appKey adUnits:(NSArray<NSString *> *)adUnits;
+ (void)setISDemandOnlyInterstitialDelegate:(id<ISDemandOnlyInterstitialDelegate>)delegate;
+ (void)loadISDemandOnlyInterstitial:(NSString *)instanceId;
+ (void)showISDemandOnlyInterstitial:(UIViewController *)viewController instanceId:(NSString *)instanceId;
+ (BOOL)hasISDemandOnlyInterstitial:(NSString *)instanceId;
@end
