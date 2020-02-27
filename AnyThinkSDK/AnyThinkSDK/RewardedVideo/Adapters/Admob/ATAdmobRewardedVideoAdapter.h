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
typedef NS_ENUM(NSInteger, ATPACConsentStatus) {
    ATPACConsentStatusUnknown = 0,          ///< Unknown consent status.
    ATPACConsentStatusNonPersonalized = 1,  ///< User consented to non-personalized ads.
    ATPACConsentStatusPersonalized = 2,     ///< User consented to personalized ads.
};
@interface ATAdmobRewardedVideoAdapter : NSObject<ATRewardedVideoAdapter>
@end

@protocol ATPACConsentInformation<NSObject>
+ (instancetype)sharedInstance;
@property(nonatomic) ATPACConsentStatus consentStatus;
@property(nonatomic, getter=isTaggedForUnderAgeOfConsent) BOOL tagForUnderAgeOfConsent;
@end

@protocol ATGADRequest<NSObject>
+ (NSString *)sdkVersion;
+ (instancetype)request;
@property(nonatomic, copy) NSArray *testDevices;
@end

typedef void (^ATGADRewardedAdLoadCompletionHandler)(NSError *_Nullable error);
@protocol GADRewardedAdDelegate;
@protocol ATGADRewardedAd<NSObject>
@property(nonatomic, readonly) id<ATGADRewardedAd> rewardedAd;
@property(nonatomic, readonly) id <ATGADRewardedAd> GADAd;
@property(nonatomic, readonly) NSArray<id<ATGADRewardedAd>> *monitors;
@property(nonatomic, readonly) id<ATGADRewardedAd> clickProtection;
@property(nonatomic, readonly) NSString *debugDialogString;
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
