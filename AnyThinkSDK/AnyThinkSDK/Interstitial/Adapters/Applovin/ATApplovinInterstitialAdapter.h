//
//  ATApplovinInterstitialAdapter.h
//  AnyThinkApplovinInterstitialAdapter
//
//  Created by Martin Lau on 25/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATApplovinInterstitialAdapter : NSObject

@end
@protocol ATALAdSize<NSObject>
+ (instancetype)sizeInterstitial;
@end

@protocol ALAdLoadDelegate;
@protocol ATALAdService<NSObject>
- (void)loadNextAdForZoneIdentifier:(NSString *)zoneIdentifier andNotify:(id<ALAdLoadDelegate>)delegate;
@end

@protocol ATALSdk<NSObject>
- (void)initializeSdk;
+ (NSString *)version;
+(NSUInteger)versionCode;
+ (instancetype)sharedWithKey:(NSString *)sdkKey;
@property (strong, nonatomic, readonly) id<ATALAdService>adService;
@end

@protocol ATALAd<NSObject>
@end



@protocol ATALPrivacySettings<NSObject>
+ (void)setHasUserConsent:(BOOL)hasUserConsent;
+ (void)setIsAgeRestrictedUser:(BOOL)isAgeRestrictedUser;
@end


@protocol ATALAdDisplayDelegate;

@protocol ALAdLoadDelegate <NSObject>
- (void)adService:(id<ATALAdService>)adService didLoadAd:(id<ATALAd>)ad;
- (void)adService:(id<ATALAdService>)adService didFailToLoadAdWithError:(int)code;
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

@protocol ATALInterstitialAd<NSObject>
@property (strong, nonatomic, nullable) id<ALAdLoadDelegate> adLoadDelegate;
@property (strong, nonatomic, nullable) id<ALAdDisplayDelegate> adDisplayDelegate;
@property (strong, nonatomic, nullable) id<ALAdVideoPlaybackDelegate> adVideoPlaybackDelegate;
- (void)showAd:(id<ATALAd>)ad;
- (instancetype)initWithSdk:(id<ATALSdk>)sdk;
@end
