//
//  ATAdmobInterstitialAdapter.h
//  AnyThinkAdmobInterstitialAdapter
//
//  Created by Martin Lau on 25/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATAdmobInterstitialAdapter : NSObject
@end

@protocol ATGADRequest<NSObject>
+ (NSString *)sdkVersion;
+ (instancetype)request;
@property(nonatomic, copy) NSArray *testDevices;
@end

@protocol GADInterstitialDelegate;
@protocol ATGADInterstitial<NSObject>
- (instancetype)initWithAdUnitID:(NSString *)adUnitID;
#pragma mark Pre-Request
@property(nonatomic, readonly, copy, nullable) NSString *adUnitID;
@property(nonatomic, weak, nullable) id<GADInterstitialDelegate> delegate;
#pragma mark Making an Ad Request
- (void)loadRequest:(id<ATGADRequest>)request;
#pragma mark Post-Request
@property(nonatomic, readonly, assign) BOOL isReady;
@property(nonatomic, readonly, assign) BOOL hasBeenUsed;
- (void)presentFromRootViewController:(UIViewController *)rootViewController;
@end

@protocol GADInterstitialDelegate<NSObject>
@optional
#pragma mark Ad Request Lifecycle Notifications
- (void)interstitialDidReceiveAd:(id<ATGADInterstitial>)ad;
- (void)interstitial:(id<ATGADInterstitial>)ad didFailToReceiveAdWithError:(NSError *)error;
#pragma mark Display-Time Lifecycle Notifications
- (void)interstitialWillPresentScreen:(id<ATGADInterstitial>)ad;
- (void)interstitialDidFailToPresentScreen:(id<ATGADInterstitial>)ad;
- (void)interstitialWillDismissScreen:(id<ATGADInterstitial>)ad;
- (void)interstitialDidDismissScreen:(id<ATGADInterstitial>)ad;
- (void)interstitialWillLeaveApplication:(id<ATGADInterstitial>)ad;

@end
