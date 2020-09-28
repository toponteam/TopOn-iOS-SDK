//
//  ATTTInterstitialAdapter.h
//  AnyThinkTTInterstitialAdapter
//
//  Created by Martin Lau on 25/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATTTInterstitialAdapter : NSObject
@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);
@end

typedef NS_ENUM(NSInteger, ATWMProposalSize) {
    ATWMProposalSize_Banner600_90,
    ATWMProposalSize_Banner600_100,
    ATWMProposalSize_Banner600_150,
    ATWMProposalSize_Banner600_260,
    ATWMProposalSize_Banner600_286,
    ATWMProposalSize_Banner600_300,
    ATWMProposalSize_Banner600_388,
    ATWMProposalSize_Banner600_400,
    ATWMProposalSize_Banner600_500,
    ATWMProposalSize_Feed228_150,
    ATWMProposalSize_Feed690_388,
    ATWMProposalSize_Interstitial600_400,
    ATWMProposalSize_Interstitial600_600,
    ATWMProposalSize_Interstitial600_900,
};

@protocol ATBUAdSDKManager<NSObject>
@property (nonatomic, copy, readonly, class) NSString *SDKVersion;
+ (void)setAppID:(NSString *)appID;
@end

@protocol ATBUSize<NSObject>
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
+ (instancetype)sizeBy:(ATWMProposalSize)proposalSize;
@end

@protocol BUInterstitialAdDelegate;

@protocol ATBUInterstitialAd<NSObject>
@property (nonatomic, weak, nullable) id<BUInterstitialAdDelegate> delegate;
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;
- (instancetype)initWithSlotID:(NSString *)slotID size:(id<ATBUSize>)expectSize;
- (void)loadAdData;
- (BOOL)showAdFromRootViewController:(nullable UIViewController *)rootViewController;
@end

@protocol BUInterstitialAdDelegate <NSObject>
@optional
- (void)interstitialAdDidClick:(id<ATBUInterstitialAd>)interstitialAd;
- (void)interstitialAdDidClose:(id<ATBUInterstitialAd>)interstitialAd;
- (void)interstitialAdWillClose:(id<ATBUInterstitialAd>)interstitialAd;
- (void)interstitialAdDidLoad:(id<ATBUInterstitialAd>)interstitialAd;
- (void)interstitialAd:(id<ATBUInterstitialAd>)interstitialAd didFailWithError:(NSError *)error;
- (void)interstitialAdWillVisible:(id<ATBUInterstitialAd>)interstitialAd;
@end

@protocol ATBUFullscreenVideoAd;
@protocol BUFullscreenVideoAdDelegate <NSObject>
@optional
- (void)fullscreenVideoMaterialMetaAdDidLoad:(id<ATBUFullscreenVideoAd>)fullscreenVideoAd;
- (void)fullscreenVideoAdVideoDataDidLoad:(id<ATBUFullscreenVideoAd>)fullscreenVideoAd;
- (void)fullscreenVideoAdWillVisible:(id<ATBUFullscreenVideoAd>)fullscreenVideoAd;
- (void)fullscreenVideoAdDidClose:(id<ATBUFullscreenVideoAd>)fullscreenVideoAd;
- (void)fullscreenVideoAdDidClick:(id<ATBUFullscreenVideoAd>)fullscreenVideoAd;
- (void)fullscreenVideoAd:(id<ATBUFullscreenVideoAd>)fullscreenVideoAd didFailWithError:(NSError *)error;
- (void)fullscreenVideoAdDidPlayFinish:(id<ATBUFullscreenVideoAd>)fullscreenVideoAd didFailWithError:(NSError *)error;
- (void)fullscreenVideoAdDidClickSkip:(id<ATBUFullscreenVideoAd>)fullscreenVideoAd;
@end

@protocol ATBUFullscreenVideoAd<NSObject>
@property (nonatomic, weak, nullable) id<BUFullscreenVideoAdDelegate> delegate;
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;
- (instancetype)initWithSlotID:(NSString *)slotID;
- (void)loadAdData;
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController;
@end

