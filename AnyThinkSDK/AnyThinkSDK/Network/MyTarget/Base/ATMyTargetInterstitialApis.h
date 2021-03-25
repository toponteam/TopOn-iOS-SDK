//
//  ATMyTargetInterstitialApis.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/12/28.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#ifndef ATMyTargetInterstitialApis_h
#define ATMyTargetInterstitialApis_h

@protocol ATMTRGBaseInterstitialAd <NSObject>

- (void)load;
- (void)loadFromBid:(NSString *)bidId;
- (void)showWithController:(UIViewController *)controller;

@end

@protocol MTRGInterstitialAdDelegate;

@protocol ATMTRGInterstitialAd  <NSObject, ATMTRGBaseInterstitialAd>

@property(nonatomic, weak, nullable) id <MTRGInterstitialAdDelegate> delegate;

+ (instancetype)interstitialAdWithSlotId:(NSUInteger)slotId;

- (instancetype)initWithSlotId:(NSUInteger)slotId;

@end

@protocol MTRGInterstitialAdDelegate <NSObject>

- (void)onLoadWithInterstitialAd:(id<ATMTRGInterstitialAd>)interstitialAd;

- (void)onNoAdWithReason:(NSString *)reason interstitialAd:(id<ATMTRGInterstitialAd>)interstitialAd;

@optional

- (void)onClickWithInterstitialAd:(id<ATMTRGInterstitialAd>)interstitialAd;

- (void)onCloseWithInterstitialAd:(id<ATMTRGInterstitialAd>)interstitialAd;

- (void)onVideoCompleteWithInterstitialAd:(id<ATMTRGInterstitialAd>)interstitialAd;

- (void)onDisplayWithInterstitialAd:(id<ATMTRGInterstitialAd>)interstitialAd;

- (void)onLeaveApplicationWithInterstitialAd:(id<ATMTRGInterstitialAd>)interstitialAd;

@end

#endif /* ATMyTargetInterstitialApis_h */

NS_ASSUME_NONNULL_END
