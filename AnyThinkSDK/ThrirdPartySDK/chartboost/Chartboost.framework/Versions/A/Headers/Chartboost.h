//
//  Chartboost.h
//  Chartboost
//
//  Copyright 2018 Chartboost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ChartboostDelegate.h"
#import "CHBInterstitial.h"
#import "CHBRewarded.h"
#import "CHBBanner.h"
@class CBInPlay;

FOUNDATION_EXPORT BOOL ChartboostInitialized(const char* function) DEPRECATED_MSG_ATTRIBUTE("This function is deprecated and will be removed in a future version.");

@interface Chartboost : NSObject

/*!
 @abstract
 Start Chartboost with required appId, appSignature and delegate.
 
 @param appId The Chartboost application ID for this application.
 
 @param appSignature The Chartboost application signature for this application.
 
 @param completion A completion block to be executed when the SDK finishes initializing.
 It takes a boolean parameter which indicates if the initialization succeeded or not.
 
 @discussion This method must be executed before any other Chartboost SDK methods can be used.
 Once executed this call will also controll session tracking and background tasks
 used by Chartboost.
 */
+ (void)startWithAppId:(NSString*)appId appSignature:(NSString*)appSignature completion:(void (^)(BOOL))completion;

/*!
 @abstract
 Returns the version of the Chartboost SDK.
 */
+ (NSString*)getSDKVersion;

/*!
 @abstract
 Set the logging level
 
 @param loggingLevel The minimum level that's going to be logged
 
 @discussion Logging by default is off.
 */

+ (void)setLoggingLevel:(CBLoggingLevel)loggingLevel;

/*!
 @abstract
 Set a custom identifier to send in the POST body for all Chartboost API server requests.
 
 @param customId The identifier to send with all Chartboost API server requests.
 
 @discussion Use this method to set a custom identifier that can be used later in the Chartboost
 dashboard to group information by.
 */
+ (void)setCustomId:(NSString *)customId;

/*!
 @abstract
 Get the current custom identifier being sent in the POST body for all Chartboost API server requests.
 
 @return The identifier being sent with all Chartboost API server requests.
 
 @discussion Use this method to get the custom identifier that can be used later in the Chartboost
 dashboard to group information by.
 */
+ (NSString *)getCustomId;

/*!
 @abstract
 Set a custom version to append to the POST body of every request. This is useful for analytics and provides chartboost with important information.
 example: [Chartboost setChartboostWrapperVersion:@"6.4.6"];
 
 @param chartboostWrapperVersion The version sent as a string.
 
 @discussion This is an internal method used via Chartboost's Unity and Corona SDKs
 to track their usage.
 */
+ (void)setChartboostWrapperVersion:(NSString*)chartboostWrapperVersion;

/*!
 @abstract
 Set a custom framework suffix to append to the POST headers field.
 example setFramework:Unity withVersion:4.6, setFrameworkVersion:5.2.1
 
 @param framework The suffix to send with all Chartbooost API server requets.
 @param version The platform version used for analytics. Example Unity should set Application.unityVersion
 
 @discussion This is an internal method used via Chartboost's Unity and Corona SDKs
 to track their usage.
 */
+ (void)setFramework:(CBFramework)framework withVersion:(NSString *)version;

/*!
 @abstract
 Decide if Chartboost SDKK will attempt to fetch videos from the Chartboost API servers.
 
 @param shouldPrefetch YES if Chartboost should prefetch video content, NO otherwise.
 
 @discussion Set to control if Chartboost SDK control if videos should be prefetched.
 
 Default is YES.
 */
+ (void)setShouldPrefetchVideoContent:(BOOL)shouldPrefetch;

/*!
 @abstract
 returns YES if auto IAP tracking is enabled, NO if it isn't.
 
 @discussion Call to check if automatic tracking of in-app purchases is enabled.
 The setting is controlled by the server.
 */
+ (BOOL)getAutoIAPTracking;

/*!
 @abstract
 Mute/unmute chartboost ads.
 @param mute YES all sounds, NO activates them. Default is NO
 @discussion default value is NO
 */
+ (void)setMuted:(BOOL)mute;

/*!
 @abstract
 Set to restrict Chartboost's ability to collect personal data from the device. See CBPIDataUseConsent declaration for details
 Note: This method should be called before starting the Chartboost SDK with startWithAppId:appSignature:delegate.
 @param consent set the consent level
 @discussion Default value is Unknown
 */
