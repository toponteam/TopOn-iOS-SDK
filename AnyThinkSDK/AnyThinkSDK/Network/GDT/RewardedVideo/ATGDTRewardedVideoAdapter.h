//
//  ATGDTRewardedVideoAdapter.h
//  AnyThinkGDTRewardedVideoAdapter
//
//  Created by Martin Lau on 2018/12/11.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ATGDTRewardedVideoAdapter : NSObject
@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);
@end

@protocol ATGDTServerSideVerificationOptions<NSObject>
@property(nonatomic, copy, nullable) NSString *userIdentifier;
@property(nonatomic, copy, nullable) NSString *customRewardString;
@end

@protocol GDTRewardedVideoAdDelegate;
@protocol ATGDTRewardVideoAd<NSObject>
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;
@property (nonatomic, assign, readonly) NSInteger expiredTimestamp;
@property (nonatomic, weak) id <GDTRewardedVideoAdDelegate> delegate;
@property (nonatomic) BOOL videoMuted;
@property (nonatomic, strong) id<ATGDTServerSideVerificationOptions> serverSideVerificationOptions;
- (instancetype)initWithPlacementId:(NSString *)placementId;
- (void)loadAd;
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController;
@end

@protocol GDTRewardedVideoAdDelegate <NSObject>
@end

@protocol GDTNativeExpressRewardedVideoAdDelegate;
@protocol ATGDTNativeExpressRewardVideoAd <NSObject>
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;
@property (nonatomic) BOOL videoMuted;
@property (nonatomic, assign, readonly) NSInteger expiredTimestamp;
@property (nonatomic, weak) id <GDTNativeExpressRewardedVideoAdDelegate> delegate;
@property (nonatomic, readonly) NSString *placementId;
@property (nonatomic, strong) id<ATGDTServerSideVerificationOptions> serverSideVerificationOptions;
- (instancetype)initWithPlacementId:(NSString *)placementId;
- (void)loadAd;
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController;
@end

@protocol GDTNativeExpressRewardedVideoAdDelegate <NSObject>
- (void)gdt_nativeExpressRewardVideoAdDidLoad:(id<ATGDTNativeExpressRewardVideoAd>)rewardedVideoAd;
- (void)gdt_nativeExpressRewardVideoAdVideoDidLoad:(id<ATGDTNativeExpressRewardVideoAd>)rewardedVideoAd;
- (void)gdt_nativeExpressRewardVideoAdWillVisible:(id<ATGDTNativeExpressRewardVideoAd>)rewardedVideoAd;
- (void)gdt_nativeExpressRewardVideoAdDidExposed:(id<ATGDTNativeExpressRewardVideoAd>)rewardedVideoAd;
- (void)gdt_nativeExpressRewardVideoAdDidClose:(id<ATGDTNativeExpressRewardVideoAd>)rewardedVideoAd;
- (void)gdt_nativeExpressRewardVideoAdDidClicked:(id<ATGDTNativeExpressRewardVideoAd>)rewardedVideoAd;
- (void)gdt_nativeExpressRewardVideoAd:(id<ATGDTNativeExpressRewardVideoAd>)rewardedVideoAd didFailWithError:(NSError *)error;
- (void)gdt_nativeExpressRewardVideoAdDidRewardEffective:(id<ATGDTNativeExpressRewardVideoAd>)rewardedVideoAd info:(NSDictionary *)info;
- (void)gdt_nativeExpressRewardVideoAdDidPlayFinish:(id<ATGDTNativeExpressRewardVideoAd>)rewardedVideoAd;
@end
