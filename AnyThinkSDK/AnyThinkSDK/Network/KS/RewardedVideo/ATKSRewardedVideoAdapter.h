//
//  ATKSRewardedVideoAdapter.h
//  AnyThinkSDK
//
//  Created by Topon on 2019/9/10.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ATKSAdShowDirection) {
    KSAdShowDirection_Vertical         =           0,
    KSAdShowDirection_Horizontal,
};

@interface ATKSRewardedVideoAdapter : NSObject
@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);
@end

@protocol ATKSRewardedVideoModel <NSObject>
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger amount;
@property (nonatomic, copy) NSString *extra;
@end

@protocol ATKSVideoAd <NSObject>
@property (nonatomic, readonly) BOOL isValid;
@property (nonatomic, assign) BOOL shouldMuted;
- (void)loadAdData;
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController showScene:(NSString *)showScene;
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController;
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController direction:(ATKSAdShowDirection)direction;
- (BOOL)isSameValidVideoAd:(id<ATKSVideoAd>)ad;

@end


@protocol KSRewardedVideoAdDelegate;
@protocol ATKSRewardedVideoAd <ATKSVideoAd>
@property (nonatomic, strong) id<ATKSRewardedVideoModel> rewardedVideoModel;
@property (nonatomic, weak, nullable) id<KSRewardedVideoAdDelegate> delegate;

- (instancetype)initWithPosId:(NSString *)posId rewardedVideoModel:(id<ATKSRewardedVideoModel>)rewardedVideoModel;
@end

@protocol KSRewardedVideoAdDelegate <NSObject>
- (void)rewardedVideoAdDidLoad:(id<ATKSRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAd:(id<ATKSRewardedVideoAd>)rewardedVideoAd didFailWithError:(NSError *_Nullable)error;
- (void)rewardedVideoAdVideoDidLoad:(id<ATKSRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdWillVisible:(id<ATKSRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdDidVisible:(id<ATKSRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdWillClose:(id<ATKSRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdDidClose:(id<ATKSRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdDidClick:(id<ATKSRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdDidPlayFinish:(id<ATKSRewardedVideoAd>)rewardedVideoAd didFailWithError:(NSError *_Nullable)error;
- (void)rewardedVideoAdDidClickSkip:(id<ATKSRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAdStartPlay:(id<ATKSRewardedVideoAd>)rewardedVideoAd;
- (void)rewardedVideoAd:(id<ATKSRewardedVideoAd>)rewardedVideoAd hasReward:(BOOL)hasReward;

@end

