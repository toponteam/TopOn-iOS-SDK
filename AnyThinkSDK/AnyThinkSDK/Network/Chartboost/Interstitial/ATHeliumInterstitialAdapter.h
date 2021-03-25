//
//  ATHeliumInterstitialAdapter.h
//  AnyThinkChartboostInterstitialAdapter
//
//  Created by stephen on 7/9/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@protocol HeliumSdkDelegate <NSObject>
@end
@protocol CHBHeliumInterstitialAdDelegate <HeliumSdkDelegate>
@end

@interface ATHeliumInterstitialAdapter : NSObject
@end

@protocol HeliumInterstitialAd <NSObject>
- (void) loadAd;
- (void) showAdWithViewController:(UIViewController *)vc;
- (BOOL) readyToShow;
@end

@protocol HeliumError<NSObject>
@property (nonatomic, readonly) NSUInteger errorCode;
@property (nonatomic,readonly) NSString *errorDescription;
@end


@protocol ATHeliumSdk<NSObject>
+(instancetype) sharedHelium;
- (void)startWithAppId:(NSString*)appId andAppSignature:(NSString*)appSignature delegate:(id<HeliumSdkDelegate>)delegate;
- (id<HeliumInterstitialAd>)interstitialAdProviderWithDelegate:(id<CHBHeliumInterstitialAdDelegate>)delegate andPlacementName:(nonnull NSString *)placementName;
//- (id<HeliumRewardedAd>)rewardedAdProviderWithDelegate:(id<CHBHeliumRewardedAdDelegate>)delegate andPlacementName:(nonnull NSString *)placementName;
- (void)setSubjectToCoppa:(BOOL)isSubject;
- (void)setSubjectToGDPR:(BOOL)isSubject;
- (void)setUserHasGivenConsent:(BOOL)hasGivenConsent;
- (void)setCCPAConsent:(BOOL)hasGivenConsent;
@end


NS_ASSUME_NONNULL_END
