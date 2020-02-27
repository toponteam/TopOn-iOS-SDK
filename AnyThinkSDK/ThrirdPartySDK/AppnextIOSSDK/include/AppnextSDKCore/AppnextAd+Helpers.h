//
//  AppnextAd+Helpers.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 21/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <AppnextSDKCore/AppnextAd.h>
#import <AppnextSDKCore/AppnextSettingsManager.h>
#import <AppnextSDKCore/AppnextAdData.h>
#import <AppnextSDKCore/AppnextAdData+InternalExtras.h>
#import <AppnextSDKCore/AppnextUIViewController.h>

@interface AppnextAd()

@property (nonatomic, strong) NSString *impression;

- (void) hideAd;

#pragma mark - Setters/Getters

- (NSString *) VID;
- (NSString *) TID;
- (NSString *) AUID;
- (NSString *) adsType;
- (NSString *) getActionPrefix;
- (void) setCount:(NSUInteger)count;
- (NSUInteger) getCount;

@end

@interface AppnextAd(Helpers)<AppnextUIViewControllerDelegate, AppnextRedirectResolveManagerDelegate, OpenLinkHelperDelegate>

#pragma mark - Class Methods

+ (ANPositionInViewType) getANPositionInViewTypeFromString:(NSString *)positionInViewString;
+ (ANPreferredOrientationType) getANPreferredOrientationTypeFromString:(NSString *)preferredOrientationTypeString;
+ (ANPostViewLocation) getANPostViewLocationFromString:(NSString *)postViewLocationString;
+ (void) sendImpressionForUrl:(NSString *)impressionUrl;

#pragma mark - Public Methods

- (AppnextConfigurationForRequest * )convertToAppnextConfigurationForRequest;
- (AppnextSettingsManager *) getSettingsManager;
- (NSString *) getOfferWallUrlExtensionForAdWithCount;
- (void) reportEventWithTID:(NSString *)tid
                       auid:(NSString *)auid
                        vid:(NSString *)vid
                placementID:(NSString *)pid
                  sessionID:(NSString *)sessionID
                  eventName:(NSString *)ref
                    adsType:(NSString *)adsType
                   bannerID:(NSString *)bid
                 campaignID:(NSString *)cid;
- (void) reportEventWithSessionID:(NSString *)sessionID eventName:(NSString *)ref bannerID:(NSString *)bid campaignID:(NSString *)cid;
- (void) reportEventWithSessionID:(NSString *)sessionID data:(NSString *)data;
- (void) reportEventWithSessionID:(NSString *)sessionID action:(NSString *)action;
- (void) onInstallClickedWithClickedBanner:(AppnextAdData *)banner;
- (void) onOpenUrlFromAd:(NSString *)url;

#pragma mark - Overridable Methods

- (AppnextUIViewController *) getAdViewController;
- (UIViewController *) getCurrentViewController;
- (AppnextResourceLoader *) getScriptLoader;
- (NSString *) getWebEmbeddedHTML;
- (NSDictionary *) getWebScriptParams:(AppnextAdData *)adData; // To be overrided by each ad that shows a web view with script
- (BOOL) adShouldLoadAutomaticallyOnShow;
- (BOOL) adShouldUseAdsManager;
- (time_t) adResponseValidityPeriod;
- (BOOL) adShouldSendPostView;
- (BOOL) adTriggersPostViewFromWebView;
- (BOOL) adRequiresImage;
- (BOOL) adRequiresVideo;
- (BOOL) adShouldAttachBanner;
- (BOOL) adNeedsVideoDownloaded;
- (BOOL) adShouldSendImpressionOnShow;

#pragma mark - Settings Methods

- (NSTimeInterval) getResolveTimeoutForAd;
- (NSString *) getButtonTextForAd:(AppnextAdData *)adData;
- (NSString *) getButtonColorForAd;
- (NSInteger) getButtonWidthForAd;
- (NSInteger) getButtonHeightForAd;
- (ANPositionInViewType) getButtonPositionForAd;
- (BOOL) getShowInstallForAd;
- (BOOL) getShowIconForAd;
- (BOOL) getShowNameAppForAd;
- (BOOL) getShowRatingForAd;
- (BOOL) getShowDescForAd;
- (BOOL) getUrlAppProtectionForAd;
- (NSString *) getBackgroundColorForAd;

- (ANCreativeType) getCreativeForAd;
- (NSString *) getSkipTextForAd;
- (BOOL) getAutoPlayForAd;
- (BOOL) getRemovePosterOnAutoPlayForAd;

- (BOOL) getMuteForAd;
- (ANProgressType) getProgressTypeForAd;
- (UIColor *) getProgressColorForAd;
- (NSTimeInterval) getProgressDelayForAd;
- (ANVideoLength) getVideoLengthTypeForAd;
- (NSString *) getVideoLengthStringForAd;
- (NSString *) getVideoUrlStringForAd:(AppnextAdData *)adData;
- (NSTimeInterval) getCloseDelayForAd;
- (BOOL) getShowCloseForAd;
- (ANPositionInViewType) getCloseButtonPositionForAd;
- (NSTimeInterval) getBannerExpirationTimeForAd;
- (NSTimeInterval) getPostponeImpressionForAd;
- (NSTimeInterval) getPostponeVTAForAd;
- (ANPreferredOrientationType) getPreferredOrientationTypeForAd;
- (ANPostViewLocation) getPostViewLocationForAd;
- (NSTimeInterval) getCapRangeForAd;

#pragma mark - Internal Methods

- (void) sendImpressionInternal;

@end
