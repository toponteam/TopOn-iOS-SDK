//
//  ATMopubInterstitialAdapter.h
//  AnyThinkMopubInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/9.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATMopubInterstitialAdapter : NSObject
@end

@protocol ATMPMoPubConfiguration<NSObject>
- (instancetype)initWithAdUnitIdForAppInitialization:(NSString *)adUnitId;
@end

@protocol ATMoPub<NSObject>
+ (instancetype)sharedInstance;
- (NSString *)version;
- (void)grantConsent;
- (void)revokeConsent;
- (void)initializeSdkWithConfiguration:(id<ATMPMoPubConfiguration>)configuration completion:(void(^_Nullable)(void))completionBlock;
@end

@protocol MPInterstitialAdControllerDelegate;
@protocol ATMPInterstitialAdController<NSObject>
+ (instancetype)interstitialAdControllerForAdUnitId:(NSString *)adUnitId;
@property (nonatomic, weak) id<MPInterstitialAdControllerDelegate> delegate;
//@property (nonatomic, copy) NSString *adUnitId;
//@property (nonatomic, copy) NSString *keywords;
//@property (nonatomic, copy) NSString *userDataKeywords;
//@property (nonatomic, copy) CLLocation *location;
- (void)loadAd;
@property (nonatomic, assign, readonly) BOOL ready;
- (void)showFromViewController:(UIViewController *)controller;
+ (void)removeSharedInterstitialAdController:(id<ATMPInterstitialAdController>)controller;
+ (NSMutableArray *)sharedInterstitialAdControllers;

@end

#pragma mark -
@protocol MPInterstitialAdControllerDelegate <NSObject>
@optional
- (void)interstitialDidLoadAd:(id<ATMPInterstitialAdController>)interstitial;
- (void)interstitialDidFailToLoadAd:(id<ATMPInterstitialAdController>)interstitial;
- (void)interstitialDidFailToLoadAd:(id<ATMPInterstitialAdController>)interstitial withError:(NSError *)error;
- (void)interstitialWillAppear:(id<ATMPInterstitialAdController>)interstitial;
- (void)interstitialDidAppear:(id<ATMPInterstitialAdController>)interstitial;
- (void)interstitialWillDisappear:(id<ATMPInterstitialAdController>)interstitial;
- (void)interstitialDidDisappear:(id<ATMPInterstitialAdController>)interstitial;
- (void)interstitialDidExpire:(id<ATMPInterstitialAdController>)interstitial;
- (void)interstitialDidReceiveTapEvent:(id<ATMPInterstitialAdController>)interstitial;
@end
NS_ASSUME_NONNULL_END
