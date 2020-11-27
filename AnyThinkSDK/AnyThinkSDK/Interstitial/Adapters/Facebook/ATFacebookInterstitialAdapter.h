//
//  ATFacebookInterstitialAdapter.h
//  AnyThinkFacebookInterstitialAdapter
//
//  Created by Martin Lau on 29/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATFacebookInterstitialAdapter : NSObject

@end

@protocol ATFBAdSettings <NSObject>
+ (void)setAdvertiserTrackingEnabled:(BOOL)advertiserTrackingEnabled;
@end

@protocol FBInterstitialAdDelegate;
@protocol ATFBInterstitialAd<NSObject>
@property (nonatomic, copy, readonly) NSString *placementID;
@property (nonatomic, weak, nullable) id<FBInterstitialAdDelegate> delegate;
- (instancetype)initWithPlacementID:(NSString *)placementID;
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;
- (void)loadAd;
- (void)loadAdWithBidPayload:(NSString *)bidPayload;
- (BOOL)showAdFromRootViewController:(nullable UIViewController *)rootViewController;
@end

@protocol FBInterstitialAdDelegate <NSObject>
@optional
- (void)interstitialAdDidClick:(id<ATFBInterstitialAd>)interstitialAd;
- (void)interstitialAdDidClose:(id<ATFBInterstitialAd>)interstitialAd;
- (void)interstitialAdWillClose:(id<ATFBInterstitialAd>)interstitialAd;
- (void)interstitialAdDidLoad:(id<ATFBInterstitialAd>)interstitialAd;
- (void)interstitialAd:(id<ATFBInterstitialAd>)interstitialAd didFailWithError:(NSError *)error;
- (void)interstitialAdWillLogImpression:(id<ATFBInterstitialAd>)interstitialAd;

@end
