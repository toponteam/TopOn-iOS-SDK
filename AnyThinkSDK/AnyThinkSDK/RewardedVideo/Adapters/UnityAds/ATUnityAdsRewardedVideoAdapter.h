//
//  ATUnityAdsRewardedVideoAdapter.h
//  AnyThinkUnityAdsRewardedVideoAdapter
//
//  Created by Martin Lau on 11/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ATUnityAdsPlacementState) {
    kATUnityAdsPlacementStateReady,
    kATUnityAdsPlacementStateNotAvailable,
    kATUnityAdsPlacementStateDisabled,
    kATUnityAdsPlacementStateWaiting,
    kATUnityAdsPlacementStateNoFill
};

typedef NS_ENUM(NSInteger, ATUnityAdsFinishState) {
    kATUnityAdsFinishStateError,
    kATUnityAdsFinishStateSkipped,
    kATUnityAdsFinishStateCompleted
};

typedef NS_ENUM(NSInteger, ATUnityAdsError) {
    kATUnityAdsErrorNotInitialized = 0,
    kATUnityAdsErrorInitializedFailed,
    kATUnityAdsErrorInvalidArgument,
    kATUnityAdsErrorVideoPlayerError,
    kATUnityAdsErrorInitSanityCheckFail,
    kATUnityAdsErrorAdBlockerDetected,
    kATUnityAdsErrorFileIoError,
    kATUnityAdsErrorDeviceIdError,
    kATUnityAdsErrorShowError,
    kATUnityAdsErrorInternalError,
};

@interface ATUnityAdsRewardedVideoAdapter : NSObject
@end

@protocol ATUnityAds<NSObject>
+ (NSString *)getVersion;
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
