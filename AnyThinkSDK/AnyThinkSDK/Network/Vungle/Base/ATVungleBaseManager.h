//
//  ATVungleBaseManager.h
//  AnyThinkVungleAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATNetworkBaseManager.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATVungleBaseManager : ATNetworkBaseManager

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
- (BOOL)loadPlacementWithID:(NSString *)placementID withSize:(NSInteger)size error:(NSError **)error;
- (BOOL)addAdViewToView:(UIView *)publisherView withOptions:(NSDictionary *)options placementID:(NSString *)placementID error:(NSError *__autoreleasing*)error;
- (void)finishedDisplayingAd;
- (void)updateCCPAStatus:(NSInteger)status;
@end

@protocol ATVungleSDKDelegate <NSObject>
@optional
- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(nullable NSString *)placementID error:(nullable NSError *)error;
- (void)vungleDidShowAdForPlacementID:(nullable NSString *)placementID;
- (void)vungleTrackClickForPlacementID:(nullable NSString *)placementID;
- (void)vungleRewardUserForPlacementID:(nullable NSString *)placementID;
- (void)vungleDidCloseAdForPlacementID:(nonnull NSString *)placementID;
- (void)vungleSDKDidInitialize;
- (void)vungleSDKFailedToInitializeWithError:(NSError *)error;
@end

NS_ASSUME_NONNULL_END
