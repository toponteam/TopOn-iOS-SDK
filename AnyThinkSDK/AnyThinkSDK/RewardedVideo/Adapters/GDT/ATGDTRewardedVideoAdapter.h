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

@protocol ATGDTSDKConfig<NSObject>
+ (NSString *)sdkVersion;
@end

@protocol GDTRewardedVideoAdDelegate;
@protocol ATGDTRewardVideoAd<NSObject>
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;
@property (nonatomic, assign, readonly) NSInteger expiredTimestamp;
@property (nonatomic, weak) id <GDTRewardedVideoAdDelegate> delegate;
- (instancetype)initWithAppId:(NSString *)appId placementId:(NSString *)placementId;
- (void)loadAd;
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController;

@end


@protocol GDTRewardedVideoAdDelegate <NSObject>
@optional
- (void)gdt_rewardVideoAdDidLoad:(id<ATGDTRewardVideoAd>)rewardedVideoAd;
- (void)gdt_rewardVideoAdVideoDidLoad:(id<ATGDTRewardVideoAd>)rewardedVideoAd;
- (void)gdt_rewardVideoAdWillVisible:(id<ATGDTRewardVideoAd>)rewardedVideoAd;
- (void)gdt_rewardVideoAdDidExposed:(id<ATGDTRewardVideoAd>)rewardedVideoAd;
- (void)gdt_rewardVideoAdDidClose:(id<ATGDTRewardVideoAd>)rewardedVideoAd;
- (void)gdt_rewardVideoAdDidClicked:(id<ATGDTRewardVideoAd>)rewardedVideoAd;
- (void)gdt_rewardVideoAd:(id<ATGDTRewardVideoAd>)rewardedVideoAd didFailWithError:(NSError *)error;
- (void)gdt_rewardVideoAdDidRewardEffective:(id<ATGDTRewardVideoAd>)rewardedVideoAd;
- (void)gdt_rewardVideoAdDidPlayFinish:(id<ATGDTRewardVideoAd>)rewardedVideoAd;

@end
