#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "KSCUEmbedAdConfig.h"
#import "KSCUEntryElement.h"
#import "KSCUContentPage.h"
#import "KSCUContentStateDelegate.h"
#import "KSAdContentAlliance.h"
#import "KSDrawAd.h"
#import "KSDrawAdsManager.h"
#import "KSAdExportManager.h"
#import "KSFeedAd.h"
#import "KSFeedAdsManager.h"
#import "KSInterstitialAd.h"
#import "KSAdImage.h"
#import "KSMaterialMeta.h"
#import "KSNativeAd.h"
#import "KSNativeAdRelatedView.h"
#import "KSNativeAdsManager.h"
#import "KSAd.h"
#import "KSAdPos.h"
#import "KSAdSDK.h"
#import "KSAdSDKError.h"
#import "KSAdSDKManager.h"
#import "KSFullscreenVideoAd.h"
#import "KSRewardedVideoAd.h"
#import "KSRewardedVideoModel.h"
#import "KSVideoAd.h"
#import "KSAdBasePlayerView.h"
#import "KSAdPlayerView.h"
#import "KSVideoAdView.h"
#import "KSAdUserInfo.h"
#import "KSAdPlayerCacheView.h"

FOUNDATION_EXPORT double KSAdSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char KSAdSDKVersionString[];

