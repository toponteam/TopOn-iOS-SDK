//
//  ATGoogleAdManagerRewardedVideoAdapter.h
//  AnyThinkAdmobRewardedVideoAdapter
//
//  Created by stephen on 7/27/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATRewardedVideoAdapter.h"
extern NSString *const kGoogleAdManagerRVAssetsCustomEventKey;

@interface ATGoogleAdManagerRewardedVideoAdapter : NSObject
@end

@protocol ATDFPRequest<NSObject>
+ (NSString *)sdkVersion;
+ (instancetype)request;
@end

typedef void (^ATGADRewardedAdLoadCompletionHandler)(NSError *_Nullable error);
@protocol DFPRewardedAdDelegate;
@protocol ATDFPRewardedAd<NSObject>
@property(nonatomic, readonly) id<ATDFPRewardedAd> rewardedAd;
@property(nonatomic, readonly) id <ATDFPRewardedAd> GADAd;
@property(nonatomic, readonly) NSArray<id<ATDFPRewardedAd>> *monitors;
@property(nonatomic, readonly) id<ATDFPRewardedAd> clickProtection;
@property(nonatomic, readonly) NSString *debugDialogString;
- (nonnull instancetype)initWithAdUnitID:(nonnull NSString *)adUnitID;
- (void)loadRequest:(nullable id<ATDFPRequest>)request completionHandler:(nullable ATGADRewardedAdLoadCompletionHandler)completionHandler;
@property(nonatomic, readonly, getter=isReady) BOOL ready;
- (void)presentFromRootViewController:(nonnull UIViewController *)viewController delegate:(nonnull id<DFPRewardedAdDelegate>)delegate;
@end

@protocol DFPRewardedAdDelegate <NSObject>
@required
- (void)rewardedAd:(nonnull id<ATDFPRewardedAd>)rewardedAd userDidEarnReward:(id)reward;
@optional
- (void)rewardedAd:(nonnull id<ATDFPRewardedAd>)rewardedAd didFailToPresentWithError:(nonnull NSError *)error;
- (void)rewardedAdDidPresent:(nonnull id<ATDFPRewardedAd>)rewardedAd;
- (void)rewardedAdDidDismiss:(nonnull id<ATDFPRewardedAd>)rewardedAd;

@end
