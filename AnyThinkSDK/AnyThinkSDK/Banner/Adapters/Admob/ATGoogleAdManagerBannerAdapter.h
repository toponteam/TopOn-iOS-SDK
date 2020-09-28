//
//  ATGoogleAdManagerBannerAdapter.h
//  AnyThinkAdmobBannerAdapter
//
//  Created by stephen on 7/27/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <UIKit/UIKit.h>
//typedef NS_ENUM(NSInteger, ATPACConsentStatus) {
//    ATPACConsentStatusUnknown = 0,          ///< Unknown consent status.
//    ATPACConsentStatusNonPersonalized = 1,  ///< User consented to non-personalized ads.
//    ATPACConsentStatusPersonalized = 2,     ///< User consented to personalized ads.
//};

//@protocol ATPACConsentInformation<NSObject>
//+ (instancetype)sharedInstance;
//@property(nonatomic) ATPACConsentStatus consentStatus;
//@property(nonatomic, getter=isTaggedForUnderAgeOfConsent) BOOL tagForUnderAgeOfConsent;
//@end
@interface ATGoogleAdManagerBannerAdapter : NSObject
@end

@protocol ATDFPBannerView;
@protocol DFPBannerViewDelegate<NSObject>
@optional
#pragma mark Ad Request Lifecycle Notifications
- (void)adViewDidReceiveAd:(id<ATDFPBannerView>)bannerView;
- (void)adView:(id<ATDFPBannerView>)bannerView didFailToReceiveAdWithError:(NSError*)error;
#pragma mark Click-Time Lifecycle Notifications
- (void)adViewWillPresentScreen:(id<ATDFPBannerView>)bannerView;
- (void)adViewWillDismissScreen:(id<ATDFPBannerView>)bannerView;
- (void)adViewDidDismissScreen:(id<ATDFPBannerView>)bannerView;
- (void)adViewWillLeaveApplication:(id<ATDFPBannerView>)bannerView;
@end

@protocol GADAdSizeDelegate<NSObject>
@end

@protocol ATGADMobileAds<NSObject>
+ (id<ATGADMobileAds>)sharedInstance;
@property(nonatomic, nonnull, readonly) NSString *sdkVersion;
@end

@protocol ATDFPRequest<NSObject>
+ (NSString *)sdkVersion;
+ (instancetype)request;
@end

typedef struct GADAdSize GADAdSize;
struct GADAdSize {
    CGSize size;       ///< The ad size. Don't modify this value directly.
    NSUInteger flags;  ///< Reserved.
};
@protocol ATDFPBannerView<NSObject>
#pragma mark Initialization
- (instancetype)initWithAdSize:(GADAdSize)adSize origin:(CGPoint)origin;
- (instancetype)initWithAdSize:(GADAdSize)adSize;
@property(nonatomic, copy) NSString *adUnitID;
@property(nonatomic, weak) UIViewController *rootViewController;
@property(nonatomic, assign) GADAdSize adSize;
@property(nonatomic, weak) id<DFPBannerViewDelegate> delegate;
@property(nonatomic, weak) id<GADAdSizeDelegate> adSizeDelegate;
#pragma mark Making an Ad Request
- (void)loadRequest:(id<ATDFPRequest>)request;
@property(nonatomic, assign, getter=isAutoloadEnabled) BOOL autoloadEnabled;
@property(nonatomic, readonly, copy) NSString *adNetworkClassName;
@end