@protocol ATBUNativeExpressInterstitialAd;
@protocol BUNativeExpresInterstitialAdDelegate <NSObject>
@optional
- (void)nativeExpresInterstitialAdDidLoad:(id<ATBUNativeExpressInterstitialAd>)interstitialAd;
- (void)nativeExpresInterstitialAd:(id<ATBUNativeExpressInterstitialAd>)interstitialAd didFailWithError:(NSError * __nullable)error;
- (void)nativeExpresInterstitialAdRenderSuccess:(id<ATBUNativeExpressInterstitialAd>)interstitialAd;
- (void)nativeExpresInterstitialAdRenderFail:(id<ATBUNativeExpressInterstitialAd>)interstitialAd error:(NSError * __nullable)error;
- (void)nativeExpresInterstitialAdWillVisible:(id<ATBUNativeExpressInterstitialAd>)interstitialAd;
- (void)nativeExpresInterstitialAdDidClick:(id<ATBUNativeExpressInterstitialAd>)interstitialAd;
- (void)nativeExpresInterstitialAdWillClose:(id<ATBUNativeExpressInterstitialAd>)interstitialAd;
- (void)nativeExpresInterstitialAdDidClose:(id<ATBUNativeExpressInterstitialAd>)interstitialAd;
@end

@protocol ATBUNativeExpressInterstitialAd<NSObject>
@property (nonatomic, weak, nullable) id<BUNativeExpresInterstitialAdDelegate> delegate;
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;
- (instancetype)initWithSlotID:(NSString *)slotID imgSize:(id<ATBUSize>)expectSize adSize:(CGSize)adsize;
- (instancetype)initWithSlotID:(NSString *)slotID adSize:(CGSize)adsize;

- (void)loadAdData;
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController;
@end

@protocol ATBUNativeExpressFullscreenVideoAdDelegate;
@protocol ATBUNativeExpressFullscreenVideoAd <NSObject>
@property (nonatomic, weak, nullable) id<ATBUNativeExpressFullscreenVideoAdDelegate> delegate;
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;
- (instancetype)initWithSlotID:(NSString *)slotID;
- (void)loadAdData;
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController;
@end

@protocol ATBUNativeExpressFullscreenVideoAdDelegate <NSObject>
@optional
- (void)nativeExpressFullscreenVideoAdDidLoad:(id <ATBUNativeExpressFullscreenVideoAd>)fullscreenVideoAd;
- (void)nativeExpressFullscreenVideoAd:(id <ATBUNativeExpressFullscreenVideoAd>)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error;
- (void)nativeExpressFullscreenVideoAdViewRenderSuccess:(id <ATBUNativeExpressFullscreenVideoAd>)rewardedVideoAd;
- (void)nativeExpressFullscreenVideoAdViewRenderFail:(id <ATBUNativeExpressFullscreenVideoAd>)rewardedVideoAd error:(NSError *_Nullable)error;
- (void)nativeExpressFullscreenVideoAdDidDownLoadVideo:(id <ATBUNativeExpressFullscreenVideoAd>)fullscreenVideoAd;
- (void)nativeExpressFullscreenVideoAdWillVisible:(id <ATBUNativeExpressFullscreenVideoAd>)fullscreenVideoAd;
- (void)nativeExpressFullscreenVideoAdDidVisible:(id <ATBUNativeExpressFullscreenVideoAd>)fullscreenVideoAd;
- (void)nativeExpressFullscreenVideoAdDidClick:(id <ATBUNativeExpressFullscreenVideoAd>)fullscreenVideoAd;
- (void)nativeExpressFullscreenVideoAdDidClickSkip:(id <ATBUNativeExpressFullscreenVideoAd>)fullscreenVideoAd;
- (void)nativeExpressFullscreenVideoAdWillClose:(id <ATBUNativeExpressFullscreenVideoAd>)fullscreenVideoAd;
- (void)nativeExpressFullscreenVideoAdDidClose:(id <ATBUNativeExpressFullscreenVideoAd>)fullscreenVideoAd;
- (void)nativeExpressFullscreenVideoAdDidPlayFinish:(id <ATBUNativeExpressFullscreenVideoAd>)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error;
@end



