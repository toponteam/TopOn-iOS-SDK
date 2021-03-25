//
//  ATMopubRewardedVideoAdapter.h
//  AnyThinkMopubRewardedVideoAdapter
//
//  Created by Martin Lau on 10/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATRewardedVideoAdapter.h"
#import <CoreLocation/CLLocation.h>
@interface ATMopubRewardedVideoAdapter : NSObject
@end

@protocol ATRewardedVideoReward<NSObject>
@end

@protocol ATMPRewardedVideoDelegate;
@protocol ATRewardedVideo<NSObject>
+ (void)setDelegate:(id<ATMPRewardedVideoDelegate>)delegate forAdUnitId:(NSString *)adUnitId;
+ (void)removeDelegate:(id<ATMPRewardedVideoDelegate>)delegate;
+ (void)removeDelegateForAdUnitId:(NSString *)adUnitId;
+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID withMediationSettings:(NSArray *)mediationSettings;
+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID keywords:(NSString *)keywords userDataKeywords:(NSString *)userDataKeywords location:(CLLocation *)location mediationSettings:(NSArray *)mediationSettings;
+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID keywords:(NSString *)keywords userDataKeywords:(NSString *)userDataKeywords location:(CLLocation *)location customerId:(NSString *)customerId mediationSettings:(NSArray *)mediationSettings;
+ (BOOL)hasAdAvailableForAdUnitID:(NSString *)adUnitID;
+ (NSArray *)availableRewardsForAdUnitID:(NSString *)adUnitID;
+ (id<ATRewardedVideoReward>)selectedRewardForAdUnitID:(NSString *)adUnitID;
+ (void)presentRewardedVideoAdForAdUnitID:(NSString *)adUnitID fromViewController:(UIViewController *)viewController withReward:(id<ATRewardedVideoReward>)reward;
+ (void)presentRewardedVideoAdForAdUnitID:(NSString *)adUnitID fromViewController:(UIViewController *)viewController withReward:(id<ATRewardedVideoReward>)reward customData:(NSString *)customData;
@end

@protocol ATMPRewardedVideoDelegate <NSObject>
@optional
- (void)rewardedVideoAdDidLoadForAdUnitID:(NSString *)adUnitID;
- (void)rewardedVideoAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error;
- (void)rewardedVideoAdDidExpireForAdUnitID:(NSString *)adUnitID;
- (void)rewardedVideoAdDidFailToPlayForAdUnitID:(NSString *)adUnitID error:(NSError *)error;
- (void)rewardedVideoAdWillAppearForAdUnitID:(NSString *)adUnitID;
- (void)rewardedVideoAdDidAppearForAdUnitID:(NSString *)adUnitID;
- (void)rewardedVideoAdWillDisappearForAdUnitID:(NSString *)adUnitID;
- (void)rewardedVideoAdDidDisappearForAdUnitID:(NSString *)adUnitID;
- (void)rewardedVideoAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID;
- (void)rewardedVideoAdWillLeaveApplicationForAdUnitID:(NSString *)adUnitID;
- (void)rewardedVideoAdShouldRewardForAdUnitID:(NSString *)adUnitID reward:(id<ATRewardedVideoReward>)reward;

@end
