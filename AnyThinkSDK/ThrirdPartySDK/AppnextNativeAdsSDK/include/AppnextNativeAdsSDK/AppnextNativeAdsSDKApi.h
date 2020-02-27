//
//  AppnextNativeAdsSDKApi.h
//  AppnextNativeAdsSDK
//
//  Created by Eran Mausner on 16/08/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <AppnextNativeAdsSDK/AppnextNativeAdsRequest.h>

@protocol AppnextNativeAdsRequestDelegate <NSObject>
@optional
- (void) onAdsLoaded:(NSArray<AppnextAdData *> *)ads forRequest:(AppnextNativeAdsRequest *)request;
- (void) onError:(NSString *)error forRequest:(AppnextNativeAdsRequest *)request;
@end

@protocol AppnextNativeAdOpenedDelegate <NSObject>
@optional
- (void) storeOpened:(AppnextAdData *)adData;
- (void) onError:(NSString *)error forAdData:(AppnextAdData *)adData;
@end

@protocol AppnextPrivacyClickedDelegate <NSObject>
@optional
- (void) successOpeningAppnextPrivacy:(AppnextAdData *)adData;
- (void) failureOpeningAppnextPrivacy:(AppnextAdData *)adData;
@end

@interface AppnextNativeAdsSDKApi : NSObject

@property (nonatomic, strong, readonly) NSString *placementID;

#pragma mark - Class methods

/**
 *  Get the version of this library/framework
 *
 *  @return
 */
+ (NSString *) getNativeAdsSDKVersion;

#pragma mark - Public methods

- (instancetype) initWithPlacementID:(NSString *)placement withViewController:(UIViewController *) viewController;
- (void) setViewController:(UIViewController *) viewController;
- (void) loadAds:(AppnextNativeAdsRequest *)request withRequestDelegate:(id<AppnextNativeAdsRequestDelegate>)delegate;
- (void) adClicked:(AppnextAdData *)adData withAdOpenedDelegate:(id<AppnextNativeAdOpenedDelegate>)delegate;
- (void) adImpression:(AppnextAdData *)adData;
- (void) videoStarted:(AppnextAdData *)adData;
- (void) videoEnded:(AppnextAdData *)adData;
- (void) privacyClicked:(AppnextAdData *)adData withPrivacyClickedDelegate:(id<AppnextPrivacyClickedDelegate>)delegate;

@end
