//
//  AppnextRewardedVideoAd.h
//  AppnextLib
//
//  Created by Eran Mausner on 11/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <AppnextLib/AppnextVideoAd.h>
#import <AppnextLib/AppnextRewardedServerSidePostbackParams.h>

@interface AppnextRewardedVideoAd : AppnextVideoAd

@property (nonatomic, strong, readonly) AppnextRewardedServerSidePostbackParams *rewardedServerSidePostbackParams;

#pragma mark - Setters/Getters

- (void) setRewardedServerSidePostbackParams:(AppnextRewardedServerSidePostbackParams *)params;

- (void) setRewardsTransactionId:(NSString *)rewardsTransactionId;
- (NSString *) getRewardsTransactionId;
- (void) setRewardsUserId:(NSString *)rewardsUserId;
- (NSString *) getRewardsUserId;
- (void) setRewardsRewardTypeCurrency:(NSString *)rewardsRewardTypeCurrency;
- (NSString *) getRewardsRewardTypeCurrency;
- (void) setRewardsAmountRewarded:(NSString *)rewardsAmountRewarded;
- (NSString *) getRewardsAmountRewarded;
- (void) setRewardsCustomParameter:(NSString *)rewardsCustomParameter;
- (NSString *) getRewardsCustomParameter;

@end
