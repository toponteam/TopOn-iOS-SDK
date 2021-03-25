//
//  ATAppnextRewardedVideoAdapter.h
//  AnyThinkAppnextRewardedVideoAdapter
//
//  Created by Martin Lau on 2018/10/17.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATAppnextRewardedVideoAdapter : NSObject
@end

@protocol ATAppnextAd;

@protocol AppnextAdDelegate <NSObject>
@optional
- (void) adLoaded:(id<ATAppnextAd>)ad;
- (void) adOpened:(id<ATAppnextAd>)ad;
- (void) adClosed:(id<ATAppnextAd>)ad;
- (void) adClicked:(id<ATAppnextAd>)ad;
- (void) adUserWillLeaveApplication:(id<ATAppnextAd>)ad;
- (void) adError:(id<ATAppnextAd>)ad error:(NSString *)error;
@end

@protocol ATAppnextAdConfiguration<NSObject>
@property (nonatomic, strong) NSString *categories;
@property (nonatomic, strong) NSString *postback;
@property (nonatomic, strong) NSString *buttonText;
@property (nonatomic, strong) NSString *buttonColor;
@property (nonatomic, strong) NSString *preferredOrientation;
@end

@protocol ATAppnextAd<NSObject>
@property (nonatomic, weak) id<AppnextAdDelegate> delegate;

@property (nonatomic, strong) NSString *placementID;
@property (nonatomic, assign, readonly) BOOL adIsLoaded;

- (instancetype) init;
- (instancetype) initWithPlacementID:(NSString *)placement;
- (instancetype) initWithConfig:(id<ATAppnextAdConfiguration>)config;
- (instancetype) initWithConfig:(id<ATAppnextAdConfiguration>)config placementID:(NSString *)placement;
- (void) loadAd;
- (void) showAd;

- (void) setRewardsUserId:(NSString *)rewardsUserId;

#pragma mark - Setters/Getters

- (void) setCategories:(NSString *)categories;
- (NSString *) getCategories;
- (void) setPostback:(NSString *)postback;
- (NSString *) getPostback;
- (void) setButtonText:(NSString *)buttonText;
- (NSString *) getButtonText;
- (void) setButtonColor:(NSString *)buttonColor;
- (NSString *) getButtonColor;
- (void) setPreferredOrientation:(NSString *)preferredOrientation;
- (NSString *) getPreferredOrientation;

@end

@protocol AppnextVideoAdDelegate <AppnextAdDelegate>
@optional
- (void) videoEnded:(id<ATAppnextAd>)ad;
@end

@protocol ATAppnextRewardedServerSidePostbackParams;
@protocol ATAppnextRewardedVideoAd<ATAppnextAd>
@property (nonatomic, strong, readonly) id<ATAppnextRewardedServerSidePostbackParams> rewardedServerSidePostbackParams;
#pragma mark - Setters/Getters
- (void) setRewardedServerSidePostbackParams:(id<ATAppnextRewardedServerSidePostbackParams>) params;
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


@protocol ATAppnextRewardedServerSidePostbackParams<NSObject>
@property (nonatomic, strong) NSString *rewardsTransactionId;
@property (nonatomic, strong) NSString *rewardsUserId;
@property (nonatomic, strong) NSString *rewardsRewardTypeCurrency;
@property (nonatomic, strong) NSString *rewardsAmountRewarded;
@property (nonatomic, strong) NSString *rewardsCustomParameter;
@end

NS_ASSUME_NONNULL_END
