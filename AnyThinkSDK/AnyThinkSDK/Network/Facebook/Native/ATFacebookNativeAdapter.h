//
//  ATFacebookNativeAdapter.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 25/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, ATFBNativeAdViewTag) {
    ATFBNativeAdViewTagIcon = 5,
    ATFBNativeAdViewTagTitle,
    ATFBNativeAdViewTagCoverImage,
    ATFBNativeAdViewTagSubtitle,
    ATFBNativeAdViewTagBody,
    ATFBNativeAdViewTagCallToAction,
    ATFBNativeAdViewTagSocialContext,
    ATFBNativeAdViewTagChoicesIcon,
    ATFBNativeAdViewTagMedia,
};

typedef NS_ENUM(NSInteger, ATFBAdFormatType) {
    ATFBAdFormatTypeUnknown = 0,
    ATFBAdFormatTypeImage,
    ATFBAdFormatTypeVideo,
    ATFBAdFormatTypeCarousel,
};

@interface ATFacebookNativeAdapter : NSObject
@end

@protocol ATFBNativeAd;
@protocol FBNativeAdDelegate<NSObject>
@optional
- (void)nativeAdDidLoad:(id<ATFBNativeAd>)nativeAd;
- (void)nativeAdDidDownloadMedia:(id<ATFBNativeAd>)nativeAd;
- (void)nativeAdWillLogImpression:(id<ATFBNativeAd>)nativeAd;
- (void)nativeAd:(id<ATFBNativeAd>)nativeAd didFailWithError:(NSError *)error;
- (void)nativeAdDidClick:(id<ATFBNativeAd>)nativeAd;
- (void)nativeAdDidFinishHandlingClick:(id<ATFBNativeAd>)nativeAd;
@end

@protocol ATFBMediaViewDelegate;
@protocol ATFBMediaView<NSObject>
@property(nonatomic) NSInteger tag;
@property(nonatomic) CGRect frame;
@property(nonatomic) UIViewAutoresizing autoresizingMask;
@property(nonatomic) id<ATFBNativeAd> nativeAd;
@property(nonatomic) id<ATFBMediaViewDelegate> delegate;
@end

@protocol ATFBAdIconView<ATFBMediaView>
@property (nonatomic, assign, readonly) ATFBNativeAdViewTag nativeAdViewTag;
@end

@protocol ATFBMediaViewDelegate<NSObject>
- (void)mediaViewVideoDidPlay:(id<ATFBMediaView>)mediaView;
- (void)mediaViewVideoDidComplete:(id<ATFBMediaView>)mediaView;
@end

@protocol ATFBImage<NSObject>
- (void)loadImageAsyncWithBlock:(void (^)(UIImage * image))block;
@end

@protocol ATFBNativeAd<NSObject>
- (instancetype)initWithPlacementID:(NSString *)placementID;
- (void)loadAd;
- (void)loadAdWithBidPayload:(NSString *)bidPayload;
- (void)registerViewForInteraction:(UIView *)view mediaView:(id<ATFBMediaView>)mediaView iconView:(id<ATFBMediaView>)iconView viewController:(UIViewController *)viewController clickableViews:(NSArray<UIView *> *)clickableViews;
@property (nonatomic, weak) id<FBNativeAdDelegate> delegate;
@property (nonatomic, copy, readonly) NSString *placementID;
@property (nonatomic, copy, readonly) NSString *headline;
@property (nonatomic, copy, readonly) NSString *linkDescription;
@property (nonatomic, copy, readonly) NSString *advertiserName;
@property (nonatomic, copy, readonly) NSString *socialContext;
@property (nonatomic, copy, readonly) NSString *callToAction;
@property (nonatomic, copy, readonly) NSString *rawBodyText;
@property (nonatomic, copy, readonly) NSString *bodyText;
@property (nonatomic, copy, readonly) NSString *sponsoredTranslation;
@property (nonatomic, copy, readonly) NSString *adTranslation;
@property (nonatomic, copy, readonly) NSString *promotedTranslation;
@property (nonatomic, strong, readonly) id<ATFBImage> adChoicesIcon;
@property (nonatomic, assign, readonly) CGFloat aspectRatio;
@property (nonatomic, copy, readonly) NSURL *adChoicesLinkURL;
@property (nonatomic, copy, readonly) NSString *adChoicesText;
@property (nonatomic, assign, readonly) ATFBAdFormatType adFormatType;
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;
@property (nonatomic, getter=isRegistered, readonly) BOOL registered;
@end

@protocol ATFBAdChoicesView<NSObject>
@property(nonatomic) id<ATFBNativeAd> nativeAd;
@end

extern const CGFloat kATFBAdOptionsViewWidth;
extern const CGFloat kATFBAdOptionsViewHeight;
@protocol ATFBAdOptionsView<NSObject>
- (instancetype)initWithFrame:(CGRect)frame;
@property (nonatomic, weak, readwrite) id<ATFBNativeAd> nativeAd;
@property (nonatomic, strong) UIColor *foregroundColor;
@property (nonatomic, assign) BOOL useSingleIcon;
@property(nonatomic) UIViewAutoresizing autoresizingMask;
@end

@protocol FBNativeBannerAdDelegate <NSObject>
@end

@protocol ATFBNativeBannerAd<NSObject>
@property (nonatomic, weak) id<FBNativeBannerAdDelegate> delegate;
- (instancetype)initWithPlacementID:(NSString *)placementID;
- (void)loadAd;
- (void)loadAdWithBidPayload:(NSString *)bidPayload;
@end

@protocol ATFBNativeBannerAdView<NSObject>
/**
 type: 1 100, 2 120, 5 50
 no need for enum definition since the type's from the server
 */
+ (instancetype)nativeBannerAdViewWithNativeBannerAd:(id<ATFBNativeBannerAd>)nativeBannerAd withType:(NSInteger)type;
@property(nonatomic) CGRect            frame;
@end
