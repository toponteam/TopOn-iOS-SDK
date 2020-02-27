//
//  ATMopubNativeAdapter.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 16/05/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
extern NSString *const kATAdTitleKey;
extern NSString *const kATAdTextKey;
extern NSString *const kATAdIconImageKey;
extern NSString *const kATAdMainImageKey;
extern NSString *const kATAdCTATextKey;
extern NSString *const kATAdStarRatingKey;

typedef CGSize (^ATMPNativeViewSizeHandler)(CGFloat maximumWidth);
@interface ATMopubNativeAdapter : NSObject
@end

@protocol ATMPMoPubConfiguration<NSObject>
- (instancetype)initWithAdUnitIdForAppInitialization:(NSString *)adUnitId;
@end

@protocol ATMoPub<NSObject>
+ (instancetype)sharedInstance;
- (NSString *)version;
- (void)grantConsent;
- (void)revokeConsent;
- (void)initializeSdkWithConfiguration:(id<ATMPMoPubConfiguration>)configuration
                            completion:(void(^_Nullable)(void))completionBlock;
@end

@protocol ATMPNativeAdRendererSettings <NSObject>
@optional
@property (nonatomic, readwrite, copy) ATMPNativeViewSizeHandler viewSizeHandler;
@end

@protocol ATMPNativeAdDelegate;
@protocol ATMPNativeAd<NSObject>
- (NSDictionary *)properties;
- (UIView *)retrieveAdViewWithError:(NSError **)error;
@property (nonatomic, weak) id<ATMPNativeAdDelegate> delegate;
@end
@protocol ATMPNativeAdDelegate <NSObject>
@optional
- (void)willPresentModalForNativeAd:(id<ATMPNativeAd>)nativeAd;
- (void)didDismissModalForNativeAd:(id<ATMPNativeAd>)nativeAd;
- (void)willLeaveApplicationFromNativeAd:(id<ATMPNativeAd>)nativeAd;
@required
- (UIViewController *)viewControllerForPresentingModalView;
@end

@protocol ATMPNativeAdRequest;
typedef void(^ATMPNativeAdRequestHandler)(id<ATMPNativeAdRequest> request, id<ATMPNativeAd> response, NSError *error);

@protocol ATMPNativeAdRequest<NSObject>
+ (instancetype)requestWithAdUnitIdentifier:(NSString *)identifier rendererConfigurations:(NSArray *)rendererConfigurations;
- (void)startWithCompletionHandler:(ATMPNativeAdRequestHandler)handler;
@end

@protocol ATMPNativeAdRendererConfiguration<NSObject>
@property (nonatomic, strong) id<ATMPNativeAdRendererSettings> rendererSettings;
@property (nonatomic, assign) Class rendererClass;
@property (nonatomic, strong) NSArray *supportedCustomEvents;
@end

@protocol ATMPNativeAdAdapterDelegate;
@protocol MPNativeAdAdapter <NSObject>
@required
@property (nonatomic, readonly) NSDictionary *properties;
@property (nonatomic, readonly) NSURL *defaultActionURL;
@optional
- (void)displayContentForURL:(NSURL *)URL rootViewController:(UIViewController *)controller;
- (BOOL)enableThirdPartyClickTracking;
- (void)trackClick;
@property (nonatomic, weak) id<ATMPNativeAdAdapterDelegate> delegate;
- (void)willAttachToView:(UIView *)view;
- (void)willAttachToView:(UIView *)view withAdContentViews:(NSArray *)adContentViews;
- (void)displayContentForDAAIconTap;
- (UIView *)privacyInformationIconView;
- (UIView *)mainMediaView;
@end

@protocol ATMPNativeAdAdapterDelegate <NSObject>
@required
- (UIViewController *)viewControllerForPresentingModalView;
- (void)nativeAdWillPresentModalForAdapter:(id<MPNativeAdAdapter>)adapter;
- (void)nativeAdDidDismissModalForAdapter:(id<MPNativeAdAdapter>)adapter;
- (void)nativeAdWillLeaveApplicationFromAdapter:(id<MPNativeAdAdapter>)adapter;
@optional
- (void)nativeAdWillLogImpression:(id<MPNativeAdAdapter>)adAdapter;
- (void)nativeAdDidClick:(id<MPNativeAdAdapter>)adAdapter;
@end

@protocol ATMPNativeAdRenderer <NSObject>
@required
+ (id<ATMPNativeAdRendererConfiguration>)rendererConfigurationWithRendererSettings:(id<ATMPNativeAdRendererSettings>)rendererSettings;
- (instancetype)initWithRendererSettings:(id<ATMPNativeAdRendererSettings>)rendererSettings;
- (UIView *)retrieveViewWithAdapter:(id<MPNativeAdAdapter>)adapter error:(NSError **)error;
@optional
@property (nonatomic, readonly) ATMPNativeViewSizeHandler viewSizeHandler;
- (void)adViewWillMoveToSuperview:(UIView *)superview;
- (void)nativeAdTapped;
@end


