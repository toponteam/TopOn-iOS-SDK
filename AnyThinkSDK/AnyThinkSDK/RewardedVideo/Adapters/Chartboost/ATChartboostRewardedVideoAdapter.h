//
//  ATChartboostRewardedVideoAdapter.h
//  ATChartboostRewardedVideoAdapter
//
//  Created by Martin Lau on 10/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATRewardedVideoAdapter.h"
extern NSString *const kChartboostRewardedVideoInitializedNotification;
extern NSString *const kChartboostRewardedVideoLoadedNotification;
extern NSString *const kChartboostRewardedVideoLoadingFailedNotification;
extern NSString *const kChartboostRewardedVideoImpressionNotification;
extern NSString *const kChartboostRewardedVideoClickNotification;
extern NSString *const kChartboostRewardedVideoCloseNotification;
extern NSString *const kChartboostRewardedVideoVideoEndNotification;

extern NSString *const kChartboostRewardedVideoNotificationUserInfoLocationKey;
extern NSString *const kChartboostRewardedVideoNotificationUserInfoErrorKey;
extern NSString *const kChartboostRewardedVideoNotificationUserInfoRewardedFlagKey;

typedef NS_ENUM(NSUInteger, ATCBLoadError) {
    /*! Unknown internal error. */
    ATCBLoadErrorInternal = 0,
    /*! Network is currently unavailable. */
    ATCBLoadErrorInternetUnavailable = 1,
    /*! Too many requests are pending for that location.  */
    ATCBLoadErrorTooManyConnections = 2,
    /*! Interstitial loaded with wrong orientation. */
    ATCBLoadErrorWrongOrientation = 3,
    /*! Interstitial disabled, first session. */
    ATCBLoadErrorFirstSessionInterstitialsDisabled = 4,
    /*! Network request failed. */
    ATCBLoadErrorNetworkFailure = 5,
    /*!  No ad received. */
    ATCBLoadErrorNoAdFound = 6,
    /*! Session not started. */
    ATCBLoadErrorSessionNotStarted = 7,
    /*! There is an impression already visible.*/
    ATCBLoadErrorImpressionAlreadyVisible = 8,
    /*! User manually cancelled the impression. */
    ATCBLoadErrorUserCancellation = 10,
    /*! No location detected. */
    ATCBLoadErrorNoLocationFound = 11,
    /*! Error downloading asset. */
    ATCBLoadErrorAssetDownloadFailure = 16,
    /*! Video Prefetching is not finished */
    ATCBLoadErrorPrefetchingIncomplete = 21,
    /*! Error Originating from the JS side of a Web View */
    ATCBLoadErrorWebViewScriptError = 22,
    /*! Network is unavailable while attempting to show. */
    ATCBLoadErrorInternetUnavailableAtShow = 25
};
@interface ATChartboostRewardedVideoAdapter : NSObject
@end

@protocol ChartboostDelegate;
@protocol ATChartboost<NSObject>
+ (NSString*)getSDKVersion;
+ (void)restrictDataCollection:(BOOL)shouldRestrict;
+ (void)setCustomId:(NSString *)customId;
+ (void)startWithAppId:(NSString*)appId appSignature:(NSString*)appSignature delegate:(id<ChartboostDelegate>)delegate;
+ (BOOL)hasRewardedVideo:(NSString*)location;
+ (void)cacheRewardedVideo:(NSString*)location;
+ (void)showRewardedVideo:(NSString*)location;
@end

@protocol ChartboostDelegate <NSObject>
@end
