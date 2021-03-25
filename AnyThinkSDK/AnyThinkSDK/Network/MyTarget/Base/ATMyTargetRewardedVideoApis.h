//
//  ATMyTargetRewardedVideoApis.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/12/28.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATMyTargetInterstitialApis.h"

#ifndef ATMyTargetRewardedVideoApis_h
#define ATMyTargetRewardedVideoApis_h

NS_ASSUME_NONNULL_BEGIN

@protocol MTRGRewardedAdDelegate;

@protocol ATMTRGReward <NSObject>

@property(nonatomic, readonly) NSString *type;

+ (instancetype)create;

@end

@protocol ATMTRGRewardedAd <NSObject, ATMTRGBaseInterstitialAd>

@property(nonatomic, weak, nullable) id <MTRGRewardedAdDelegate> delegate;

+ (instancetype)rewardedAdWithSlotId:(NSUInteger)slotId;

- (instancetype)initWithSlotId:(NSUInteger)slotId;

@end

@protocol MTRGRewardedAdDelegate <NSObject>

- (void)onLoadWithRewardedAd:(id<ATMTRGRewardedAd>)rewardedAd;

- (void)onNoAdWithReason:(NSString *)reason rewardedAd:(id<ATMTRGRewardedAd>)rewardedAd;

- (void)onReward:(id<ATMTRGReward>)reward rewardedAd:(id<ATMTRGRewardedAd>)rewardedAd;

@optional

- (void)onClickWithRewardedAd:(id<ATMTRGRewardedAd>)rewardedAd;

- (void)onCloseWithRewardedAd:(id<ATMTRGRewardedAd>)rewardedAd;

- (void)onDisplayWithRewardedAd:(id<ATMTRGRewardedAd>)rewardedAd;

- (void)onLeaveApplicationWithRewardedAd:(id<ATMTRGRewardedAd>)rewardedAd;

@end


#endif /* ATMyTargetRewardedVideoApis_h */

NS_ASSUME_NONNULL_END
