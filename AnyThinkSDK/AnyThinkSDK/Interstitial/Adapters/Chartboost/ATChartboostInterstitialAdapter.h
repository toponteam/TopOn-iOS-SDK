//
//  ATChartboostInterstitialAdapter.h
//  AnyThinkChartboostInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/9.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

extern NSString *const kChartboostInterstitialInitializedNotification;
extern NSString *const kChartboostInterstitialLoadedNotification;
extern NSString *const kChartboostInterstitialLoadingFailedNotification;
extern NSString *const kChartboostInterstitialImpressionNotification;
extern NSString *const kChartboostInterstitialClickNotification;
extern NSString *const kChartboostInterstitialCloseNotification;
extern NSString *const kChartboostInterstitialVideoEndNotification;

extern NSString *const kChartboostInterstitialNotificationUserInfoLocationKey;
extern NSString *const kChartboostInterstitialNotificationUserInfoErrorKey;
extern NSString *const kChartboostInterstitialNotificationUserInfoRewardedFlagKey;
@interface ATChartboostInterstitialAdapter : NSObject
@end

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

@protocol ChartboostDelegate;
@protocol ATChartboost<NSObject>
+ (NSString*)getSDKVersion;
+ (void)restrictDataCollection:(BOOL)shouldRestrict;
+ (void)startWithAppId:(NSString*)appId appSignature:(NSString*)appSignature delegate:(id<ChartboostDelegate>)delegate;
+ (BOOL)hasInterstitial:(NSString*)location;
+ (void)cacheInterstitial:(NSString*)location;
+ (void)showInterstitial:(NSString*)location;
@end

@protocol ChartboostDelegate <NSObject>
@optional
- (UIView*)customAgeGateView;
- (void)didInitialize:(BOOL)status;
#pragma mark - Interstitial Delegate
- (BOOL)shouldRequestInterstitial:(NSString*)location;
- (BOOL)shouldDisplayInterstitial:(NSString*)location;
- (void)didDisplayInterstitial:(NSString*)location;
- (void)didCacheInterstitial:(NSString*)location;
- (void)didFailToLoadInterstitial:(NSString*)location withError:(NSUInteger)error;
- (void)didFailToRecordClick:(NSString*)location withError:(NSUInteger)error;
- (void)didDismissInterstitial:(NSString*)location;
- (void)didCloseInterstitial:(NSString*)location;
- (void)didClickInterstitial:(NSString*)location;
@end

NS_ASSUME_NONNULL_END
