//
//  ATVungleRewardedVideoAdapter.h
//  AnyThinkVungleRewardedVideoAdapter
//
//  Created by Martin Lau on 11/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
extern NSString *const kVungleRewardedVideoLoadNotification;
extern NSString *const kVungleRewardedVideoShowNotification;
extern NSString *const kVungleRewardedVideoCloseNotification;
extern NSString *const kVungleRewardedVideoNotificationUserInfoPlacementIDKey;
extern NSString *const kVungleRewardedVideoNotificationUserInfoErrorKey;
extern NSString *const kVungleRewardedVideoNotificationUserInfoVideoCompletedFlagKey;
extern NSString *const kVungleRewardedVideoNotificationUserInfoClickFlagKey;

@interface ATVungleRewardedVideoAdapter : NSObject
@end

@protocol ATVungleSDKDelegate;
@protocol ATVungleSDK<NSObject>
@property (strong) NSDictionary *userData;
@property (nullable, strong) id<ATVungleSDKDelegate> delegate;
@property (assign) BOOL muted;
@property (atomic, readonly, getter=isInitialized) BOOL initialized;
+ (instancetype)sharedSDK;
- (void)updateConsentStatus:(NSInteger)status consentMessageVersion:(NSString *)version;
- (BOOL)startWithAppId:(nonnull NSString *)appID error:(NSError **)error;
- (BOOL)playAd:(UIViewController *)controller options:(nullable NSDictionary *)options placementID:(nullable NSString *)placementID error:( NSError *__autoreleasing _Nullable *_Nullable)error;
- (BOOL)isAdCachedForPlacementID:(nonnull NSString *)placementID;
- (BOOL)loadPlacementWithID:(NSString *)placementID error:(NSError **)error;
@end

@protocol ATVungleViewInfo<NSObject>
/**
 * Represents a BOOL whether or not the video can be considered a full view.
 */
@property (nonatomic, readonly) NSNumber *completedView;

/**
 * The time in seconds that the user watched the video.
 */
@property (nonatomic, readonly) NSNumber *playTime;

/**
 * Represents a BOOL whether or not the user clicked the download button.
 */
@property (nonatomic, readonly) NSNumber *didDownload;
@end

@protocol ATVungleSDKDelegate <NSObject>
@optional
- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(nullable NSString *)placementID error:(nullable NSError *)error;
- (void)vungleWillShowAdForPlacementID:(nullable NSString *)placementID;
- (void)vungleWillCloseAdWithViewInfo:(nonnull id<ATVungleViewInfo>)info placementID:(nonnull NSString *)placementID;
- (void)vungleDidCloseAdWithViewInfo:(nonnull id<ATVungleViewInfo>)info placementID:(nonnull NSString *)placementID;
- (void)vungleSDKDidInitialize;
- (void)vungleSDKFailedToInitializeWithError:(NSError *)error;
@end
