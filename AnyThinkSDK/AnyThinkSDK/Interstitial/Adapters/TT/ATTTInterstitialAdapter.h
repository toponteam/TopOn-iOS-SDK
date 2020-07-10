//
//  ATTTInterstitialAdapter.h
//  AnyThinkTTInterstitialAdapter
//
//  Created by Martin Lau on 25/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATTTInterstitialAdapter : NSObject
@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);
@end

typedef NS_ENUM(NSInteger, ATWMProposalSize) {
    ATWMProposalSize_Banner600_90,
    ATWMProposalSize_Banner600_100,
    ATWMProposalSize_Banner600_150,
    ATWMProposalSize_Banner600_260,
    ATWMProposalSize_Banner600_286,
    ATWMProposalSize_Banner600_300,
    ATWMProposalSize_Banner600_388,
    ATWMProposalSize_Banner600_400,
    ATWMProposalSize_Banner600_500,
    ATWMProposalSize_Feed228_150,
    ATWMProposalSize_Feed690_388,
    ATWMProposalSize_Interstitial600_400,
    ATWMProposalSize_Interstitial600_600,
    ATWMProposalSize_Interstitial600_900,
};

@protocol ATBUAdSDKManager<NSObject>
@property (nonatomic, copy, readonly, class) NSString *SDKVersion;
+ (void)setAppID:(NSString *)appID;
@end

@protocol ATBUSize<NSObject>
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
+ (instancetype)sizeBy:(ATWMProposalSize)proposalSize;
@end

@protocol BUInterstitialAdDelegate;

@protocol ATBUInterstitialAd<NSObject>
@property (nonatomic, weak, nullable) id<BUInterstitialAdDelegate> delegate;
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;
- (instancetype)initWithSlotID:(NSString *)slotID size:(id<ATBUSize>)expectSize;
- (void)loadAdData;
- (BOOL)showAdFromRootViewController:(nullable UIViewController *)rootViewController;
@end

@protocol BUInterstitialAdDelegate <NSObject>
@end

@protocol ATBUFullscreenVideoAd;
@protocol BUFullscreenVideoAdDelegate <NSObject>
@end

@protocol ATBUFullscreenVideoAd<NSObject>
@property (nonatomic, weak, nullable) id<BUFullscreenVideoAdDelegate> delegate;
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;
- (instancetype)initWithSlotID:(NSString *)slotID;
- (void)loadAdData;
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController;
@end

@protocol ATBUNativeExpressInterstitialAd;
@protocol BUNativeExpresInterstitialAdDelegate <NSObject>
@end

@protocol ATBUNativeExpressInterstitialAd<NSObject>
@property (nonatomic, weak, nullable) id<BUNativeExpresInterstitialAdDelegate> delegate;
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;
- (instancetype)initWithSlotID:(NSString *)slotID imgSize:(id<ATBUSize>)expectSize adSize:(CGSize)adsize;
- (instancetype)initWithSlotID:(NSString *)slotID adSize:(CGSize)adsize;

- (void)loadAdData;
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController;
@end

@protocol BUNativeExpressFullscreenVideoAdDelegate;
@protocol ATBUNativeExpressFullscreenVideoAd <NSObject>
@property (nonatomic, weak, nullable) id<BUNativeExpressFullscreenVideoAdDelegate> delegate;
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;
- (instancetype)initWithSlotID:(NSString *)slotID;
- (void)loadAdData;
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController;
@end

@protocol BUNativeExpressFullscreenVideoAdDelegate <NSObject>
@end



