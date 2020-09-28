//
//  ATAdmobBannerAdapter.h
//  AnyThinkAdmobBannerAdapter
//
//  Created by Martin Lau on 18/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ATPACConsentStatus) {
    ATPACConsentStatusUnknown = 0,          ///< Unknown consent status.
    ATPACConsentStatusNonPersonalized = 1,  ///< User consented to non-personalized ads.
    ATPACConsentStatusPersonalized = 2,     ///< User consented to personalized ads.
};

@protocol ATPACConsentInformation<NSObject>
+ (instancetype)sharedInstance;
@property(nonatomic) ATPACConsentStatus consentStatus;
@property(nonatomic, getter=isTaggedForUnderAgeOfConsent) BOOL tagForUnderAgeOfConsent;
@end
@interface ATAdmobBannerAdapter : NSObject
@end

@protocol ATGADBannerView;
@protocol GADBannerViewDelegate<NSObject>
@optional
#pragma mark Ad Request Lifecycle Notifications
- (void)adViewDidReceiveAd:(id<ATGADBannerView>)bannerView;
- (void)adView:(id<ATGADBannerView>)bannerView didFailToReceiveAdWithError:(NSError*)error;
#pragma mark Click-Time Lifecycle Notifications
- (void)adViewWillPresentScreen:(id<ATGADBannerView>)bannerView;
- (void)adViewWillDismissScreen:(id<ATGADBannerView>)bannerView;
- (void)adViewDidDismissScreen:(id<ATGADBannerView>)bannerView;
- (void)adViewWillLeaveApplication:(id<ATGADBannerView>)bannerView;
@end

@protocol GADAdSizeDelegate<NSObject>
@end

@protocol ATGADMobileAds<NSObject>
+ (id<ATGADMobileAds>)sharedInstance;
@property(nonatomic, nonnull, readonly) NSString *sdkVersion;
@end

@protocol ATGADRequest<NSObject>
+ (NSString *)sdkVersion;
+ (instancetype)request;
@property(nonatomic, copy) NSArray *testDevices;
@end

typedef struct GADAdSize GADAdSize;
struct GADAdSize {
    CGSize size;       ///< The ad size. Don't modify this value directly.
    NSUInteger flags;  ///< Reserved.
};

@protocol ATGADBannerView<NSObject>
#pragma mark Initialization
- (instancetype)initWithAdSize:(GADAdSize)adSize origin:(CGPoint)origin;
- (instancetype)initWithAdSize:(GADAdSize)adSize;
@property(nonatomic, copy) NSString *adUnitID;
@property(nonatomic, weak) UIViewController *rootViewController;
@property(nonatomic, assign) GADAdSize adSize;
@property(nonatomic, weak) id<GADBannerViewDelegate> delegate;
@property(nonatomic, weak) id<GADAdSizeDelegate> adSizeDelegate;
#pragma mark Making an Ad Request
- (void)loadRequest:(id<ATGADRequest>)request;
@property(nonatomic, assign, getter=isAutoloadEnabled) BOOL autoloadEnabled;
@property(nonatomic, readonly, copy) NSString *adNetworkClassName;
@end
