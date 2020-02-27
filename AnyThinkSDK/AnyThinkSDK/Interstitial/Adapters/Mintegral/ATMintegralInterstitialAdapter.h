//
//  ATMintegralInterstitialAdapter.h
//  AnyThinkMintegralInterstitialAdapter
//
//  Created by Martin Lau on 25/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATMintegralInterstitialAdapter : NSObject
@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);
@end

typedef NS_ENUM(NSInteger, ATMTGUserPrivateType) {
    ATMTGUserPrivateType_ALL         = 0,
    ATMTGUserPrivateType_GeneralData = 1,
    ATMTGUserPrivateType_DeviceId    = 2,
    ATMTGUserPrivateType_Gps         = 3,
};

@protocol ATMTGSDK<NSObject>
+(instancetype) sharedInstance;
- (void)setUserPrivateInfoType:(ATMTGUserPrivateType)type agree:(BOOL)agree;
- (void)setAppID:(nonnull NSString *)appID ApiKey:(nonnull NSString *)apiKey;
@property (nonatomic, assign) BOOL consentStatus;
@end

@protocol ATMTGInterstitialAdManager;
#pragma mark - MTGInterstitialAdManagerDelegate
@protocol ATMTGInterstitialAdLoadDelegate <NSObject>
@optional
- (void) onInterstitialLoadSuccess:(id<ATMTGInterstitialAdManager>)adManager;
- (void) onInterstitialLoadFail:(nonnull NSError *)error adManager:(id<ATMTGInterstitialAdManager>)adManager;
@end

@protocol ATMTGInterstitialAdShowDelegate <NSObject>
@optional
- (void) onInterstitialShowSuccess:(id<ATMTGInterstitialAdManager>)adManager;
- (void) onInterstitialShowFail:(nonnull NSError *)error adManager:(id<ATMTGInterstitialAdManager>)adManager;
- (void) onInterstitialClosed:(id<ATMTGInterstitialAdManager>)adManager;
- (void) onInterstitialAdClick:(id<ATMTGInterstitialAdManager>)adManager;
@end

@protocol ATMTGInterstitialAdManager<NSObject>
@property (nonatomic, readonly)   NSString * _Nonnull currentUnitId;
- (nonnull instancetype)initWithUnitID:(nonnull NSString *)unitId adCategory:(NSInteger)adCategory;
- (void)loadWithDelegate:(nullable id <ATMTGInterstitialAdLoadDelegate>) delegate;
- (void)showWithDelegate:(nullable id <ATMTGInterstitialAdShowDelegate>)delegate presentingViewController:(nullable UIViewController *)viewController;
@end

@protocol ATMTGInterstitialVideoAdManager;
@protocol ATMTGInterstitialVideoDelegate <NSObject>
@optional
- (void) onInterstitialAdLoadSuccess:(id<ATMTGInterstitialVideoAdManager>)adManager;
- (void) onInterstitialVideoLoadSuccess:(id<ATMTGInterstitialVideoAdManager>)adManager;
- (void) onInterstitialVideoLoadFail:(nonnull NSError *)error adManager:(id<ATMTGInterstitialVideoAdManager>)adManager;
- (void) onInterstitialVideoShowSuccess:(id<ATMTGInterstitialVideoAdManager>)adManager;
- (void) onInterstitialVideoShowFail:(nonnull NSError *)error adManager:(id<ATMTGInterstitialVideoAdManager>)adManager;
- (void) onInterstitialVideoAdClick:(id<ATMTGInterstitialVideoAdManager>)adManager;
- (void)onInterstitialVideoAdDismissedWithConverted:(BOOL)converted adManager:(id<ATMTGInterstitialVideoAdManager>)adManager;
@end

@protocol ATMTGInterstitialVideoAdManager<NSObject>
@property (nonatomic, weak) id  <ATMTGInterstitialVideoDelegate> _Nullable delegate;
@property (nonatomic, readonly)   NSString * _Nonnull currentUnitId;
@property (nonatomic, assign) BOOL  playVideoMute;
- (nonnull instancetype)initWithUnitID:(nonnull NSString *)unitId delegate:(nullable id<ATMTGInterstitialVideoDelegate>)delegate;
- (void)loadAd;
- (void)showFromViewController:(UIViewController *_Nonnull)viewController;
- (void)cleanAllVideoFileCache;
- (BOOL)isVideoReadyToPlay:(nonnull NSString *)unitId;
@end

@protocol ATMTGBidInterstitialVideoAdManager<NSObject>
@property (nonatomic, weak) id  <ATMTGInterstitialVideoDelegate> _Nullable delegate;
@property (nonatomic, readonly)   NSString * _Nonnull currentUnitId;
@property (nonatomic, assign) BOOL  playVideoMute;
- (nonnull instancetype)initWithUnitID:(nonnull NSString *)unitId delegate:(nullable id<ATMTGInterstitialVideoDelegate>)delegate;
- (void)loadAdWithBidToken:(nonnull NSString *)bidToken;
- (void)showFromViewController:(UIViewController *_Nonnull)viewController;
- (BOOL)isVideoReadyToPlay:(nonnull NSString *)unitId;
- (void)cleanAllVideoFileCache;
@end