+ (void)setPIDataUseConsent:(CBPIDataUseConsent)consent;

/*!
 @abstract
 Get the current consent setting
 */
+ (CBPIDataUseConsent)getPIDataUseConsent;

#pragma mark - Deprecated
+ (void)restrictDataCollection:(BOOL)shouldRestrict __attribute__((deprecated("Use setPIDataUseConsent:(CBPIDataUseConsent)consent instead")));
+ (void)setStatusBarBehavior:(CBStatusBarBehavior)statusBarBehavior __attribute__((deprecated("This method is deprecated and is a no-op")));
+ (void)setMediation:(CBMediation)library withVersion:(NSString*)libraryVersion DEPRECATED_MSG_ATTRIBUTE("Please use setMediation:withLibraryVersion:adapterVersion: instead.");
+ (void)cacheInPlay:(CBLocation)location DEPRECATED_MSG_ATTRIBUTE("This is a deprecated no-op method and will be removed in a future version.");
+ (BOOL)hasInPlay:(CBLocation)location DEPRECATED_MSG_ATTRIBUTE("This is a deprecated no-op method and will be removed in a future version.");
+ (CBInPlay *)getInPlay:(CBLocation)location DEPRECATED_MSG_ATTRIBUTE("This is a deprecated no-op method and will be removed in a future version.");
+ (void)startWithAppId:(NSString*)appId appSignature:(NSString*)appSignature delegate:(id<ChartboostDelegate>)delegate DEPRECATED_MSG_ATTRIBUTE("Please use +[Chartboost startWithAppId:appSignature:completion:] instead.");
+ (BOOL)isAnyViewVisible DEPRECATED_MSG_ATTRIBUTE("This method is deprecated and will be removed in a future version.");
+ (BOOL)hasInterstitial:(CBLocation)location DEPRECATED_MSG_ATTRIBUTE("Please use -[CHBInterstitial isCached] instead.");
+ (BOOL)hasRewardedVideo:(CBLocation)location DEPRECATED_MSG_ATTRIBUTE("Please use -[CHBRewarded isCached] instead.");
+ (void)cacheInterstitial:(CBLocation)location DEPRECATED_MSG_ATTRIBUTE("Please use -[CHBInterstitial cache] instead.");
+ (void)showInterstitial:(CBLocation)location DEPRECATED_MSG_ATTRIBUTE("Please use -[CHBInterstitial showFromViewController:] instead.");
+ (void)cacheRewardedVideo:(CBLocation)location DEPRECATED_MSG_ATTRIBUTE("Please use -[CHBRewarded cache] instead.");
+ (void)showRewardedVideo:(CBLocation)location DEPRECATED_MSG_ATTRIBUTE("Please use -[CHBRewarded showFromViewController:] instead.");
+ (void)setDelegate:(id<ChartboostDelegate>)del DEPRECATED_MSG_ATTRIBUTE("This method is deprecated and will be removed in a future version.");
+ (void)didPassAgeGate:(BOOL)pass DEPRECATED_MSG_ATTRIBUTE("Please use -[CHBAdDelegate shouldConfirmClick:confirmationHandler:] instead.");
+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication DEPRECATED_MSG_ATTRIBUTE("This method is deprecated and will be removed in a future version.");
+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation DEPRECATED_MSG_ATTRIBUTE("This method is deprecated and will be removed in a future version.");
+ (void)setShouldRequestInterstitialsInFirstSession:(BOOL)shouldRequest DEPRECATED_MSG_ATTRIBUTE("This method is deprecated and will be removed in a future version.");
+ (void)setShouldPauseClickForConfirmation:(BOOL)shouldPause DEPRECATED_MSG_ATTRIBUTE("Please use -[CHBAdDelegate shouldConfirmClick:confirmationHandler:] instead.");
+ (void)setAutoCacheAds:(BOOL)shouldCache DEPRECATED_MSG_ATTRIBUTE("This method is deprecated and will be removed in a future version.");
+ (BOOL)getAutoCacheAds DEPRECATED_MSG_ATTRIBUTE("This method is deprecated and will be removed in a future version.");
+ (void)setMediation:(CBMediation)library withLibraryVersion:(NSString*)libraryVersion adapterVersion:(NSString*)adapterVersion DEPRECATED_MSG_ATTRIBUTE("Please use CHBMediation as specified in Chartboost+Mediation.h instead.");

@end
