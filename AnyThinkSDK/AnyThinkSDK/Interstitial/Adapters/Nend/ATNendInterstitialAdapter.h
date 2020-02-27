//
//  ATNendInterstitialAdapter.h
//  AnyThinkNendInterstitialAdapter
//
//  Created by Martin Lau on 2019/4/18.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kATNendInterstitialLoadedNotification;
extern NSString *const kATNendInterstitialClickNotification;
extern NSString *const kATNendInterstitialNotificationUserInfoSpotIDKey;
extern NSString *const kATNendInterstitialNotificationUserInfoClickTypeKey;
extern NSString *const kATNendInterstitialNotificationUserInfoStatusKey;
@interface ATNendInterstitialAdapter : NSObject
@end

#pragma mark - interstitial
@protocol NADInterstitialDelegate <NSObject>
@optional
- (void)didFinishLoadInterstitialAdWithStatus:(NSInteger)status;
- (void)didFinishLoadInterstitialAdWithStatus:(NSInteger)status spotId:(NSString *)spotId;
- (void)didClickWithType:(NSInteger)type;
- (void)didClickWithType:(NSInteger)type spotId:(NSString *)spotId;
@end
@protocol ATNADInterstitial<NSObject>
@property (nonatomic, weak, readwrite) id<NADInterstitialDelegate> delegate;
@property (nonatomic) BOOL isOutputLog __deprecated_msg("This method is deprecated. Use setLogLevel: method of NADLogger instead.");
@property (nonatomic) BOOL enableAutoReload;
+ (instancetype)sharedInstance;
- (void)loadAdWithApiKey:(NSString *)apiKey spotId:(NSString *)spotId;
- (NSInteger)showAdFromViewController:(UIViewController *)viewController;
- (NSInteger)showAdFromViewController:(UIViewController *)viewController spotId:(NSString *)spotId;
- (BOOL)dismissAd;
@end

#pragma mark - interstitial video
@protocol ATNADInterstitialVideo;
@protocol NADInterstitialVideoDelegate <NSObject>
@optional
- (void)nadInterstitialVideoAdDidReceiveAd:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd;
- (void)nadInterstitialVideoAd:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd didFailToLoadWithError:(NSError *)error;
- (void)nadInterstitialVideoAdDidFailedToPlay:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd;
- (void)nadInterstitialVideoAdDidOpen:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd;
- (void)nadInterstitialVideoAdDidClose:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd;
- (void)nadInterstitialVideoAdDidStartPlaying:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd;
- (void)nadInterstitialVideoAdDidStopPlaying:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd;
- (void)nadInterstitialVideoAdDidCompletePlaying:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd;
- (void)nadInterstitialVideoAdDidClickAd:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd;
- (void)nadInterstitialVideoAdDidClickInformation:(id<ATNADInterstitialVideo>)nadInterstitialVideoAd;
@end

@protocol ATNADVideo<NSObject>
@property (nonatomic, copy, nullable) NSString *mediationName;
@property (nonatomic, copy, nullable) NSString *userId;
@property (nonatomic) id userFeature;
@property (nonatomic, readonly, getter=isReady) BOOL ready;
@property (nonatomic) BOOL isLocationEnabled;
- (instancetype)initWithSpotId:(NSString *)spotId apiKey:(NSString *)apiKey;
- (void)loadAd;
- (void)showAdFromViewController:(UIViewController *)viewController;
- (void)releaseVideoAd;
@end

@protocol ATNADInterstitialVideo<ATNADVideo>
@property (nonatomic, weak, readwrite) id<NADInterstitialVideoDelegate> delegate;
@property (nonatomic, copy) UIColor *fallbackFullboardBackgroundColor;
@property (nonatomic) BOOL isMuteStartPlaying;
- (void)addFallbackFullboardWithSpotId:(NSString *)spotId apiKey:(NSString *)apiKey;
@end

#pragma mark - fullscreen interstitial
@protocol ATNADFullBoard;
@protocol NADFullBoardViewDelegate <NSObject>
@optional
- (void)NADFullBoardDidClickAd:(id<ATNADFullBoard>)ad;
@end

@protocol NADFullBoardView <NSObject>
@property (nonatomic, weak) id<NADFullBoardViewDelegate> delegate;
- (void)enableCloseButtonWithClickHandler:(dispatch_block_t)handler;
@end

@protocol NADFullBoardDelegate <NADFullBoardViewDelegate>
@optional
- (void)NADFullBoardDidShowAd:(id<ATNADFullBoard>)ad;
- (void)NADFullBoardDidDismissAd:(id<ATNADFullBoard>)ad;
@end

@protocol ATNADFullBoard<NSObject>
@property (nonatomic, weak) id<NADFullBoardDelegate> delegate;
@property (nonatomic, copy) UIColor *backgroundColor;
- (void)showFromViewController:(UIViewController *)viewController;
- (UIViewController<NADFullBoardView> *)fullBoardAdViewController;
@end

typedef void(^ATNADFullBoardLoaderCompletionHandler)(id<ATNADFullBoard>ad, NSInteger error);
@protocol ATNADFullBoardLoader<NSObject>
- (instancetype)initWithSpotId:(NSString *)spotId apiKey:(NSString *)apiKey;
- (void)loadAdWithCompletionHandler:(ATNADFullBoardLoaderCompletionHandler)handler;
@end
