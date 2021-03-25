//
//  ATAdmobRewardedVideoAdapter.h
//  AnyThinkAdmobRewardedVideoAdapter
//
//  Created by Martin Lau on 07/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATRewardedVideoAdapter.h"
extern NSString *const kAdmobRVAssetsCustomEventKey;

@interface ATAdmobRewardedVideoAdapter : NSObject
@end

@protocol ATGADRequest<NSObject>
+ (NSString *)sdkVersion;
+ (instancetype)request;
@property(nonatomic, copy) NSArray *testDevices;
@end

typedef void (^ATGADRewardedAdLoadCompletionHandler)(NSError *_Nullable error);
@protocol GADRewardedAdDelegate;
@protocol ATGADServerSideVerificationOptions;
@protocol ATGADRewardedAd<NSObject>
@property(nonatomic, readonly) id<ATGADRewardedAd> rewardedAd;
@property(nonatomic, readonly) id <ATGADRewardedAd> GADAd;
@property(nonatomic, readonly) NSArray<id<ATGADRewardedAd>> *monitors;
@property(nonatomic, readonly) id<ATGADRewardedAd> clickProtection;
@property(nonatomic, readonly) NSString *debugDialogString;
@property(nonatomic, nullable) id<ATGADServerSideVerificationOptions> serverSideVerificationOptions;
- (nonnull instancetype)initWithAdUnitID:(nonnull NSString *)adUnitID;
- (void)loadRequest:(nullable id<ATGADRequest>)request completionHandler:(nullable ATGADRewardedAdLoadCompletionHandler)completionHandler;
@property(nonatomic, readonly, getter=isReady) BOOL ready;
- (void)presentFromRootViewController:(nonnull UIViewController *)viewController delegate:(nonnull id<GADRewardedAdDelegate>)delegate;
@end

@protocol GADRewardedAdDelegate <NSObject>
@required
- (void)rewardedAd:(nonnull id<ATGADRewardedAd>)rewardedAd userDidEarnReward:(id)reward;
@optional
- (void)rewardedAd:(nonnull id<ATGADRewardedAd>)rewardedAd didFailToPresentWithError:(nonnull NSError *)error;
- (void)rewardedAdDidPresent:(nonnull id<ATGADRewardedAd>)rewardedAd;
- (void)rewardedAdDidDismiss:(nonnull id<ATGADRewardedAd>)rewardedAd;

@end

@protocol ATGADServerSideVerificationOptions<NSObject>
@property(nonatomic, copy, nullable) NSString *userIdentifier;
@property(nonatomic, copy, nullable) NSString *customRewardString;
@end
