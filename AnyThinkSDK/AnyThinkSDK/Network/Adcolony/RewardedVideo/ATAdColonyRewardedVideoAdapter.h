//
//  ATAdColonyRewardedVideoAdapter.h
//  AnyThinkAdColonyRewardedVideoAdapter
//
//  Created by Martin Lau on 11/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
extern NSString *const kAdColonyRVCustomEventKey;
typedef NS_ENUM(NSUInteger, ATAdColonyIAPEngagement) {
    
    /** IAP was enabled for the ad, and the user engaged via a dynamic end card (DEC). */
    ATAdColonyIAPEngagementEndCard = 0,
    
    /** IAP was enabled for the ad, and the user engaged via an in-vdeo engagement (Overlay). */
    ATAdColonyIAPEngagementOverlay
};

typedef NS_ENUM(NSUInteger, ATAdColonyZoneType) {
    
    /** Interstitial zone type */
    ATAdColonyZoneTypeInterstitial = 0,
    
    /** Native zone type */
    ATAdColonyZoneTypeNative
};

@interface ATAdColonyRewardedVideoAdapter : NSObject

@end

@protocol ATAdColonyZone<NSObject>
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) ATAdColonyZoneType type;
@property (nonatomic, readonly) BOOL enabled;
@property (nonatomic, readonly) BOOL rewarded;
@property (nonatomic, readonly) NSUInteger viewsPerReward;
@property (nonatomic, readonly) NSUInteger viewsUntilReward;
@property (nonatomic, readonly) NSUInteger rewardAmount;
@property (nonatomic, readonly) NSString *rewardName;
-(void)setReward:(nullable void (^)(BOOL success, NSString *name, int amount))reward;
@end

@protocol AdColonyAdRequestError <NSObject>
- (nonnull instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)coder NS_UNAVAILABLE;
- (nonnull instancetype)initWithDomain:(nonnull NSErrorDomain)domain code:(NSInteger)code userInfo:(nullable NSDictionary<NSErrorUserInfoKey, id> *)dict NS_UNAVAILABLE;
@property (nonatomic, nonnull, strong, readonly) NSString *zoneId;
@end

@protocol ATAdColonyAppOptions<NSObject>
@property (nonatomic, strong, nullable) NSString *userID;
@property (nonatomic) BOOL gdprRequired;
@property (nonatomic) NSString *gdprConsentString;
- (id<ATAdColonyAppOptions>)setPrivacyConsentString:(NSString *)consentString forType:(NSString *)type;

- (id<ATAdColonyAppOptions>)setPrivacyFrameworkOfType:(NSString *)type isRequired:(BOOL)required;
@end

@protocol ATAdColonyInterstitial;
@protocol ATAdColonyInterstitialDelegate;
@protocol ATAdColony<NSObject>
+ (NSString *)getSDKVersion;
+ (void)configureWithAppID:(NSString *)appID zoneIDs:(NSArray<NSString *> *)zoneIDs options:(nullable id)options completion:(nullable void (^)(NSArray<id<ATAdColonyZone>> *zones))completion;
+ (void)requestInterstitialInZone:(NSString *)zoneID options:(nullable id)options success:(void (^)(id<ATAdColonyInterstitial>ad))success failure:(nullable void (^)(NSError *error))failure;
+ (void)requestInterstitialInZone:(NSString *)zoneID options:(id<ATAdColonyAppOptions>)options andDelegate:(id<ATAdColonyInterstitialDelegate>)delegate;

@end

@protocol ATAdColonyInterstitialDelegate <NSObject>
- (void)adColonyInterstitialDidLoad:(id<ATAdColonyInterstitial> _Nonnull)interstitial;
- (void)adColonyInterstitialDidFailToLoad:(id<AdColonyAdRequestError>)error;
- (void)adColonyInterstitialWillOpen:(id<ATAdColonyInterstitial> _Nonnull)interstitial;
- (void)adColonyInterstitialDidClose:(id<ATAdColonyInterstitial> _Nonnull)interstitial;
- (void)adColonyInterstitialExpired:(id<ATAdColonyInterstitial> _Nonnull)interstitial;
- (void)adColonyInterstitialWillLeaveApplication:(id<ATAdColonyInterstitial> _Nonnull)interstitial;
- (void)adColonyInterstitialDidReceiveClick:(id<ATAdColonyInterstitial> _Nonnull)interstitial;
- (void)adColonyInterstitial:(id<ATAdColonyInterstitial> _Nonnull)interstitial iapOpportunityWithProductId:(NSString * _Nonnull)iapProductID andEngagement:(ATAdColonyIAPEngagement)engagement;

@end

@protocol ATAdColonyInterstitial<NSObject>
@property (nonatomic, nullable, weak) id<ATAdColonyInterstitialDelegate> delegate;
@property (nonatomic, readonly) NSString *zoneID;
@property (nonatomic, readonly) BOOL expired;
@property (nonatomic, readonly) BOOL audioEnabled;
@property (nonatomic, readonly) BOOL iapEnabled;
- (void)setOpen:(nullable void (^)(void))open;
- (void)setClose:(nullable void (^)(void))close;
- (void)setAudioStart:(nullable void (^)(void))audioStart;
- (void)setAudioStop:(nullable void (^)(void))audioStop;
- (void)setExpire:(nullable void (^)(void))expire;
- (void)setLeftApplication:(nullable void (^)(void))leftApplication;
- (void)setClick:(nullable void (^)(void))click;
- (void)setIapOpportunity:(nullable void (^)(NSString *iapProductID, ATAdColonyIAPEngagement engagement))iapOpportunity;
- (BOOL)showWithPresentingViewController:(UIViewController *)viewController;
- (void)cancel;
@end
