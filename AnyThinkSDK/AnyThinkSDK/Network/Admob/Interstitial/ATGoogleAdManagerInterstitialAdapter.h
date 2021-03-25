//
//  ATGoogleAdManagerInterstitialAdapter.h
//  AnyThinkAdmobInterstitialAdapter
//
//  Created by stephen on 7/27/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATGoogleAdManagerInterstitialAdapter : NSObject

@end

@protocol ATDFPRequest<NSObject>
+ (NSString *)sdkVersion;
+ (instancetype)request;
@end

@protocol DFPInterstitialDelegate;
@protocol ATDFPInterstitial<NSObject>
- (instancetype)initWithAdUnitID:(NSString *)adUnitID;
#pragma mark Pre-Request
@property(nonatomic, readonly, copy, nullable) NSString *adUnitID;
@property(nonatomic, weak, nullable) id<DFPInterstitialDelegate> delegate;
#pragma mark Making an Ad Request
- (void)loadRequest:(id<ATDFPRequest>)request;
#pragma mark Post-Request
@property(nonatomic, readonly, assign) BOOL isReady;
@property(nonatomic, readonly, assign) BOOL hasBeenUsed;
- (void)presentFromRootViewController:(UIViewController *)rootViewController;
@end

@protocol DFPInterstitialDelegate<NSObject>
@optional
#pragma mark Ad Request Lifecycle Notifications
- (void)interstitialDidReceiveAd:(id<ATDFPInterstitial>)ad;
- (void)interstitial:(id<ATDFPInterstitial>)ad didFailToReceiveAdWithError:(NSError *)error;
#pragma mark Display-Time Lifecycle Notifications
- (void)interstitialWillPresentScreen:(id<ATDFPInterstitial>)ad;
- (void)interstitialDidFailToPresentScreen:(id<ATDFPInterstitial>)ad;
- (void)interstitialWillDismissScreen:(id<ATDFPInterstitial>)ad;
- (void)interstitialDidDismissScreen:(id<ATDFPInterstitial>)ad;
- (void)interstitialWillLeaveApplication:(id<ATDFPInterstitial>)ad;

@end
