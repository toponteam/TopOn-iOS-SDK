//
//  ATFacebookRewardedVideoAdapter.h
//  AnyThinkFacebookRewardedVideoAdapter
//
//  Created by Martin Lau on 10/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const kFacebookRVCustomEventKey;
@interface ATFacebookRewardedVideoAdapter : NSObject

@end

@protocol ATFBRewardedVideoAdDelegate;
@protocol ATFBRewardedVideoAd<NSObject>
@property (nonatomic, weak, nullable) id<ATFBRewardedVideoAdDelegate> delegate;
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;
- (instancetype)initWithPlacementID:(NSString *)placementID withUserID:(nullable NSString *)userID withCurrency:(nullable NSString *)currency;
- (void)loadAd;
- (void)loadAdWithBidPayload:(NSString *)bidPayload;
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController;
@end


@protocol ATFBRewardedVideoAdDelegate <NSObject>
@optional
- (void)rewardedVideoAdDidClick:(id<ATFBRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdDidLoad:(id<ATFBRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdDidClose:(id<ATFBRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdWillClose:(id<ATFBRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAd:(id<ATFBRewardedVideoAd>)rewardedVideoAd didFailWithError:(NSError *)error;
- (void)rewardedVideoAdVideoComplete:(id<ATFBRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdWillLogImpression:(id<ATFBRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdServerRewardDidSucceed:(id<ATFBRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdServerRewardDidFail:(id<ATFBRewardedVideoAd>)rewardedVideoAd;
@end
