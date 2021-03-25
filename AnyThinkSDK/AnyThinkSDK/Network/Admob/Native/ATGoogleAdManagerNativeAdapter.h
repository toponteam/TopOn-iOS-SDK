//
//  ATGoogleAdManagerNativeAdapter.h
//  AnyThinkGoogleAdManagerNativeAdapter
//
//  Created by stephen on 7/27/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ATAdmobNativeCommon.h"

@interface ATGoogleAdManagerNativeAdapter : NSObject
@end

@protocol ATGADVideoOptions<NSObject>
@property(nonatomic, assign) BOOL startMuted;
@end

@protocol ATGADAdLoaderOptions<NSObject>
@end

@protocol ATGADAdNetworkExtras<NSObject>
@end

@protocol ATGADExtras<ATGADAdNetworkExtras>
@property(nonatomic, copy) NSDictionary *additionalParameters;
@end

@protocol ATDFPRequest<NSObject>
+ (NSString *)sdkVersion;
+ (instancetype)request;
- (void)registerAdNetworkExtras:(id<ATGADAdNetworkExtras>)extras;
@end

@protocol ATGADMultipleAdsAdLoaderOptions<ATGADAdLoaderOptions>
@property(nonatomic) NSInteger numberOfAds;
@end

@protocol ATGADNativeAdMediaAdLoaderOptions<ATGADAdLoaderOptions>
@property(nonatomic, assign) NSInteger mediaAspectRatio;
@end

@protocol ATGADAdLoaderDelegate;
@protocol ATDFPAdLoader<NSObject>
- (instancetype)initWithAdUnitID:(NSString *)adUnitID
              rootViewController:(UIViewController *)rootViewController
                         adTypes:(NSArray<NSString*> *)adTypes
                         options:(NSArray<id<ATGADAdLoaderOptions>> *)options;
@property(nonatomic, weak) id<ATGADAdLoaderDelegate> delegate;
- (void)loadRequest:(id<ATDFPRequest>)request;
@end

@protocol ATGADAdLoaderDelegate<NSObject>
@optional
- (void)adLoader:(id<ATDFPAdLoader>)adLoader didFailToReceiveAdWithError:(NSError *)error;
- (void)adLoaderDidFinishLoading:(id<ATDFPAdLoader>)adLoader;
@end

@protocol ATGADUnifiedNativeAd;
@protocol ATGADUnifiedNativeAdLoaderDelegate<ATGADAdLoaderDelegate>
- (void)adLoader:(id<ATDFPAdLoader>)adLoader didReceiveUnifiedNativeAd:(id<ATGADUnifiedNativeAd>)nativeAd;
@end

@protocol ATGADNativeAdImage<NSObject>
@property(nonatomic, readonly, strong) UIImage *image;
@end

@protocol ATGADVideoController;
@protocol GADUnifiedNativeAdDelegate;
@protocol ATGADUnifiedNativeAd<NSObject>
@property(nonatomic, readonly, copy) NSString *headline;
@property(nonatomic, readonly, copy) NSString *body;
@property(nonatomic, readonly, copy) NSString *callToAction;
@property(nonatomic, readonly, copy) NSDecimalNumber *starRating;
@property(nonatomic, readonly, copy, nullable) NSString *advertiser;
@property(nonatomic, readonly, strong) id<ATGADNativeAdImage> icon;
@property(nonatomic, readonly, strong) NSArray<id<ATGADNativeAdImage>> *images;
@property(nonatomic, weak, nullable) id<GADUnifiedNativeAdDelegate> delegate;
@property(nonatomic, readonly, nullable) id<ATGADVideoController> videoController;
- (void)registerAdView:(UIView *)adView
   clickableAssetViews:
(NSDictionary<NSString*, UIView *> *)clickableAssetViews
nonclickableAssetViews:
(NSDictionary<NSString*, UIView *> *)nonclickableAssetViews;
- (void)unregisterAdView;
@end

@protocol ATGADMediaView<NSObject>
@end
@protocol ATGADUnifiedNativeAdDelegate<NSObject>
- (void)nativeAdDidRecordImpression:(id<ATGADUnifiedNativeAd>)nativeAd;
- (void)nativeAdDidRecordClick:(id<ATGADUnifiedNativeAd>)nativeAd;
@end

@protocol ATGADAdChoicesView<NSObject>
@end

@protocol ATGADUnifiedNativeAdView<NSObject>
@property(nonatomic) BOOL translatesAutoresizingMaskIntoConstraints;
@property(nonatomic, strong, nullable) id<ATGADUnifiedNativeAd> nativeAd;
@property(nonatomic, weak, nullable) UIView *headlineView;
@property(nonatomic, weak, nullable) UIView *callToActionView;
@property(nonatomic, weak, nullable) UIView *iconView;
@property(nonatomic, weak, nullable) UIView *bodyView;
@property(nonatomic, weak, nullable) UIView *storeView;
@property(nonatomic, weak, nullable) UIView *priceView;
@property(nonatomic, weak, nullable) UIView *imageView;
@property(nonatomic, weak, nullable) UIView *starRatingView;
@property(nonatomic, weak, nullable) UIView *advertiserView;
@property(nonatomic, weak, nullable) id<ATGADMediaView> mediaView;
@property(nonatomic, weak, nullable) id<ATGADAdChoicesView> adChoicesView;
@end

@protocol ATGADVideoControllerDelegate;
@protocol ATGADVideoController<NSObject>
- (BOOL)hasVideoContent;
@property(nonatomic, weak) id<ATGADVideoControllerDelegate> delegate;
@end

@protocol ATGADVideoControllerDelegate<NSObject>
- (void)videoControllerDidPlayVideo:(id<ATGADVideoController>)videoController;
- (void)videoControllerDidPauseVideo:(id<ATGADVideoController>)videoController;
- (void)videoControllerDidEndVideoPlayback:(id<ATGADVideoController>)videoController;
- (void)videoControllerDidMuteVideo:(id<ATGADVideoController>)videoController;
- (void)videoControllerDidUnmuteVideo:(id<ATGADVideoController>)videoController;
@end
