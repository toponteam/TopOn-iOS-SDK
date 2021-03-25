//
//  ATKidozRewardedVideoAdapter.h
//  AnyThinkKidozAdapter
//
//  Created by Topon on 12/23/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kATKidozRewardedVideoLoadedNotification;
extern NSString *const kATKidozRewardedVideoFailedToLoadNotification;
extern NSString *const kATKidozRewardedVideoShowNotification;
extern NSString *const kATKidozRewardedVideoCloseNotification;
extern NSString *const kATKidozRewardedVideoRewardNotification;
extern NSString *const kATKidozRewardedVideoNotificationUserInfoErrorKey;

@interface ATKidozRewardedVideoAdapter : NSObject

@end

@protocol KDZInitDelegate <NSObject>
@optional
-(void)onInitSuccess;
-(void)onInitError:(NSString *)error;
@end

@protocol KDZRewardedDelegate <NSObject>
-(void)rewardedDidInitialize;
-(void)rewardedDidClose;
-(void)rewardedDidOpen;
-(void)rewardedIsReady;
-(void)rewardedReturnedWithNoOffers;
-(void)rewardedDidPause;
-(void)rewardedDidResume;
-(void)rewardedLoadFailed;
-(void)rewardedDidReciveError:(NSString*)errorMessage;
-(void)rewardReceived;
-(void)rewardedStarted;
-(void)rewardedLeftApplication;
@end

@protocol ATKidozSDK <NSObject>

+ (id)instance;

- (void)initializeWithPublisherID:(NSString *)publisherID securityToken:(NSString *)securityToken withDelegate:(id<KDZInitDelegate>)delegate;
- (void)initializeWithPublisherID:(NSString *)publisherID securityToken:(NSString *)securityToken;
- (BOOL)isSDKInitialized;

- (void)loadRewarded;
- (void)showRewarded;
- (BOOL)isRewardedInitialized;
- (BOOL)isRewardedReady;
- (void)initializeRewardedWithDelegate:(id<KDZRewardedDelegate>)delegate;
- (void)setRewardedDelegate:(id<KDZRewardedDelegate>)delegate;

@end
NS_ASSUME_NONNULL_END
