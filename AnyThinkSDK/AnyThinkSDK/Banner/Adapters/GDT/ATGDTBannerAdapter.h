//
//  ATGDTBannerAdapter.h
//  AnyThinkGDTBannerAdapter
//
//  Created by Martin Lau on 20/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import<UIKit/UIKit.h>

@interface ATGDTBannerAdapter : NSObject

@end

#define AT_GDTMOB_AD_SUGGEST_SIZE_320x50    CGSizeMake(320, 50) //For iPhone
#define AT_GDTMOB_AD_SUGGEST_SIZE_468x60    CGSizeMake(468, 60) //For iPad
#define AT_GDTMOB_AD_SUGGEST_SIZE_728x90    CGSizeMake(728, 90) //For iPad

@protocol ATGDTSDKConfig<NSObject>
+ (NSString *)sdkVersion;
@end

@protocol ATGDTMobBannerViewDelegate <NSObject>
@optional
- (void)bannerViewMemoryWarning;
- (void)bannerViewDidReceived;
- (void)bannerViewFailToReceived:(NSError *)error;
- (void)bannerViewWillLeaveApplication;
- (void)bannerViewWillClose;
- (void)bannerViewWillExposure;
- (void)bannerViewClicked;
- (void)bannerViewWillPresentFullScreenModal;
- (void)bannerViewDidPresentFullScreenModal;
- (void)bannerViewWillDismissFullScreenModal;
- (void)bannerViewDidDismissFullScreenModal;
@end

@protocol ATGDTMobBannerView<NSObject>
@property (nonatomic, weak) UIViewController *currentViewController;
@property(nonatomic, weak) id<ATGDTMobBannerViewDelegate> delegate;
@property(nonatomic, assign) int interval;
@property(nonatomic, assign) BOOL isGpsOn;
@property(nonatomic, assign) BOOL isAnimationOn;
@property(nonatomic, assign) BOOL showCloseBtn;
- (instancetype)initWithAppId:(NSString *)appId placementId:(NSString *)placementId;
- (instancetype)initWithFrame:(CGRect)frame appId:(NSString *)appId placementId:(NSString *)placementId;
- (void)loadAdAndShow;
@end

@protocol GDTUnifiedBannerView;
/**
 *  广点通推荐尺寸
 */
#define ATGDT_UNIFIED_BANNER_AD_SUGGEST_SIZE_375x60    CGSizeMake(375, 60)


@protocol GDTUnifiedBannerViewDelegate <NSObject>
@optional
- (void)unifiedBannerViewDidLoad:(id<GDTUnifiedBannerView>)unifiedBannerView;
- (void)unifiedBannerViewFailedToLoad:(id<GDTUnifiedBannerView>)unifiedBannerView error:(NSError *)error;
- (void)unifiedBannerViewWillExpose:(id<GDTUnifiedBannerView>)unifiedBannerView;
- (void)unifiedBannerViewClicked:(id<GDTUnifiedBannerView>)unifiedBannerView;
- (void)unifiedBannerViewWillPresentFullScreenModal:(id<GDTUnifiedBannerView>)unifiedBannerView;
- (void)unifiedBannerViewDidPresentFullScreenModal:(id<GDTUnifiedBannerView>)unifiedBannerView;
- (void)unifiedBannerViewWillDismissFullScreenModal:(id<GDTUnifiedBannerView>)unifiedBannerView;
- (void)unifiedBannerViewDidDismissFullScreenModal:(id<GDTUnifiedBannerView>)unifiedBannerView;
- (void)unifiedBannerViewWillLeaveApplication:(id<GDTUnifiedBannerView>)unifiedBannerView;
- (void)unifiedBannerViewWillClose:(id<GDTUnifiedBannerView>)unifiedBannerView;
@end

@protocol ATGDTUnifiedBannerView<NSObject>
@property (nonatomic, weak) id<GDTUnifiedBannerViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame appId:(NSString *)appId placementId:(NSString *)placementId viewController:(UIViewController *)viewController;
- (void)loadAdAndShow;

@end
