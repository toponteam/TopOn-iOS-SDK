//
//  ATTTRewardedVideoAdapter.h
//  AnyThinkTTRewardedVideoAdapter
//
//  Created by Martin Lau on 14/08/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATTTRewardedVideoAdapter : NSObject
@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);
@end

@protocol ATBUAdSDKManager<NSObject>
@property (nonatomic, copy, readonly, class) NSString *SDKVersion;
+ (void)setAppID:(NSString *)appID;
@end

@protocol ATBURewardedVideoModel<NSObject>
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *rewardName;
@property (nonatomic, assign) NSInteger rewardAmount;
@property (nonatomic, copy) NSString *extra;
@property (nonatomic, assign) BOOL isShowDownloadBar;
@end

@protocol BURewardedVideoAdDelegate;
@protocol ATBURewardedVideoAd<NSObject>
@property (nonatomic, weak, nullable) id<BURewardedVideoAdDelegate> delegate;
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;
- (instancetype)initWithSlotID:(NSString *)slotID rewardedVideoModel:(id<ATBURewardedVideoModel>)model;
- (void)loadAdData;
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController;
@end

@protocol BURewardedVideoAdDelegate <NSObject>
@optional
- (void)rewardedVideoAdDidLoad:(id<ATBURewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdVideoDidLoad:(id<ATBURewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdDidVisible:(id<ATBURewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdDidClose:(id<ATBURewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdDidClick:(id<ATBURewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdDidClickDownload:(id<ATBURewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAd:(id<ATBURewardedVideoAd>)rewardedVideoAd didFailWithError:(NSError *)error;
- (void)rewardedVideoAdDidPlayFinish:(id<ATBURewardedVideoAd>)rewardedVideoAd didFailWithError:(NSError *)error;
- (void)rewardedVideoAdServerRewardDidSucceed:(id<ATBURewardedVideoAd>)rewardedVideoAd verify:(BOOL)verify;
- (void)rewardedVideoAdServerRewardDidFail:(id<ATBURewardedVideoAd>)rewardedVideoAd;
@end

@protocol ATBUNativeExpressRewardedVideoAdDelegate;
@protocol ATBUNativeExpressRewardedVideoAd <NSObject>
@property (nonatomic, strong) id<ATBURewardedVideoModel> rewardedVideoModel;
@property (nonatomic, weak, nullable) id<ATBUNativeExpressRewardedVideoAdDelegate> delegate;
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;
- (instancetype)initWithSlotID:(NSString *)slotID rewardedVideoModel:(id <ATBURewardedVideoModel>)model;
- (void)loadAdData;
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController;

@end

@protocol ATBUNativeExpressRewardedVideoAdDelegate <NSObject>
@optional
- (void)nativeExpressRewardedVideoAdDidLoad:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd;
- (void)nativeExpressRewardedVideoAd:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd didFailWithError:(NSError *_Nullable)error;
- (void)nativeExpressRewardedVideoAdDidDownLoadVideo:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd;
- (void)nativeExpressRewardedVideoAdViewRenderSuccess:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd;
- (void)nativeExpressRewardedVideoAdViewRenderFail:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd error:(NSError *_Nullable)error;
- (void)nativeExpressRewardedVideoAdWillVisible:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd;
- (void)nativeExpressRewardedVideoAdDidVisible:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd;
- (void)nativeExpressRewardedVideoAdWillClose:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd;
- (void)nativeExpressRewardedVideoAdDidClose:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd;
- (void)nativeExpressRewardedVideoAdDidClick:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd;
- (void)nativeExpressRewardedVideoAdDidClickSkip:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd;
- (void)nativeExpressRewardedVideoAdDidPlayFinish:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd didFailWithError:(NSError *_Nullable)error;
- (void)nativeExpressRewardedVideoAdServerRewardDidSucceed:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd verify:(BOOL)verify;
- (void)nativeExpressRewardedVideoAdServerRewardDidFail:(id <ATBUNativeExpressRewardedVideoAd>)rewardedVideoAd;
@end


