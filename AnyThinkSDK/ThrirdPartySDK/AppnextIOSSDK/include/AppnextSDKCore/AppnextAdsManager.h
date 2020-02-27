//
//  AppnextAdsManager.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 11/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <AppnextSDKCore/AppnextAdsContainerDelegate.h>
#import <AppnextSDKCore/AppnextAd.h>
#import <AppnextSDKCore/AppnextConfigurationForRequest.h>
#import "AppnextAdsContainer.h"
#import <AppnextSDKCore/AppnextSDKCoreDefs.h>
#import <AppnextSDKCore/AppnextSettingsManager.h>

@interface AppnextAdsManager : NSObject

AS_SINGLETON(AppnextAdsManager)

- (void) getAdsListAndResources:(AppnextConfigurationForRequest *)configurationForRequest withAppnextSettingsManager:(AppnextSettingsManager*) settingsManager withDelegate:(id<AppnextAdsContainerDelegate>)delegate;
- (AppnextAdData *) getAttachedBannerToContainer:(id<AppnextAdsContainerProtocol>)container;
- (BOOL) shouldGetVideoForBanner:(AppnextAdData *)adData withAd:(AppnextConfigurationForRequest *)configurationForRequest;
//- (BOOL) shouldSendPostViewForBanner:(AppnextAdData *)adData withAd:(AppnextAd *)ad;
- (NSString *) getVideoResourcePathForBanner:(AppnextAdData *)adData withAd:(AppnextConfigurationForRequest *)configurationForRequest;
- (NSString *) getImageForVideoResourcePathForBanner:(AppnextAdData *)adData withAd:(AppnextConfigurationForRequest *)configurationForRequest;
- (NSString *) getImageWideForVideoResourcePathForBanner:(AppnextAdData *)adData withAd:(AppnextConfigurationForRequest *)configurationForRequest;
- (BOOL) hasAdNotShownOnContainer:(AppnextAdsContainer *)adsContainer;
- (NSString *) prepareJSONForAd:(AppnextConfigurationForRequest *)configurationForRequest;
- (void) detachBannerFromAd:(AppnextConfigurationForRequest *)configurationForRequest wasShown:(BOOL)shown;

@end
