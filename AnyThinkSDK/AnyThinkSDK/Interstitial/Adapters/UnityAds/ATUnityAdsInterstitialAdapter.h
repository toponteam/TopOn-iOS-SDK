//
//  ATUnityAdsInterstitialAdapter.h
//  AnyThinkUnityAdsInterstitialAdapter
//
//  Created by Martin Lau on 2018/12/25.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kATUnityAdsInterstitialLoadedNotification;
extern NSString *const kATUnityAdsInterstitialFailedToLoadNotification;
extern NSString *const kATUnityAdsInterstitialPlayStartNotification;
extern NSString *const kATUnityAdsInterstitialClickNotification;
extern NSString *const kATUnityAdsInterstitialCloseNotification;
extern NSString *const kATUnityAdsInterstitialNotificationUserInfoPlacementIDKey;
extern NSString *const kATUnityAdsInterstitialNotificationUserInfoErrorKey;


@interface ATUnityAdsInterstitialAdapter : NSObject
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

@protocol UnityServicesDelegate <NSObject>
- (void)unityServicesDidError:(NSInteger)error withMessage:(NSString *)message;
@end

@protocol UMONShowAdPlacementContent;
@protocol UnityMonetizationDelegate <UnityServicesDelegate>
-(void)placementContentReady:(NSString *)placementId placementContent:(id<UMONShowAdPlacementContent>)decision;
-(void)placementContentStateDidChange:(NSString *)placementId placementContent:(id<UMONShowAdPlacementContent>)placementContent previousState:(NSInteger)previousState newState:(NSInteger)newState;
@end

@protocol UnityMonetization<NSObject>
+(void)setDelegate:(id <UnityMonetizationDelegate>)delegate;
+(nullable id <UnityMonetizationDelegate>)getDelegate;
+(BOOL)isReady:(NSString *)placementId;
+ (void)initialize:(NSString *)gameId delegate:(nullable id<UnityMonetizationDelegate>)delegate;
+ (void)initialize:(NSString *)gameId delegate:(nullable id<UnityMonetizationDelegate>)delegate testMode:(BOOL)testMode;
@end

@protocol UMONShowAdDelegate <NSObject>
-(void)unityAdsDidStart:(NSString*)placementId;
-(void)unityAdsDidFinish:(NSString*)placementId withFinishState:(NSInteger)finishState;
@end

@protocol UMONShowAdPlacementContent<NSObject>
-(instancetype)initWithPlacementId:(NSString *)placementId withParams:(NSDictionary *)params;
@property(nonatomic, readonly, getter=isReady) BOOL ready;
@property (strong, nonatomic) id<UMONShowAdDelegate> delegate;
-(void)show:(UIViewController *)viewController;
-(void)show:(UIViewController *)viewController withDelegate:(id<UMONShowAdDelegate>)delegate;
@end
