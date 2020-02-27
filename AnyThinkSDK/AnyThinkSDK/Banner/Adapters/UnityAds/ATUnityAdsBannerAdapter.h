//
//  ATUnityAdsBannerAdapter.h
//  AnyThinkUnityAdsBannerAdapter
//
//  Created by Martin Lau on 2018/12/25.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kATUnityAdsBannerNotificationLoaded;
extern NSString *const kATUnityAdsBannerNotificationShow;
extern NSString *const kATUnityAdsBannerNotificationClick;
extern NSString *const kATUnityAdsBannerNotificationUserInfoPlacementIDKey;
extern NSString *const kATUnityAdsBannerNotificationUserInfoViewKey;
@interface ATUnityAdsBannerAdapter : NSObject

@end

@protocol UnityAdsDelegate;
@protocol ATUnityAds<NSObject>
+ (NSString *)getVersion;
+ (BOOL)isInitialized;
+ (BOOL)isReady:(NSString *)placementId;
+ (void)initialize:(NSString *)gameId delegate:(nullable id<UnityAdsDelegate>)delegate;
+ (void)initialize:(NSString *)gameId delegate:(nullable id<UnityAdsDelegate>)delegate testMode:(BOOL)testMode;
@end

@protocol UnityAdsDelegate <NSObject>
- (void)unityAdsReady:(NSString *)placementId;
- (void)unityAdsDidError:(NSInteger)error withMessage:(NSString *)message;
- (void)unityAdsDidStart:(NSString *)placementId;
- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(NSInteger)state;
@end

@protocol UADSPlayerMetaData<NSObject>
- (BOOL)set:(NSString *)key value:(id)value;
- (void)setServerId:(NSString *)serverId;
- (void)commit;
@end

@protocol UnityAdsBannerDelegate <NSObject>
-(void)unityAdsBannerDidLoad:(NSString *)placementId view:(UIView *)view;
-(void)unityAdsBannerDidUnload:(NSString *)placementId;
-(void)unityAdsBannerDidShow:(NSString *)placementId;
-(void)unityAdsBannerDidHide:(NSString *)placementId;
-(void)unityAdsBannerDidClick:(NSString *)placementId;
-(void)unityAdsBannerDidError:(NSString *)message;
@end

@protocol UnityAdsBanner<NSObject>
+(void)setBannerPosition:(NSInteger)position;
+(void)loadBanner;
+(void)loadBanner:(NSString *)placementId;
+(void)destroy;
+(nullable id <UnityAdsBannerDelegate>)getDelegate;
+(void)setDelegate:(id<UnityAdsBannerDelegate>)delegate;
@end
