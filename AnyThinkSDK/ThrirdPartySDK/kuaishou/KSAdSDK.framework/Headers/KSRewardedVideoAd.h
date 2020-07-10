//
//  KSRewardedVideoAd.h
//  KSAdSDK
//
//  Created by 徐志军 on 2019/8/28.
//  Copyright © 2019 KuaiShou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KSVideoAd.h"


typedef NS_ENUM(NSInteger, KSRewardedVideoAdRewardedType) {
    // 正常的激励视频，必须是视频播放完成才显示关闭按钮
    KSRewardedVideoAdRewardedTypeNormal                 =           1,
    // 播放30秒，显示关闭按钮，并且有奖励，如果视频小于等于30秒，就是normal
    KSRewardedVideoAdRewardedTypePlay30Second           =           2,
//    // 播放5秒显示跳过，播放完成后，显示关闭按钮，点击跳过，弹出是否有奖励的选项
//    KSRewardedVideoAdRewardedTypeCanSkip                =           3,
//    // 播放5秒显示跳过，播放30秒，显示关闭按钮，并且有奖励，如果视频小于等于30秒，就是normal
//    KSRewardedVideoAdRewardedTypePlay30SecondAndCanSkip =           4,
};


@class KSRewardedVideoModel;
@protocol KSRewardedVideoAdDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface KSRewardedVideoAd : KSVideoAd
@property (nonatomic, strong) KSRewardedVideoModel *rewardedVideoModel;
@property (nonatomic, weak, nullable) id<KSRewardedVideoAdDelegate> delegate;

- (instancetype)initWithPosId:(NSString *)posId rewardedVideoModel:(KSRewardedVideoModel *)rewardedVideoModel;

- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController showScene:(nullable NSString *)showScene type:(KSRewardedVideoAdRewardedType)type;
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController showScene:(nullable NSString *)showScene type:(KSRewardedVideoAdRewardedType)type direction:(KSAdShowDirection)direction;
@end

@protocol KSRewardedVideoAdDelegate <NSObject>
@optional
/**
 This method is called when video ad material loaded successfully.
 */
- (void)rewardedVideoAdDidLoad:(KSRewardedVideoAd *)rewardedVideoAd;
/**
 This method is called when video ad materia failed to load.
 @param error : the reason of error
 */
- (void)rewardedVideoAd:(KSRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error;
/**
 This method is called when cached successfully.
 */
- (void)rewardedVideoAdVideoDidLoad:(KSRewardedVideoAd *)rewardedVideoAd;
/**
 This method is called when video ad slot will be showing.
 */
- (void)rewardedVideoAdWillVisible:(KSRewardedVideoAd *)rewardedVideoAd;
/**
 This method is called when video ad slot has been shown.
 */
- (void)rewardedVideoAdDidVisible:(KSRewardedVideoAd *)rewardedVideoAd;
/**
 This method is called when video ad is about to close.
 */
- (void)rewardedVideoAdWillClose:(KSRewardedVideoAd *)rewardedVideoAd;
/**
 This method is called when video ad is closed.
 */
- (void)rewardedVideoAdDidClose:(KSRewardedVideoAd *)rewardedVideoAd;

/**
 This method is called when video ad is clicked.
 */
- (void)rewardedVideoAdDidClick:(KSRewardedVideoAd *)rewardedVideoAd;
/**
 This method is called when video ad play completed or an error occurred.
 @param error : the reason of error
 */
- (void)rewardedVideoAdDidPlayFinish:(KSRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error;
/**
 This method is called when the user clicked skip button.
 */
- (void)rewardedVideoAdDidClickSkip:(KSRewardedVideoAd *)rewardedVideoAd;
/**
 This method is called when the video begin to play.
 */
- (void)rewardedVideoAdStartPlay:(KSRewardedVideoAd *)rewardedVideoAd;
/**
 This method is called when the user close video ad.
 */
- (void)rewardedVideoAd:(KSRewardedVideoAd *)rewardedVideoAd hasReward:(BOOL)hasReward;
@end

NS_ASSUME_NONNULL_END
