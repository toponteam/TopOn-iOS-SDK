//
//  ATMintegralInterstitialAdapter.h
//  AnyThinkMintegralInterstitialAdapter
//
//  Created by Martin Lau on 25/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATMintegralInterstitialAdapter : NSObject
@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);
@end

@protocol ATMTGInterstitialAdManager;
#pragma mark - MTGInterstitialAdManagerDelegate
@protocol ATMTGInterstitialAdLoadDelegate <NSObject>
@optional
- (void) onInterstitialLoadSuccess:(id<ATMTGInterstitialAdManager>)adManager;
- (void) onInterstitialLoadFail:(NSError *)error adManager:(id<ATMTGInterstitialAdManager>)adManager;
@end

@protocol ATMTGInterstitialAdShowDelegate <NSObject>
@optional
- (void) onInterstitialShowSuccess:(id<ATMTGInterstitialAdManager>)adManager;
- (void) onInterstitialShowFail:(NSError *)error adManager:(id<ATMTGInterstitialAdManager>)adManager;
- (void) onInterstitialClosed:(id<ATMTGInterstitialAdManager>)adManager;
- (void) onInterstitialAdClick:(id<ATMTGInterstitialAdManager>)adManager;
@end

@protocol ATMTGInterstitialAdManager<NSObject>
@property (nonatomic, readonly)   NSString * currentUnitId;
- (instancetype)initWithPlacementId:(NSString *)placementId
    unitId:(NSString *)unitId
adCategory:(NSInteger)adCategory;
- (void)loadWithDelegate:(id <ATMTGInterstitialAdLoadDelegate>) delegate;
- (void)showWithDelegate:(id <ATMTGInterstitialAdShowDelegate>)delegate presentingViewController:(UIViewController *)viewController;
@end

@protocol ATMTGInterstitialVideoAdManager;
@protocol ATMTGInterstitialVideoDelegate <NSObject>
@optional
- (void) onInterstitialAdLoadSuccess:(id<ATMTGInterstitialVideoAdManager>)adManager;
- (void) onInterstitialVideoLoadSuccess:(id<ATMTGInterstitialVideoAdManager>)adManager;
- (void) onInterstitialVideoLoadFail:(NSError *)error adManager:(id<ATMTGInterstitialVideoAdManager>)adManager;
- (void) onInterstitialVideoShowSuccess:(id<ATMTGInterstitialVideoAdManager>)adManager;
- (void) onInterstitialVideoShowFail:(NSError *)error adManager:(id<ATMTGInterstitialVideoAdManager>)adManager;
- (void) onInterstitialVideoAdClick:(id<ATMTGInterstitialVideoAdManager>)adManager;
- (void)onInterstitialVideoAdDismissedWithConverted:(BOOL)converted adManager:(id<ATMTGInterstitialVideoAdManager>)adManager;
@end

@protocol ATMTGInterstitialVideoAdManager<NSObject>
@property (nonatomic, weak) id  <ATMTGInterstitialVideoDelegate> delegate;
@property (nonatomic, readonly)   NSString * currentUnitId;
@property (nonatomic, assign) BOOL  playVideoMute;
- (instancetype)initWithPlacementId:(NSString *)placementId
  unitId:(NSString *)unitId
delegate:(nullable id<ATMTGInterstitialVideoDelegate>)delegate;
- (void)loadAd;
- (void)showFromViewController:(UIViewController *)viewController;
- (void)cleanAllVideoFileCache;
- (BOOL)isVideoReadyToPlay:(NSString *)unitId;
@end

@protocol ATMTGBidInterstitialVideoAdManager<NSObject>
@property (nonatomic, weak) id  <ATMTGInterstitialVideoDelegate> delegate;
@property (nonatomic, readonly)   NSString * currentUnitId;
@property (nonatomic, assign) BOOL  playVideoMute;
- (nonnull instancetype)initWithPlacementId:(nullable NSString *)placementId
  unitId:(nonnull NSString *)unitId
delegate:(nullable id<ATMTGInterstitialVideoDelegate>)delegate;
- (void)loadAdWithBidToken:(NSString *)bidToken;
- (void)showFromViewController:(UIViewController *)viewController;
- (BOOL)isVideoReadyToPlay:(NSString *)unitId;
- (void)cleanAllVideoFileCache;
@end
