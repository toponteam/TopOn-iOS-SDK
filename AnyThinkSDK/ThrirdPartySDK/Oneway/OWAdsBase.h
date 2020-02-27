//
//  OWAdsBase.h
//  OneWaySDK
//
//  Created by lch on 2017/12/5.
//  Copyright © 2017年 mobi.oneway. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OneWaySDKAdType) {
    kOneWaySDKAdTypeUnknow = 0,
    kOneWaySDKAdTypeRewarded,
    kOneWaySDKAdTypeFeed,
    kOneWaySDKAdTypeInterstitial,
    kOneWaySDKAdTypeBanner,
    kOneWaySDKAdTypeRecommend,
    kOneWaySDKAdTypeInterstitialImage
};

typedef NS_ENUM(NSInteger, OneWaySDKPlacementState) {
    kOneWaySDKPlacementStateReady,
    kOneWaySDKPlacementStateNotAvailable,
    kOneWaySDKPlacementStateDisabled,
    kOneWaySDKPlacementStateWaiting,
    kOneWaySDKPlacementStateNoFill
};

typedef NS_ENUM(NSInteger, OneWaySDKError) {
    kOneWaySDKErrorNotInitialized = 0,
    kOneWaySDKErrorInitializedFailed,
    kOneWaySDKErrorInvalidArgument,
    kOneWaySDKErrorVideoPlayerError,
    kOneWaySDKErrorInitSanityCheckFail,
    kOneWaySDKErrorAdBlockerDetected,
    kOneWaySDKErrorFileIoError,
    kOneWaySDKErrorDeviceIdError,
    kOneWaySDKErrorShowError,
    kOneWaySDKErrorInternalError,
    kOneWaySDKCampaignNoFill,
};


@interface OWAdsBase : NSObject
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)initialize NS_UNAVAILABLE;



+ (void)initWithDelegate:(id)delegate type:(OneWaySDKAdType)type;

+ (void)show:(UIViewController *)viewController adType:(OneWaySDKAdType)adType fullScreen:(BOOL)isFullScreen tag:(NSString *)tag;

+ (BOOL)isReady:(OneWaySDKAdType)adType;

+ (void)receivedMessage:(NSString *)message placement:(NSString *)placement errorEvent:(NSString *)errorString;

+ (void)resendRequest ;

+ (void)handle:(id)delegate error:(OneWaySDKError)errorCode message:(NSString *)message;
@end
