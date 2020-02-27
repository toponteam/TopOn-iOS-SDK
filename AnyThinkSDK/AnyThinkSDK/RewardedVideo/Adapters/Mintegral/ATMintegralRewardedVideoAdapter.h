//
//  ATMintegralRewardedVideoAdapter.h
//  AnyThinkMintegralRewardedVideoAdapter
//
//  Created by Martin Lau on 05/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ATRewardedVideoAdapter.h"
typedef NS_ENUM(NSInteger, ATRVMTGUserPrivateType) {
    ATRVMTGUserPrivateType_ALL         = 0,
    ATRVMTGUserPrivateType_GeneralData = 1,
    ATRVMTGUserPrivateType_DeviceId    = 2,
    ATMTRVGUserPrivateType_Gps         = 3,
};
@interface ATMintegralRewardedVideoAdapter : NSObject<ATRewardedVideoAdapter>
@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);
@end

@protocol ATRVMTGSDK<NSObject>
+ (nonnull instancetype)sharedInstance;
- (void)setAppID:(nonnull NSString *)appID ApiKey:(nonnull NSString *)apiKey;
- (void)setUserPrivateInfoType:(ATRVMTGUserPrivateType)type agree:(BOOL)agree;
@property (nonatomic, assign) BOOL consentStatus;
@end

@protocol ATRVMTGRewardAdInfo<NSObject>
@end

@protocol ATRVMTGRewardAdLoadDelegate;
@protocol ATRVMTGRewardAdShowDelegate;
@protocol ATRVMTGRewardAdManager<NSObject>
+ (nonnull instancetype)sharedInstance;
- (void)loadVideo:(nonnull NSString *)unitId delegate:(nullable id <ATRVMTGRewardAdLoadDelegate>)delegate;
- (void)showVideo:(nonnull NSString *)unitId withRewardId:(nonnull NSString *)rewardId userId:(nullable NSString *)userId delegate:(nullable id <ATRVMTGRewardAdShowDelegate>)delegate viewController:(nonnull UIViewController*)viewController;
- (BOOL)isVideoReadyToPlay:(nonnull NSString *)unitId;
- (void)cleanAllVideoFileCache;
@end

@protocol ATRVMTGRewardAdLoadDelegate <NSObject>
@optional
- (void)onVideoAdLoadSuccess:(nullable NSString *)unitId;
- (void)onVideoAdLoadFailed:(nullable NSString *)unitId error:(nonnull NSError *)error;
- (void)onAdLoadSuccess:(nullable NSString *)unitId;
@end

@protocol ATRVMTGRewardAdShowDelegate <NSObject>
@optional
- (void)onVideoAdShowSuccess:(nullable NSString *)unitId;
- (void)onVideoAdShowFailed:(nullable NSString *)unitId withError:(nonnull NSError *)error;
- (void)onVideoAdClicked:(nullable NSString *)unitId;
- (void)onVideoAdDismissed:(nullable NSString *)unitId withConverted:(BOOL)converted withRewardInfo:(id<ATRVMTGRewardAdInfo>)rewardInfo;
@end

@protocol ATMTGBidRewardAdManager<NSObject>
@property (nonatomic, assign) BOOL  playVideoMute;
+ (nonnull instancetype)sharedInstance;
- (void)loadVideoWithBidToken:(nonnull NSString *)bidToken unitId:(nonnull NSString *)unitId delegate:(nullable id <ATRVMTGRewardAdLoadDelegate>)delegate;
- (void)showVideo:(nonnull NSString *)unitId withRewardId:(nonnull NSString *)rewardId userId:(nullable NSString *)userId delegate:(nullable id <ATRVMTGRewardAdShowDelegate>)delegate viewController:(nonnull UIViewController*)viewController;
- (BOOL)isVideoReadyToPlay:(nonnull NSString *)unitId;
@end
