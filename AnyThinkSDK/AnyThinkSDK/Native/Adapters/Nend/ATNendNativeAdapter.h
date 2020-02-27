//
//  ATNendNativeAdapter.h
//  AnyThinkNendNativeAdapter
//
//  Created by Martin Lau on 2019/4/16.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATNendNativeAdapter : NSObject
@end

#pragma mark - static native
typedef void (^AT_NADNativeImageCompletionBlock)(UIImage *);

typedef NS_ENUM(NSInteger, AT_NADNativeAdvertisingExplicitly) {
    AT_NADNativeAdvertisingExplicitlyPR,
    AT_NADNativeAdvertisingExplicitlySponsored,
    AT_NADNativeAdvertisingExplicitlyAD,
    AT_NADNativeAdvertisingExplicitlyPromotion,
};

@protocol ATNADNative;
@protocol NADNativeViewRendering;

@protocol NADNativeDelegate <NSObject>
@optional
- (void)nadNativeDidClickAd:(id<ATNADNative>)ad;
@end

@protocol ATNADNative<NSObject>
@property (nonatomic, readonly, copy) NSString *shortText;
@property (nonatomic, readonly, copy) NSString *longText;
@property (nonatomic, readonly, copy) NSString *promotionUrl;
@property (nonatomic, readonly, copy) NSString *promotionName;
@property (nonatomic, readonly, copy) NSString *actionButtonText;
@property (nonatomic, readonly, copy) NSString *imageUrl;
@property (nonatomic, readonly, copy) NSString *logoUrl;
@property (nonatomic, weak) id<NADNativeDelegate> delegate;
- (void)intoView:(UIView<NADNativeViewRendering> *)view advertisingExplicitly:(AT_NADNativeAdvertisingExplicitly)advertisingExplicitly;
- (NSString *)prTextForAdvertisingExplicitly:(AT_NADNativeAdvertisingExplicitly)advertisingExplicitly;
- (void)activateAdView:(UIView *)view withPrLabel:(UIView *)prLabel;
- (void)loadAdImageWithCompletionBlock:(AT_NADNativeImageCompletionBlock)block;
- (void)loadLogoImageWithCompletionBlock:(AT_NADNativeImageCompletionBlock)block;
@end

typedef void (^AT_NADNativeCompletionBlock)(id<ATNADNative>ad, NSError *error);
@protocol ATNADNativeClient<NSObject>
- (instancetype)initWithSpotId:(NSString *)spotId apiKey:(NSString *)apiKey;
- (void)loadWithCompletionBlock:(AT_NADNativeCompletionBlock)completionBlock;
- (void)enableAutoReloadWithInterval:(NSTimeInterval)interval completionBlock:(AT_NADNativeCompletionBlock)completionBlock;
- (void)disableAutoReload;
@end

#pragma mark - video native
@protocol ATNADNativeVideo;

extern const NSInteger kATNADVideoOrientationVertical;
extern const NSInteger kATNADVideoOrientationHorizontal;

typedef NS_ENUM(NSInteger, ATNADNativeVideoClickAction) {
    ATNADNativeVideoClickActionFullScreen = 1,
    ATNADNativeVideoClickActionLP = 2
};

@protocol NADNativeVideoDelegate <NSObject>
@optional
- (void)nadNativeVideoDidImpression:(id<ATNADNativeVideo> _Nonnull)ad;
- (void)nadNativeVideoDidClickAd:(id<ATNADNativeVideo> _Nonnull)ad;
- (void)nadNativeVideoDidClickInformation:(id<ATNADNativeVideo> _Nonnull)ad;
@end

@protocol ATNADNativeVideo<NSObject>
@property (readwrite, nonatomic, weak, nullable) id<NADNativeVideoDelegate> delegate;
@property (readwrite, nonatomic, getter=isMutedOnFullScreen) BOOL mutedOnFullScreen;
@property (readonly, nonatomic) BOOL hasVideo;
@property (readonly, nonatomic) NSInteger orientation;
@property (readonly, nonatomic, copy, nullable) NSString *title;
@property (readonly, nonatomic, copy, nullable) NSString *advertiserName;
@property (readonly, nonatomic, copy, nullable) NSString *explanation;
@property (readonly, nonatomic) CGFloat userRating;
@property (readonly, nonatomic) NSInteger userRatingCount;
@property (readonly, nonatomic, copy, nullable) NSString *callToAction;
@property (readonly, nonatomic, copy, nullable) NSString *logoImageUrl;
@property (readonly, nonatomic, strong, nullable) UIImage *logoImage;
@property (readonly, nonatomic, strong, nullable) id<ATNADNative> staticNativeAd;
- (instancetype _Null_unspecified)init NS_UNAVAILABLE;
- (void)registerInteractionViews:(nonnull NSArray<__kindof UIView *> *)views;
- (void)unregisterInteractionViews;
- (void)downloadLogoImageWithCompletionHandler:(void(^_Nonnull)(UIImage * _Nullable))handler;
@end

@protocol ATNADNativeVideoLoader<NSObject>
@property (readwrite, nonatomic, copy, nullable) NSString *userId;
@property (readwrite, nonatomic, copy, nullable) NSString *mediationName;
@property (readwrite, nonatomic, strong, nullable) id userFeature;
@property (readwrite, nonatomic) BOOL isLocationEnabled;

- (instancetype _Null_unspecified)init NS_UNAVAILABLE;
- (instancetype)initWithSpotId:(NSString *)spotId apiKey:(NSString *)apiKey;
- (instancetype)initWithSpotId:(NSString *)spotId apiKey:(NSString *)apiKey clickAction:(ATNADNativeVideoClickAction)action;

- (void)setFillerStaticNativeAdId:(NSString *)spotId apiKey:(NSString *)apiKey;
- (void)loadAdWithCompletionHandler:(void(^)(id<ATNADNativeVideo> _Nullable, NSError * _Nullable))handler;
@end

@protocol ATNADNativeVideoView;
@protocol NADNativeVideoViewDelegate <NSObject>
@optional
- (void)nadNativeVideoViewDidStartPlay:(id<ATNADNativeVideoView>)videoView;
- (void)nadNativeVideoViewDidStopPlay:(id<ATNADNativeVideoView>)videoView;
- (void)nadNativeVideoViewDidCompletePlay:(id<ATNADNativeVideoView>)videoView;
- (void)nadNativeVideoViewDidFailToPlay:(id<ATNADNativeVideoView>)videoView;
- (void)nadNativeVideoViewDidOpenFullScreen:(id<ATNADNativeVideoView>)videoView;
- (void)nadNativeVideoViewDidCloseFullScreen:(id<ATNADNativeVideoView>)videoView;

@end

@protocol ATNADNativeVideoView<NSObject>
@property(nonatomic) CGRect frame;
@property (readwrite, nonatomic, weak) id<NADNativeVideoViewDelegate> delegate;
@property (readwrite, nonatomic, strong) id<ATNADNativeVideo> videoAd;
@property (readwrite, nonatomic, weak, nullable)IBOutlet UIViewController *rootViewController;

@end

@protocol NADNativeViewRendering <NSObject>
@required
- (UILabel *)prTextLabel;
@optional
- (UIImageView *)adImageView;
- (UIImageView *)nadLogoImageView;
- (UILabel *)shortTextLabel;
- (UILabel *)longTextLabel;
- (UILabel *)promotionUrlLabel;
- (UILabel *)promotionNameLabel;
- (UILabel *)actionButtonTextLabel;
@end
