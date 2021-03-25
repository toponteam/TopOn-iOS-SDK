//
//  ATKSInterstitialAdapter.h
//  AnyThinkSDK
//
//  Created by Topon on 2019/9/10.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ATKSInterstitialAdapter : NSObject
@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);

@end

@protocol ATKSVideoAd <NSObject>
@property (nonatomic, readonly) BOOL isValid;
@property (nonatomic, assign) BOOL shouldMuted;
- (void)loadAdData;
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController;
@end

@protocol KSFullscreenVideoAdDelegate;

@protocol ATKSFullscreenVideoAd <ATKSVideoAd>

@property (nonatomic, weak, nullable) id<KSFullscreenVideoAdDelegate> delegate;

- (instancetype)initWithPosId:(NSString *)posId;
@end

@protocol KSFullscreenVideoAdDelegate <NSObject>
- (void)fullscreenVideoAdDidLoad:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd;
- (void)fullscreenVideoAd:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error;
- (void)fullscreenVideoAdVideoDidLoad:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd;
- (void)fullscreenVideoAdWillVisible:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd;
- (void)fullscreenVideoAdDidVisible:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd;
- (void)fullscreenVideoAdWillClose:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd;
- (void)fullscreenVideoAdDidClose:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd;
- (void)fullscreenVideoAdDidClick:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd;
- (void)fullscreenVideoAdDidPlayFinish:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error;
- (void)fullscreenVideoAdDidClickSkip:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd;
- (void)fullscreenVideoAdStartPlay:(id<ATKSFullscreenVideoAd>)fullscreenVideoAd;
@end


