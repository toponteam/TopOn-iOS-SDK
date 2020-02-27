//
//  ATApplovinRewardedVideoAdapter.h
//  AnyThinkApplovinRewardedVideoAdapter
//
//  Created by Martin Lau on 09/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATRewardedVideoAdapter.h"
@interface ATApplovinRewardedVideoAdapter : NSObject<ATRewardedVideoAdapter>
@end

@protocol ATALSdk<NSObject>
- (void)initializeSdk;
+ (NSString *)version;
+(NSUInteger)versionCode;
+ (instancetype)sharedWithKey:(NSString *)sdkKey;
@end

@protocol ATALAd<NSObject>
@end

@protocol ATALAdService<NSObject>
@end

@protocol ATALPrivacySettings<NSObject>
+ (void)setHasUserConsent:(BOOL)hasUserConsent;
+ (void)setIsAgeRestrictedUser:(BOOL)isAgeRestrictedUser;
@end

@protocol ALAdLoadDelegate;
@protocol ALAdRewardDelegate;
@protocol ALAdDisplayDelegate;
@protocol ALAdVideoPlaybackDelegate;
@protocol ATALIncentivizedInterstitialAd<NSObject>
- (instancetype)initWithZoneIdentifier:(NSString *)zoneIdentifier sdk:(id<ATALSdk>)sdk;
- (void)preloadAndNotify:(id<ALAdLoadDelegate>)adLoadDelegate;
+ (void)setUserIdentifier:(NSString *)userIdentifier;
- (void)showAndNotify:(id<ALAdRewardDelegate>)adRewardDelegate;
@property (strong, nonatomic) id <ALAdDisplayDelegate> adDisplayDelegate;
@property (strong, nonatomic) id <ALAdVideoPlaybackDelegate> adVideoPlaybackDelegate;
@property (readonly, atomic, getter=isReadyForDisplay) BOOL readyForDisplay;
@end

@protocol ALAdLoadDelegate <NSObject>
- (void)adService:(id<ATALAdService>)adService didLoadAd:(id<ATALAd>)ad;
- (void)adService:(id<ATALAdService>)adService didFailToLoadAdWithError:(int)code;
@end

@protocol ALAdRewardDelegate <NSObject>
@required
- (void)rewardValidationRequestForAd:(id<ATALAd>)ad didSucceedWithResponse:(NSDictionary *)response;
- (void)rewardValidationRequestForAd:(id<ATALAd>)ad didExceedQuotaWithResponse:(NSDictionary *)response;
- (void)rewardValidationRequestForAd:(id<ATALAd>)ad wasRejectedWithResponse:(NSDictionary *)response;
- (void)rewardValidationRequestForAd:(id<ATALAd>)ad didFailWithError:(NSInteger)responseCode;
@optional
- (void)userDeclinedToViewAd:(id<ATALAd>)ad;

@end

@protocol ALAdDisplayDelegate <NSObject>
- (void)ad:(id<ATALAd>)ad wasDisplayedIn:(UIView *)view;
- (void)ad:(id<ATALAd>)ad wasHiddenIn:(UIView *)view;
- (void)ad:(id<ATALAd>)ad wasClickedIn:(UIView *)view;
@end

@protocol ALAdVideoPlaybackDelegate <NSObject>
- (void)videoPlaybackBeganInAd:(id<ATALAd>)ad;
- (void)videoPlaybackEndedInAd:(id<ATALAd>)ad atPlaybackPercent:(NSNumber *)percentPlayed fullyWatched:(BOOL)wasFullyWatched;
@end
