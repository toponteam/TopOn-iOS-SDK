//
//  ATMopubBannerAdapter.h
//  AnyThinkMopubBannerAdapter
//
//  Created by Martin Lau on 30/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATMopubBannerAdapter : NSObject

@end

@protocol ATMPMoPubConfiguration<NSObject>
- (instancetype)initWithAdUnitIdForAppInitialization:(NSString *)adUnitId;
@end

@protocol ATMoPub<NSObject>
+ (instancetype)sharedInstance;
- (NSString *)version;
- (void)grantConsent;
- (void)revokeConsent;
- (void)initializeSdkWithConfiguration:(id<ATMPMoPubConfiguration>)configuration completion:(void(^_Nullable)(void))completionBlock;

@end

@protocol MPAdViewDelegate;
@protocol ATMPAdView<NSObject>
- (id)initWithAdUnitId:(NSString *)adUnitId size:(CGSize)size;
@property (nonatomic, weak) id<MPAdViewDelegate> delegate;
@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, copy) NSString *keywords;
@property (nonatomic, copy) NSString *userDataKeywords;
@property (nonatomic) CGRect frame;
- (void)loadAd;
- (void)forceRefreshAd;
- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation;
- (void)lockNativeAdsToOrientation:(NSInteger)orientation;
- (void)unlockNativeAdsOrientation;
- (NSInteger)allowedNativeAdsOrientation;
- (CGSize)adContentViewSize;
- (void)stopAutomaticallyRefreshingContents;
- (void)startAutomaticallyRefreshingContents;
@end
#pragma mark -
@protocol MPAdViewDelegate <NSObject>
@required
- (UIViewController *)viewControllerForPresentingModalView;
@optional
- (void)adViewDidLoadAd:(id<ATMPAdView>)view;
- (void)adViewDidFailToLoadAd:(id<ATMPAdView>)view;
- (void)willPresentModalViewForAd:(id<ATMPAdView>)view;
- (void)didDismissModalViewForAd:(id<ATMPAdView>)view;
- (void)willLeaveApplicationFromAd:(id<ATMPAdView>)view;
@end
