//
//  ATUnityAdsBaseManager.h
//  AnyThinkUnityAdsAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATNetworkBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATUnityAdsBaseManager : ATNetworkBaseManager

@end

@protocol UnityAdsDelegate <NSObject>
- (void)unityAdsReady:(NSString *)placementId;
- (void)unityAdsDidError:(NSInteger)error withMessage:(NSString *)message;
- (void)unityAdsDidStart:(NSString *)placementId;
- (void)unityAdsDidFinish:(NSString *)placementId
          withFinishState:(NSInteger)state;
@end

@protocol UnityAdsExtendedDelegate <UnityAdsDelegate>
- (void)unityAdsDidClick:(NSString *)placementId;
- (void)unityAdsPlacementStateChanged:(NSString *)placementId oldState:(NSInteger)oldState newState:(NSInteger)newState;
@end

@protocol ATUnityAds<NSObject>
+ (NSString *)getVersion;
+ (BOOL)isInitialized;
+ (void)initialize:(NSString *)gameId;
+ (void)addDelegate:(__nullable id<UnityAdsDelegate>)delegate;
+ (void)removeDelegate:(id<UnityAdsDelegate>)delegate;
+ (BOOL)isReady:(NSString *)placementId;
+ (void)show:(UIViewController *)viewController placementId:(NSString *)placementId;
@end

@protocol UADSPlayerMetaData<NSObject>
- (BOOL)set:(NSString *)key value:(id)value;
- (void)setServerId:(NSString *)serverId;
- (void)commit;
@end

NS_ASSUME_NONNULL_END
