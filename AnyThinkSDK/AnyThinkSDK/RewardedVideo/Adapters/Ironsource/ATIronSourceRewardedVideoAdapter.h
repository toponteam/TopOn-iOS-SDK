//
//  ATIronSourceRewardedVideoAdapter.h
//  AnyThinkIronSourceRewardedVideoAdapter
//
//  Created by Martin Lau on 09/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
extern NSString *const kATIronSourceRVNotificationLoaded;
extern NSString *const kATIronSourceRVNotificationLoadFailed;
extern NSString *const kATIronSourceRVNotificationShow;
extern NSString *const kATIronSourceRVNotificationShowFailed;
extern NSString *const kATIronSourceRVNotificationClick;
extern NSString *const kATIronSourceRVNotificationReward;
extern NSString *const kATIronSourceRVNotificationClose;

extern NSString *const kATIronSourceRVNotificationUserInfoInstanceIDKey;
extern NSString *const kATIronSourceRVNotificationUserInfoErrorKey;

@interface ATIronSourceRewardedVideoAdapter : NSObject
@end

@protocol ISDemandOnlyRewardedVideoDelegate;
@protocol ATIronSource<NSObject>
+ (void)setConsent:(BOOL)consent;
+ (NSString *)sdkVersion;
#pragma makr - mediation
//To be added

#pragma makr - demand only
+ (void)initISDemandOnly:(NSString *)appKey adUnits:(NSArray<NSString *> *)adUnits;
+ (void)setISDemandOnlyRewardedVideoDelegate:(id<ISDemandOnlyRewardedVideoDelegate>)delegate;
+ (void)loadISDemandOnlyRewardedVideo:(NSString *)instanceId;
+ (void)showISDemandOnlyRewardedVideo:(UIViewController *)viewController instanceId:(NSString *)instanceId;
+ (BOOL)hasISDemandOnlyRewardedVideo:(NSString *)instanceId;
@end

@protocol ATISPlacementInfo<NSObject>
@property (readonly) NSString *placementName;
@property (readonly) NSString *rewardName;
@property (readonly) NSNumber *rewardAmount;
@end

@protocol ISDemandOnlyRewardedVideoDelegate <NSObject>
@required
- (void)rewardedVideoDidLoad:(NSString *)instanceId;
- (void)rewardedVideoDidFailToLoadWithError:(NSError *)error instanceId:(NSString *)instanceId;
- (void)rewardedVideoDidOpen:(NSString *)instanceId;
- (void)rewardedVideoDidClose:(NSString *)instanceId;
- (void)rewardedVideoDidFailToShowWithError:(NSError *)error instanceId:(NSString *)instanceId;
- (void)rewardedVideoDidClick:(NSString *)instanceId;
- (void)rewardedVideoAdRewarded:(NSString *)instanceId;
@end
