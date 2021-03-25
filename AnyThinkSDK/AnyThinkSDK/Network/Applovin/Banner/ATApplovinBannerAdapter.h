//
//  ATApplovinBannerAdapter.h
//  AnyThinkApplovinBannerAdapter
//
//  Created by Martin Lau on 20/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATApplovinBannerAdapter : NSObject

@end

@protocol ATALAdService;
@protocol ATALSdk<NSObject>
- (void)initializeSdk;
+ (NSString *)version;
+(NSUInteger)versionCode;
+ (instancetype)sharedWithKey:(NSString *)sdkKey;
@property (strong, nonatomic, readonly) id<ATALAdService> adService;
@end

@protocol ATALAd<NSObject>
@end

@protocol ATALAdLoadDelegate;
@protocol ATALAdService<NSObject>
- (void)loadNextAdForZoneIdentifier:(NSString *)zoneIdentifier andNotify:(id<ATALAdLoadDelegate>)delegate;
@end

@protocol ATALPrivacySettings<NSObject>
+ (void)setHasUserConsent:(BOOL)hasUserConsent;
+ (void)setIsAgeRestrictedUser:(BOOL)isAgeRestrictedUser;
@end

@protocol ATALAdLoadDelegate <NSObject>
- (void)adService:(id<ATALAdService>)adService didLoadAd:(id<ATALAd>)ad;
- (void)adService:(id<ATALAdService>)adService didFailToLoadAdWithError:(int)code;
@end

@protocol ATALAdDisplayDelegate <NSObject>
- (void)ad:(id<ATALAd>)ad wasDisplayedIn:(UIView *)view;
- (void)ad:(id<ATALAd>)ad wasHiddenIn:(UIView *)view;
- (void)ad:(id<ATALAd>)ad wasClickedIn:(UIView *)view;
@end

@protocol ATALAdSize<NSObject>
+ (instancetype)sizeBanner;
+ (instancetype)sizeMRec;
@end


typedef NS_ENUM(NSInteger, ATALAdViewDisplayErrorCode)
{
    ATALAdViewDisplayErrorCodeUnspecified
};

@protocol ATALAdView;
@protocol ATALAdViewEventDelegate <NSObject>
@optional
- (void)ad:(id<ATALAd>)ad didPresentFullscreenForAdView:(id<ATALAdView>)adView;
- (void)ad:(id<ATALAd>)ad willDismissFullscreenForAdView:(id<ATALAdView>)adView;
- (void)ad:(id<ATALAd>)ad didDismissFullscreenForAdView:(id<ATALAdView>)adView;
- (void)ad:(id<ATALAd>)ad willLeaveApplicationForAdView:(id<ATALAdView>)adView;
- (void)ad:(id<ATALAd>)ad didReturnToApplicationForAdView:(id<ATALAdView>)adView;
- (void)ad:(id<ATALAd>)ad didFailToDisplayInAdView:(id<ATALAdView>)adView withError:(ATALAdViewDisplayErrorCode)code;
@end

@protocol ATALAdView<NSObject>
@property (strong, atomic) id <ATALAdLoadDelegate> adLoadDelegate;
@property (strong, atomic) id <ATALAdDisplayDelegate> adDisplayDelegate;
@property (strong, atomic) id <ATALAdViewEventDelegate> adEventDelegate;
//@property (strong, atomic) ALAdSize *adSize;

@property (assign, atomic, getter=isAutoloadEnabled, setter=setAutoloadEnabled:) BOOL autoload;
@property (assign, atomic, getter=isAutoloadEnabled, setter=setAutoloadEnabled:) BOOL shouldAutoload;
- (void)loadNextAd;
- (instancetype)initWithFrame:(CGRect)frame size:(id<ATALAdSize>)size sdk:(id<ATALSdk>)sdk;
- (void)render:(id<ATALAd>)ad;
//- (instancetype)initWithSize:(id<ATALAdSize>)size zoneIdentifier:(NSString *)zoneIdentifier;
- (instancetype)initWithSdk:(id<ATALSdk>)sdk size:(id<ATALAdSize>)size;
- (instancetype)initWithSdk:(id<ATALSdk>)sdk size:(id<ATALAdSize>)size zoneIdentifier:(nullable NSString *)zoneIdentifier;

@end
