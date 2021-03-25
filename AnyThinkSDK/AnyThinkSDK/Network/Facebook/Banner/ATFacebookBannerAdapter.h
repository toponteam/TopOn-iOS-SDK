//
//  ATFacebookBannerAdapter.h
//  AnyThinkFacebookBannerAdapter
//
//  Created by Martin Lau on 29/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATFacebookBannerAdapter : NSObject

@end

struct FBAdSize {
    CGSize size;
};

@protocol FBAdViewDelegate;
@protocol ATFBAdView<NSObject>
- (instancetype)initWithPlacementID:(NSString *)placementID;
- (instancetype)initWithPlacementID:(NSString *)placementID adSize:(struct FBAdSize)adSize rootViewController:(nullable UIViewController *)rootViewController;
- (void)loadAd;
- (void)loadAdWithBidPayload:(NSString *)bidPayload;
- (void)disableAutoRefresh;
@property(nonatomic) CGRect frame;
@property (nonatomic, copy, readonly) NSString *placementID;
@property (nonatomic, weak, readonly, nullable) UIViewController *rootViewController;
@property (nonatomic, weak, nullable) id<FBAdViewDelegate> delegate;
@end

@protocol FBAdViewDelegate <NSObject>
@optional
- (void)adViewDidClick:(id<ATFBAdView>)adView;
- (void)adViewDidFinishHandlingClick:(id<ATFBAdView>)adView;
- (void)adViewDidLoad:(id<ATFBAdView>)adView;
- (void)adView:(id<ATFBAdView>)adView didFailWithError:(NSError *)error;
- (void)adViewWillLogImpression:(id<ATFBAdView>)adView;
@property (nonatomic, readonly, strong) UIViewController *viewControllerForPresentingModalView;

@end


NS_ASSUME_NONNULL_END
